"""Environment-driven application settings (architecture.md §6)."""

from functools import lru_cache
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict

AuthProviderName = Literal["supabase", "clerk"]
OcrProviderName = Literal["mistral", "document_ai"]
LlmProviderName = Literal["gemini", "openai"]
StorageProviderName = Literal["r2"]
AppEnvName = Literal["local", "staging", "production"]


class Settings(BaseSettings):
    """All config is env-driven; never hardcode secrets or per-env values."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # Deployment stage — telemetry / log level only; never business-logic forks
    app_env: AppEnvName = "local"

    # Core infrastructure
    database_url: str = "postgresql+psycopg://lexivo:lexivo@localhost:5432/lexivo"
    redis_url: str = "redis://localhost:6379/0"
    celery_broker_url: str = "redis://localhost:6379/1"
    # Eager mode runs tasks in-process (CI / unit tests without Redis)
    celery_task_always_eager: bool = False

    # Observability (empty = no-op / stub for local + CI)
    sentry_dsn: str = ""
    posthog_api_key: str = ""
    posthog_host: str = ""

    # Adapter provider selectors (launch defaults)
    auth_provider: AuthProviderName = "supabase"
    ocr_provider: OcrProviderName = "mistral"
    llm_provider: LlmProviderName = "gemini"
    storage_provider: StorageProviderName = "r2"

    # Supabase Auth
    supabase_url: str = ""
    supabase_jwt_secret: str = ""
    supabase_anon_key: str = ""

    # Clerk (alternate auth)
    clerk_secret_key: str = ""
    clerk_jwks_url: str = ""

    # Cloudflare R2
    r2_account_id: str = ""
    r2_access_key_id: str = ""
    r2_secret_access_key: str = ""
    r2_bucket_name: str = ""
    r2_endpoint_url: str = ""

    # Gemini / OpenAI
    gemini_api_key: str = ""
    openai_api_key: str = ""

    # Mistral OCR / Document AI
    mistral_api_key: str = ""
    document_ai_project_id: str = ""
    document_ai_processor_id: str = ""
    document_ai_location: str = "us"

    # Subscription / free-tier quotas (OpenSpec subscription)
    # Paywall UI flag only — caps always enforce regardless of this flag.
    subscription_paywall_enabled: bool = False
    free_tier_docs_per_month: int = 20
    free_tier_chat_messages_per_day: int = 100
    free_tier_ocr_pages_per_month: int = 500


@lru_cache
def get_settings() -> Settings:
    return Settings()
