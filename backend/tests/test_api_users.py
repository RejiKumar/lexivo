"""API tests for thin users router via UserService."""

from fastapi.testclient import TestClient

from tests.conftest import make_auth_header


def test_get_and_update_current_user_profile(api_client: TestClient) -> None:
    headers = make_auth_header(
        sub="profile-user",
        email="profile@example.com",
        name="Profile User",
    )

    get_resp = api_client.get("/api/v1/users/me", headers=headers)
    assert get_resp.status_code == 200
    body = get_resp.json()
    assert body["external_id"] == "profile-user"
    assert body["email"] == "profile@example.com"
    user_id = body["id"]

    patch_resp = api_client.patch(
        "/api/v1/users/me",
        headers=headers,
        json={"display_name": "Updated Name"},
    )
    assert patch_resp.status_code == 200
    assert patch_resp.json()["display_name"] == "Updated Name"
    assert patch_resp.json()["id"] == user_id

    again = api_client.get("/api/v1/users/me", headers=headers)
    assert again.json()["display_name"] == "Updated Name"


def test_users_me_requires_auth(api_client: TestClient) -> None:
    assert api_client.get("/api/v1/users/me").status_code == 401
