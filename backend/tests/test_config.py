"""Unit tests for environment-driven Settings (pydantic-settings)."""

import os

import pytest

from app.core.config import Settings, get_settings


@pytest.fixture(autouse=True)
def _clear_settings_cache() -> None:
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


def test_settings_loads_core_urls_from_env(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv(
        "DATABASE_URL",
        "postgresql+psycopg://lexivo:lexivo@localhost:5432/lexivo",
    )
    monkeypatch.setenv("REDIS_URL", "redis://localhost:6379/0")
    monkeypatch.setenv("CELERY_BROKER_URL", "redis://localhost:6379/1")

    settings = Settings()

    assert settings.database_url.endswith("/lexivo")
    assert settings.redis_url == "redis://localhost:6379/0"
    assert settings.celery_broker_url == "redis://localhost:6379/1"


def test_settings_loads_provider_secrets_from_env(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("SUPABASE_URL", "https://example.supabase.co")
    monkeypatch.setenv("SUPABASE_JWT_SECRET", "test-jwt-secret")
    monkeypatch.setenv("R2_ACCOUNT_ID", "acct")
    monkeypatch.setenv("R2_ACCESS_KEY_ID", "key")
    monkeypatch.setenv("R2_SECRET_ACCESS_KEY", "secret")
    monkeypatch.setenv("R2_BUCKET_NAME", "lexivo")
    monkeypatch.setenv("GEMINI_API_KEY", "gemini-key")
    monkeypatch.setenv("MISTRAL_API_KEY", "mistral-key")

    settings = Settings()

    assert settings.supabase_url == "https://example.supabase.co"
    assert settings.supabase_jwt_secret == "test-jwt-secret"
    assert settings.r2_account_id == "acct"
    assert settings.r2_access_key_id == "key"
    assert settings.r2_secret_access_key == "secret"
    assert settings.r2_bucket_name == "lexivo"
    assert settings.gemini_api_key == "gemini-key"
    assert settings.mistral_api_key == "mistral-key"


def test_provider_selectors_default_to_launch_bindings(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    for key in (
        "AUTH_PROVIDER",
        "OCR_PROVIDER",
        "LLM_PROVIDER",
        "STORAGE_PROVIDER",
    ):
        monkeypatch.delenv(key, raising=False)

    # Ignore backend/.env so this asserts field defaults, not the developer's local file.
    settings = Settings(_env_file=None)

    assert settings.auth_provider == "supabase"
    assert settings.ocr_provider == "mistral"
    assert settings.llm_provider == "gemini"
    assert settings.storage_provider == "r2"


def test_provider_selectors_can_be_overridden(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("AUTH_PROVIDER", "clerk")
    monkeypatch.setenv("OCR_PROVIDER", "document_ai")
    monkeypatch.setenv("LLM_PROVIDER", "openai")
    monkeypatch.setenv("STORAGE_PROVIDER", "supabase")
    monkeypatch.setenv("SUPABASE_SERVICE_ROLE_KEY", "service-role-test")
    monkeypatch.setenv("SUPABASE_STORAGE_BUCKET", "lexivo-dev")

    settings = Settings()

    assert settings.auth_provider == "clerk"
    assert settings.ocr_provider == "document_ai"
    assert settings.llm_provider == "openai"
    assert settings.storage_provider == "supabase"
    assert settings.supabase_service_role_key == "service-role-test"
    assert settings.supabase_storage_bucket == "lexivo-dev"


def test_get_settings_reads_os_environ(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("DATABASE_URL", "postgresql+psycopg://u:p@db:5432/app")
    monkeypatch.setenv("AUTH_PROVIDER", "clerk")

    settings = get_settings()

    assert "db:5432" in settings.database_url
    assert settings.auth_provider == "clerk"
    # Ensure we did not bake secrets into source
    assert "test-jwt-secret" not in open(
        os.path.join(os.path.dirname(__file__), "..", "app", "core", "config.py"),
        encoding="utf-8",
    ).read()
