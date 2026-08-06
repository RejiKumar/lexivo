"""Build adapter Protocol implementations from Settings (usable outside FastAPI)."""

from __future__ import annotations

from app.adapters.analytics.posthog import PostHogAnalyticsProvider
from app.adapters.analytics.stub import StubAnalyticsProvider
from app.adapters.auth.clerk_adapter import ClerkAuthAdapter
from app.adapters.auth.supabase_adapter import SupabaseAuthAdapter, jwks_url_for
from app.adapters.llm.gemini_adapter import GeminiLLMAdapter
from app.adapters.llm.openai_adapter import OpenAILLMAdapter
from app.adapters.ocr.doc_ai_adapter import DocAIAdapter
from app.adapters.ocr.mistral_ocr_adapter import MistralOCRAdapter
from app.adapters.protocols import (
    AnalyticsProvider,
    AuthProvider,
    LLMProvider,
    OCRProvider,
    StorageProvider,
)
from app.adapters.storage.r2_adapter import R2StorageAdapter
from app.adapters.storage.supabase_adapter import SupabaseStorageAdapter
from app.core.config import Settings, get_settings


def build_auth_provider(settings: Settings | None = None) -> AuthProvider:
    cfg = settings or get_settings()
    if cfg.auth_provider == "clerk":
        return ClerkAuthAdapter(secret_key=cfg.clerk_secret_key)
    return SupabaseAuthAdapter(
        jwt_secret=cfg.supabase_jwt_secret,
        jwks_url=jwks_url_for(cfg.supabase_url),
    )


def build_storage_provider(settings: Settings | None = None) -> StorageProvider:
    cfg = settings or get_settings()
    if cfg.storage_provider == "r2":
        return R2StorageAdapter(
            endpoint_url=cfg.r2_endpoint_url,
            access_key_id=cfg.r2_access_key_id,
            secret_access_key=cfg.r2_secret_access_key,
            bucket_name=cfg.r2_bucket_name,
        )
    if cfg.storage_provider == "supabase":
        return SupabaseStorageAdapter(
            supabase_url=cfg.supabase_url,
            service_role_key=cfg.supabase_service_role_key,
            bucket_name=cfg.supabase_storage_bucket,
        )
    raise ValueError(f"Unsupported STORAGE_PROVIDER: {cfg.storage_provider}")


def build_llm_provider(settings: Settings | None = None) -> LLMProvider:
    cfg = settings or get_settings()
    if cfg.llm_provider == "openai":
        return OpenAILLMAdapter(api_key=cfg.openai_api_key)
    return GeminiLLMAdapter(api_key=cfg.gemini_api_key)


def build_ocr_provider(settings: Settings | None = None) -> OCRProvider:
    cfg = settings or get_settings()
    if cfg.ocr_provider == "document_ai":
        return DocAIAdapter(
            project_id=cfg.document_ai_project_id,
            processor_id=cfg.document_ai_processor_id,
            location=cfg.document_ai_location,
        )
    return MistralOCRAdapter(api_key=cfg.mistral_api_key)


def build_analytics_provider(settings: Settings | None = None) -> AnalyticsProvider:
    """Stub when PostHog key empty; real adapter when set (SDK only in adapter)."""
    cfg = settings or get_settings()
    key = (cfg.posthog_api_key or "").strip()
    if not key:
        return StubAnalyticsProvider()
    return PostHogAnalyticsProvider(api_key=key, host=cfg.posthog_host)
