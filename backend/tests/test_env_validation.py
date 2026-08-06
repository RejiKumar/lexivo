"""Tests for masked env validation helpers."""

from __future__ import annotations

import logging

import pytest

from app.core.config import Settings
from app.core.env_validation import (
    core_env_keys,
    feature_env_keys,
    log_startup_config,
    mask_secret,
    required_env_keys,
    validate_settings_or_raise,
)


def test_mask_secret_hides_prefix() -> None:
    assert mask_secret("abcdefghijklmnop") == "************mnop"
    assert mask_secret("") == "(not set)"
    assert mask_secret("ab") == "**"


def test_required_env_keys_lists_missing_for_default_providers() -> None:
    settings = Settings(
        storage_provider="r2",
        supabase_url="",
        supabase_anon_key="",
        supabase_jwt_secret="",
        gemini_api_key="",
        mistral_api_key="",
        r2_account_id="",
        r2_access_key_id="",
        r2_secret_access_key="",
        r2_bucket_name="",
        r2_endpoint_url="",
    )
    missing = required_env_keys(settings)
    assert "SUPABASE_URL" in missing
    assert "SUPABASE_ANON_KEY" in missing
    # JWKS verification covers projects without a legacy HS256 secret.
    assert "SUPABASE_JWT_SECRET" not in missing
    assert "GEMINI_API_KEY" in missing
    assert "MISTRAL_API_KEY" in missing
    assert "R2_BUCKET_NAME" in missing


def test_required_env_keys_empty_when_complete() -> None:
    settings = Settings(
        storage_provider="r2",
        supabase_url="https://example.supabase.co",
        supabase_anon_key="anon-test-key-value",
        supabase_jwt_secret="jwt-test-secret-value-32chars!",
        gemini_api_key="gemini-test-key-value",
        mistral_api_key="mistral-test-key-value",
        r2_account_id="acct123456",
        r2_access_key_id="akid-test-value",
        r2_secret_access_key="sk-test-value",
        r2_bucket_name="lexivo",
        r2_endpoint_url="https://example.r2.cloudflarestorage.com",
    )
    assert required_env_keys(settings) == []


def test_supabase_storage_feature_keys() -> None:
    settings = Settings(
        storage_provider="supabase",
        supabase_url="https://example.supabase.co",
        supabase_service_role_key="",
        supabase_storage_bucket="",
    )
    features = feature_env_keys(settings)
    missing = features["document storage / uploads (Supabase)"]
    assert "SUPABASE_SERVICE_ROLE_KEY" in missing
    assert "SUPABASE_STORAGE_BUCKET" in missing
    assert "R2_BUCKET_NAME" not in str(features)


def test_validate_raises_when_core_auth_config_missing(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.delenv("LEXIVO_SKIP_ENV_VALIDATION", raising=False)
    monkeypatch.delenv("LEXIVO_STRICT_ENV", raising=False)
    settings = Settings(
        supabase_url="",
        supabase_anon_key="",
        supabase_jwt_secret="",
    )
    with pytest.raises(RuntimeError, match="SUPABASE_URL"):
        validate_settings_or_raise(settings)


def test_local_boots_with_missing_provider_keys(
    monkeypatch: pytest.MonkeyPatch,
    caplog: pytest.LogCaptureFixture,
) -> None:
    monkeypatch.delenv("LEXIVO_SKIP_ENV_VALIDATION", raising=False)
    monkeypatch.delenv("LEXIVO_STRICT_ENV", raising=False)
    settings = Settings(
        app_env="local",
        storage_provider="r2",
        supabase_url="https://example.supabase.co",
        supabase_anon_key="anon-test-key-value",
        supabase_jwt_secret="jwt-test-secret-value-32chars!",
        gemini_api_key="gemini-test-key-value",
        mistral_api_key="",
        r2_account_id="",
    )
    with caplog.at_level(logging.WARNING):
        validate_settings_or_raise(settings)
    joined = "\n".join(r.getMessage() for r in caplog.records)
    assert "MISTRAL_API_KEY" in joined
    assert "R2_ACCOUNT_ID" in joined


def test_deployed_stage_requires_provider_keys(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.delenv("LEXIVO_SKIP_ENV_VALIDATION", raising=False)
    monkeypatch.delenv("LEXIVO_STRICT_ENV", raising=False)
    settings = Settings(
        app_env="production",
        supabase_url="https://example.supabase.co",
        supabase_anon_key="anon-test-key-value",
        supabase_jwt_secret="jwt-test-secret-value-32chars!",
        mistral_api_key="",
    )
    with pytest.raises(RuntimeError, match="MISTRAL_API_KEY"):
        validate_settings_or_raise(settings)


def test_core_and_feature_key_split() -> None:
    settings = Settings(
        storage_provider="r2",
        supabase_url="",
        mistral_api_key="",
        r2_account_id="acct",
        r2_access_key_id="key",
        r2_secret_access_key="secret",
        r2_bucket_name="lexivo",
        r2_endpoint_url="https://example.r2.cloudflarestorage.com",
    )
    assert "SUPABASE_URL" in core_env_keys(settings)
    assert "SUPABASE_URL" not in str(feature_env_keys(settings))
    assert any("MISTRAL_API_KEY" in keys for keys in feature_env_keys(settings).values())


def test_validate_skipped_when_flag_set(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("LEXIVO_SKIP_ENV_VALIDATION", "1")
    settings = Settings(supabase_url="", gemini_api_key="")
    validate_settings_or_raise(settings)  # does not raise


def test_log_startup_config_never_prints_raw_secret(
    caplog: pytest.LogCaptureFixture,
) -> None:
    secret = "super-secret-gemini-key-xyz"
    settings = Settings(
        gemini_api_key=secret,
        mistral_api_key="mistral-secret-abc",
        supabase_anon_key="anon-secret-def",
        supabase_url="https://example.supabase.co",
        llm_provider="gemini",
        ocr_provider="mistral",
    )
    with caplog.at_level(logging.INFO):
        log_startup_config(settings)
    joined = "\n".join(r.message for r in caplog.records)
    assert secret not in joined
    assert "mistral-secret-abc" not in joined
    assert "anon-secret-def" not in joined
    assert "LLM provider: gemini" in joined
    assert "OCR provider: mistral" in joined
    assert "****xyz" in joined or "************xyz" in joined or mask_secret(secret) in joined
