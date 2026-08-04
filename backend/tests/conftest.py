"""Shared pytest fixtures — Settings, DB, Protocol fakes, API client helpers.

Compose-backed integration tests may use marker ``compose`` (optional; needs Docker).
"""

from __future__ import annotations

from collections.abc import Generator
from datetime import UTC, datetime, timedelta

import jwt
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.adapters.auth.supabase_adapter import SupabaseAuthAdapter
from app.core.config import Settings, get_settings
from app.core.db import Base, SessionLocal, get_db, reset_engine
from app.core.dependencies import get_auth_provider, get_storage_provider
from app.main import create_app
from app.tasks.celery_app import celery_app
from app.tasks.provider_overrides import (
    clear_task_provider_overrides,
    set_task_provider_overrides,
)
from tests.fakes import (
    FakeAuthProvider,
    FakeLLMProvider,
    FakeOCRProvider,
    FakeStorageProvider,
)

import app.models  # noqa: F401 — register ORM metadata

TEST_JWT_SECRET = "shared-test-jwt-secret-32chars!!"


@pytest.fixture
def test_settings() -> Settings:
    return Settings(
        auth_provider="supabase",
        supabase_jwt_secret=TEST_JWT_SECRET,
        storage_provider="r2",
        r2_endpoint_url="https://example.r2.cloudflarestorage.com",
        r2_access_key_id="ak",
        r2_secret_access_key="sk",
        r2_bucket_name="bucket",
        celery_task_always_eager=True,
        celery_broker_url="memory://",
        redis_url="cache+memory://",
        database_url="sqlite+pysqlite://",
    )


@pytest.fixture
def fake_auth() -> FakeAuthProvider:
    return FakeAuthProvider()


@pytest.fixture
def fake_storage() -> FakeStorageProvider:
    return FakeStorageProvider()


@pytest.fixture
def fake_llm() -> FakeLLMProvider:
    return FakeLLMProvider()


@pytest.fixture
def fake_ocr() -> FakeOCRProvider:
    return FakeOCRProvider()


@pytest.fixture
def db_engine():
    engine = create_engine(
        "sqlite+pysqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    yield engine
    Base.metadata.drop_all(engine)
    engine.dispose()


@pytest.fixture
def db_session(db_engine) -> Generator[Session, None, None]:
    """SQLAlchemy session bound to the shared in-memory test engine."""
    # Point app SessionLocal at the same engine so Celery eager tasks see rows.
    import app.core.db as db_mod

    db_mod._engine = db_engine
    SessionLocal.configure(bind=db_engine)

    session = SessionLocal()
    try:
        yield session
    finally:
        session.close()
        clear_task_provider_overrides()
        reset_engine()


@pytest.fixture
def celery_eager() -> Generator[None, None, None]:
    """Run Celery tasks in-process without Redis (preferred for CI)."""
    previous_eager = celery_app.conf.task_always_eager
    previous_propagate = celery_app.conf.task_eager_propagates
    celery_app.conf.task_always_eager = True
    celery_app.conf.task_eager_propagates = True
    try:
        yield
    finally:
        celery_app.conf.task_always_eager = previous_eager
        celery_app.conf.task_eager_propagates = previous_propagate
        clear_task_provider_overrides()


def make_auth_header(
    *,
    sub: str = "test-user",
    email: str = "test@example.com",
    secret: str = TEST_JWT_SECRET,
    name: str | None = None,
) -> dict[str, str]:
    now = datetime.now(UTC)
    payload: dict = {
        "sub": sub,
        "email": email,
        "aud": "authenticated",
        "iat": now,
        "exp": now + timedelta(hours=1),
    }
    if name is not None:
        payload["name"] = name
    token = jwt.encode(payload, secret, algorithm="HS256")
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def auth_header() -> dict[str, str]:
    return make_auth_header()


@pytest.fixture
def api_client(
    db_engine,
    test_settings: Settings,
    fake_storage: FakeStorageProvider,
    fake_ocr: FakeOCRProvider,
    celery_eager: None,
) -> Generator[TestClient, None, None]:
    """HTTPX/Starlette TestClient with auth, storage, DB, and eager OCR overrides."""
    import app.core.db as db_mod

    db_mod._engine = db_engine
    SessionLocal.configure(bind=db_engine)
    set_task_provider_overrides(ocr=fake_ocr, storage=fake_storage)

    app = create_app()
    app.dependency_overrides[get_settings] = lambda: test_settings
    app.dependency_overrides[get_auth_provider] = lambda: SupabaseAuthAdapter(
        jwt_secret=TEST_JWT_SECRET,
    )
    app.dependency_overrides[get_storage_provider] = lambda: fake_storage

    def _override_db():
        session = SessionLocal()
        try:
            yield session
        finally:
            session.close()

    app.dependency_overrides[get_db] = _override_db

    with TestClient(app) as client:
        yield client

    app.dependency_overrides.clear()
    clear_task_provider_overrides()
    reset_engine()
