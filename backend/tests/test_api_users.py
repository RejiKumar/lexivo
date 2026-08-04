"""API tests for thin users router via UserService."""

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

JWT_SECRET = "users-router-test-jwt-secret-32ch!"


def _token(sub: str = "profile-user", email: str = "profile@example.com") -> str:
    now = datetime.now(UTC)
    return jwt.encode(
        {
            "sub": sub,
            "email": email,
            "name": "Profile User",
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


def test_get_and_update_current_user_profile(client: TestClient) -> None:
    headers = {"Authorization": f"Bearer {_token()}"}

    get_resp = client.get("/api/v1/users/me", headers=headers)
    assert get_resp.status_code == 200
    body = get_resp.json()
    assert body["external_id"] == "profile-user"
    assert body["email"] == "profile@example.com"
    user_id = body["id"]

    patch_resp = client.patch(
        "/api/v1/users/me",
        headers=headers,
        json={"display_name": "Updated Name"},
    )
    assert patch_resp.status_code == 200
    assert patch_resp.json()["display_name"] == "Updated Name"
    assert patch_resp.json()["id"] == user_id

    again = client.get("/api/v1/users/me", headers=headers)
    assert again.json()["display_name"] == "Updated Name"


def test_users_me_requires_auth(client: TestClient) -> None:
    assert client.get("/api/v1/users/me").status_code == 401
