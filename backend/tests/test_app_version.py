"""Tests for GET /api/v1/app/version (soft / force upgrade policy)."""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from app.core.config import Settings, get_settings
from app.main import create_app

_REQUIRED_ROOT_FIELDS = {
    "latest_version",
    "min_supported_version",
    "soft_update_message",
    "force_update_message",
    "android",
    "ios",
    "web",
}
_REQUIRED_PLATFORM_FIELDS = {
    "latest_version",
    "min_supported_version",
    "store_url",
}
_REQUIRED_WEB_FIELDS = {"latest_version", "min_supported_version"}


@pytest.fixture(autouse=True)
def _clear_settings_cache() -> None:
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


def test_app_version_defaults_happy_path(api_client: TestClient) -> None:
    res = api_client.get("/api/v1/app/version")
    assert res.status_code == 200
    data = res.json()
    assert _REQUIRED_ROOT_FIELDS <= data.keys()
    assert data["latest_version"] == "1.0.0"
    assert data["min_supported_version"] == "1.0.0"
    assert isinstance(data["soft_update_message"], str) and data["soft_update_message"]
    assert isinstance(data["force_update_message"], str) and data["force_update_message"]
    assert _REQUIRED_PLATFORM_FIELDS <= data["android"].keys()
    assert _REQUIRED_PLATFORM_FIELDS <= data["ios"].keys()
    assert _REQUIRED_WEB_FIELDS <= data["web"].keys()
    assert "store_url" not in data["web"]
    for platform in ("android", "ios", "web"):
        assert data[platform]["latest_version"] == "1.0.0"
        assert data[platform]["min_supported_version"] == "1.0.0"


def test_app_version_unauthenticated(api_client: TestClient) -> None:
    """Pre-login force-update must work without Authorization."""
    res = api_client.get("/api/v1/app/version")
    assert res.status_code == 200


def test_app_version_env_overrides(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("LATEST_APP_VERSION", "2.0.0")
    monkeypatch.setenv("MIN_SUPPORTED_APP_VERSION", "1.5.0")
    monkeypatch.setenv("SOFT_UPDATE_MESSAGE", "Please soft-update.")
    monkeypatch.setenv("FORCE_UPDATE_MESSAGE", "Please force-update.")
    monkeypatch.setenv("ANDROID_LATEST_APP_VERSION", "2.1.0")
    monkeypatch.setenv("ANDROID_MIN_SUPPORTED_APP_VERSION", "1.6.0")
    monkeypatch.setenv(
        "ANDROID_STORE_URL",
        "https://play.google.com/store/apps/details?id=com.lexivo.lexivo",
    )
    monkeypatch.setenv("IOS_STORE_URL", "https://apps.apple.com/app/id123")
    monkeypatch.setenv("WEB_LATEST_APP_VERSION", "2.0.1")

    get_settings.cache_clear()
    app = create_app()
    with TestClient(app) as client:
        res = client.get("/api/v1/app/version")

    assert res.status_code == 200
    data = res.json()
    assert data["latest_version"] == "2.0.0"
    assert data["min_supported_version"] == "1.5.0"
    assert data["soft_update_message"] == "Please soft-update."
    assert data["force_update_message"] == "Please force-update."
    assert data["android"]["latest_version"] == "2.1.0"
    assert data["android"]["min_supported_version"] == "1.6.0"
    assert data["android"]["store_url"].endswith("com.lexivo.lexivo")
    assert data["ios"]["latest_version"] == "2.0.0"  # falls back to global
    assert data["ios"]["store_url"] == "https://apps.apple.com/app/id123"
    assert data["web"]["latest_version"] == "2.0.1"
    assert data["web"]["min_supported_version"] == "1.5.0"


def test_app_version_settings_defaults(monkeypatch: pytest.MonkeyPatch) -> None:
    for key in (
        "LATEST_APP_VERSION",
        "MIN_SUPPORTED_APP_VERSION",
        "SOFT_UPDATE_MESSAGE",
        "FORCE_UPDATE_MESSAGE",
        "ANDROID_LATEST_APP_VERSION",
        "ANDROID_MIN_SUPPORTED_APP_VERSION",
        "ANDROID_STORE_URL",
        "IOS_LATEST_APP_VERSION",
        "IOS_MIN_SUPPORTED_APP_VERSION",
        "IOS_STORE_URL",
        "WEB_LATEST_APP_VERSION",
        "WEB_MIN_SUPPORTED_APP_VERSION",
    ):
        monkeypatch.delenv(key, raising=False)

    settings = Settings()
    assert settings.latest_app_version == "1.0.0"
    assert settings.min_supported_app_version == "1.0.0"
    assert settings.android_store_url == ""
    assert settings.ios_store_url == ""


def test_openapi_includes_app_version(api_client: TestClient) -> None:
    schema = api_client.get("/openapi.json").json()
    assert "/api/v1/app/version" in schema["paths"]
    components = schema.get("components", {}).get("schemas", {})
    assert "AppVersionResponse" in components
