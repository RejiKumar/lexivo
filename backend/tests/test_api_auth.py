"""API tests for thin auth router (AuthProvider-backed /me)."""

from collections.abc import Generator
from datetime import UTC, datetime, timedelta

import jwt
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.adapters.auth.supabase_adapter import SupabaseAuthAdapter
from app.core.config import Settings, get_settings
from app.core.db import Base, get_db
from app.core.dependencies import get_auth_provider
from app.main import create_app
import app.models  # noqa: F401 — register ORM metadata

JWT_SECRET = "auth-router-test-jwt-secret-32ch!!"


def _token(sub: str = "auth-user", email: str = "auth@example.com") -> str:
    now = datetime.now(UTC)
    return jwt.encode(
        {
            "sub": sub,
            "email": email,
            "aud": "authenticated",
            "iat": now,
            "exp": now + timedelta(hours=1),
        },
        JWT_SECRET,
        algorithm="HS256",
    )


@pytest.fixture
def client() -> Generator[TestClient, None, None]:
    engine = create_engine(
        "sqlite+pysqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    SessionLocal = sessionmaker(bind=engine, expire_on_commit=False)

    app = create_app()
    app.dependency_overrides[get_settings] = lambda: Settings(
        auth_provider="supabase",
        supabase_jwt_secret=JWT_SECRET,
    )
    app.dependency_overrides[get_auth_provider] = lambda: SupabaseAuthAdapter(
        jwt_secret=JWT_SECRET,
    )

    def _override_db():
        session = SessionLocal()
        try:
            yield session
        finally:
            session.close()

    app.dependency_overrides[get_db] = _override_db

    with TestClient(app) as test_client:
        yield test_client

    app.dependency_overrides.clear()
    Base.metadata.drop_all(engine)
    engine.dispose()


def test_auth_me_unauthorized_without_token(client: TestClient) -> None:
    assert client.get("/api/v1/auth/me").status_code == 401


def test_auth_me_returns_identity_payload(client: TestClient) -> None:
    response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {_token()}"},
    )
    assert response.status_code == 200
    assert response.json() == {
        "subject": "auth-user",
        "email": "auth@example.com",
        "display_name": None,
    }
