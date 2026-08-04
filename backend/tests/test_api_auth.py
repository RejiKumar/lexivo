"""API tests for thin auth router (AuthProvider-backed /me)."""

from fastapi.testclient import TestClient

from tests.conftest import make_auth_header


def test_auth_me_unauthorized_without_token(api_client: TestClient) -> None:
    assert api_client.get("/api/v1/auth/me").status_code == 401


def test_auth_me_returns_identity_payload(api_client: TestClient) -> None:
    response = api_client.get(
        "/api/v1/auth/me",
        headers=make_auth_header(sub="auth-user", email="auth@example.com"),
    )
    assert response.status_code == 200
    assert response.json() == {
        "subject": "auth-user",
        "email": "auth@example.com",
        "display_name": None,
    }
