"""Integration tests: protected dependency via AuthProvider."""

from datetime import UTC, datetime, timedelta

import jwt
import pytest
from fastapi import Depends, FastAPI
from fastapi.testclient import TestClient

from app.adapters.auth.supabase_adapter import SupabaseAuthAdapter
from app.adapters.types import UserIdentity
from app.core.config import Settings, get_settings
from app.core.dependencies import get_auth_provider
from app.core.security import get_current_user

JWT_SECRET = "integration-test-jwt-secret-32ch!"


def _valid_token(sub: str = "prot-user") -> str:
    now = datetime.now(UTC)
    payload = {
        "sub": sub,
        "email": "prot@example.com",
        "aud": "authenticated",
        "iat": now,
        "exp": now + timedelta(hours=1),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm="HS256")


@pytest.fixture
def protected_app() -> FastAPI:
    app = FastAPI()

    @app.get("/protected")
    async def protected(user: UserIdentity = Depends(get_current_user)) -> dict:
        return {"subject": user.subject, "email": user.email}

    app.dependency_overrides[get_settings] = lambda: Settings(
        auth_provider="supabase",
        supabase_jwt_secret=JWT_SECRET,
    )
    app.dependency_overrides[get_auth_provider] = lambda: SupabaseAuthAdapter(
        jwt_secret=JWT_SECRET,
    )
    return app


def test_protected_dependency_rejects_missing_bearer(protected_app: FastAPI) -> None:
    client = TestClient(protected_app)
    response = client.get("/protected")
    assert response.status_code == 401


def test_protected_dependency_rejects_bad_bearer(protected_app: FastAPI) -> None:
    client = TestClient(protected_app)
    response = client.get(
        "/protected",
        headers={"Authorization": "Bearer totally-invalid"},
    )
    assert response.status_code == 401


def test_protected_dependency_accepts_valid_token(protected_app: FastAPI) -> None:
    client = TestClient(protected_app)
    response = client.get(
        "/protected",
        headers={"Authorization": f"Bearer {_valid_token()}"},
    )
    assert response.status_code == 200
    assert response.json() == {"subject": "prot-user", "email": "prot@example.com"}
