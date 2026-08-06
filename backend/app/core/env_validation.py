"""Startup env validation and masked config logging (never print secrets)."""

from __future__ import annotations

import logging
import os

from app.core.config import Settings

logger = logging.getLogger(__name__)

_PLACEHOLDER_VALUES = frozenset(
    {
        "",
        "changeme",
        "your-key",
        "your_key",
        "replace-me",
        "gemini-api-key",
        "mistral-api-key",
        "sk-...",
    }
)


def mask_secret(value: str, *, visible: int = 4) -> str:
    """Mask a secret for debug logs; never return the full value."""
    raw = (value or "").strip()
    if not raw:
        return "(not set)"
    if len(raw) <= visible:
        return "*" * len(raw)
    return ("*" * (len(raw) - visible)) + raw[-visible:]


def _is_missing(value: str) -> bool:
    stripped = (value or "").strip()
    if not stripped:
        return True
    return stripped.lower() in _PLACEHOLDER_VALUES


def core_env_keys(settings: Settings) -> list[str]:
    """Missing vars the API cannot boot without (DB + auth)."""
    missing: list[str] = []

    if _is_missing(settings.database_url):
        missing.append("DATABASE_URL")

    if settings.auth_provider == "supabase":
        # SUPABASE_JWT_SECRET is optional: projects on JWT signing keys issue
        # asymmetric tokens verified through the project JWKS (derived from URL).
        if _is_missing(settings.supabase_url):
            missing.append("SUPABASE_URL")
        if _is_missing(settings.supabase_anon_key):
            missing.append("SUPABASE_ANON_KEY")

    return missing


def feature_env_keys(settings: Settings) -> dict[str, list[str]]:
    """Missing vars per optional feature, keyed by the feature they disable."""
    features: dict[str, list[str]] = {}

    if settings.storage_provider == "r2":
        storage = [
            name
            for name, value in (
                ("R2_ACCOUNT_ID", settings.r2_account_id),
                ("R2_ACCESS_KEY_ID", settings.r2_access_key_id),
                ("R2_SECRET_ACCESS_KEY", settings.r2_secret_access_key),
                ("R2_BUCKET_NAME", settings.r2_bucket_name),
                ("R2_ENDPOINT_URL", settings.r2_endpoint_url),
            )
            if _is_missing(value)
        ]
        if storage:
            features["document storage / uploads (R2)"] = storage
    elif settings.storage_provider == "supabase":
        storage = [
            name
            for name, value in (
                ("SUPABASE_URL", settings.supabase_url),
                ("SUPABASE_SERVICE_ROLE_KEY", settings.supabase_service_role_key),
                ("SUPABASE_STORAGE_BUCKET", settings.supabase_storage_bucket),
            )
            if _is_missing(value)
        ]
        if storage:
            features["document storage / uploads (Supabase)"] = storage

    if settings.llm_provider == "gemini" and _is_missing(settings.gemini_api_key):
        features["summary / translation / RAG chat (Gemini)"] = ["GEMINI_API_KEY"]
    elif settings.llm_provider == "openai" and _is_missing(settings.openai_api_key):
        features["summary / translation / RAG chat (OpenAI)"] = ["OPENAI_API_KEY"]

    if settings.ocr_provider == "mistral" and _is_missing(settings.mistral_api_key):
        features["OCR (Mistral)"] = ["MISTRAL_API_KEY"]
    elif settings.ocr_provider == "document_ai":
        doc_ai = [
            name
            for name, value in (
                ("DOCUMENT_AI_PROJECT_ID", settings.document_ai_project_id),
                ("DOCUMENT_AI_PROCESSOR_ID", settings.document_ai_processor_id),
            )
            if _is_missing(value)
        ]
        if doc_ai:
            features["OCR (Document AI)"] = doc_ai

    return features


def required_env_keys(settings: Settings) -> list[str]:
    """All missing vars needed for the full feature set (core + providers)."""
    missing = core_env_keys(settings)
    for keys in feature_env_keys(settings).values():
        missing.extend(keys)
    return missing


def skip_env_validation() -> bool:
    """Tests / CI can set LEXIVO_SKIP_ENV_VALIDATION=1 to skip strict checks."""
    return os.environ.get("LEXIVO_SKIP_ENV_VALIDATION", "").strip().lower() in {
        "1",
        "true",
        "yes",
    }


def strict_env_validation(settings: Settings) -> bool:
    """Deployed stages require every provider key; local may run partially configured.

    Force strict local runs with ``LEXIVO_STRICT_ENV=1``.
    """
    override = os.environ.get("LEXIVO_STRICT_ENV", "").strip().lower()
    if override in {"1", "true", "yes"}:
        return True
    if override in {"0", "false", "no"}:
        return False
    return settings.app_env != "local"


def log_startup_config(settings: Settings) -> None:
    """Log enabled providers and masked secrets — never full key material."""
    logger.info("=== Lexivo backend startup config ===")
    logger.info("APP_ENV: %s", settings.app_env)
    logger.info("Auth provider: %s", settings.auth_provider)
    logger.info("LLM provider: %s", settings.llm_provider)
    logger.info("OCR provider: %s", settings.ocr_provider)
    logger.info("Storage provider: %s", settings.storage_provider)
    logger.info("Celery eager: %s", settings.celery_task_always_eager)
    logger.info("Supabase URL: %s", settings.supabase_url or "(not set)")
    logger.info("Supabase anon key: %s", mask_secret(settings.supabase_anon_key))
    logger.info(
        "Supabase service role key: %s",
        mask_secret(settings.supabase_service_role_key),
    )
    logger.info(
        "Supabase JWT secret (legacy HS256 only): %s",
        mask_secret(settings.supabase_jwt_secret),
    )
    logger.info(
        "Supabase storage bucket: %s",
        settings.supabase_storage_bucket or "(not set)",
    )
    logger.info("Gemini API key: %s", mask_secret(settings.gemini_api_key))
    logger.info("Mistral API key: %s", mask_secret(settings.mistral_api_key))
    logger.info("R2 account id: %s", mask_secret(settings.r2_account_id, visible=6))
    logger.info("R2 access key: %s", mask_secret(settings.r2_access_key_id))
    logger.info("R2 secret key: %s", mask_secret(settings.r2_secret_access_key))
    logger.info("R2 bucket: %s", settings.r2_bucket_name or "(not set)")
    logger.info("R2 endpoint: %s", settings.r2_endpoint_url or "(not set)")
    logger.info(
        "Sentry: %s",
        "enabled" if (settings.sentry_dsn or "").strip() else "disabled",
    )
    logger.info(
        "PostHog: %s",
        "enabled" if (settings.posthog_api_key or "").strip() else "disabled",
    )
    logger.info("=====================================")


def validate_settings_or_raise(settings: Settings) -> None:
    """Fail fast on core config; warn about provider keys unless running strict."""
    if skip_env_validation():
        logger.warning(
            "LEXIVO_SKIP_ENV_VALIDATION set — skipping env checks (tests/CI only)."
        )
        return

    strict = strict_env_validation(settings)
    core_missing = core_env_keys(settings)
    features_missing = feature_env_keys(settings)

    blocking = list(core_missing)
    if strict:
        for keys in features_missing.values():
            blocking.extend(keys)

    if blocking:
        raise RuntimeError(
            "Missing required environment variables for Lexivo API: "
            f"{', '.join(blocking)}. "
            "Copy backend/.env.example → backend/.env, fill in your keys, "
            "and restart. See README.md (Local environment). "
            "Secrets are never printed."
        )

    for feature, keys in features_missing.items():
        logger.warning(
            "%s disabled - missing %s. Add the keys to backend/.env to enable it.",
            feature,
            ", ".join(keys),
        )
