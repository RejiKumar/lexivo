"""FastAPI dependency providers for adapter Protocols."""

from fastapi import Depends

from app.adapters.auth.clerk_adapter import ClerkAuthAdapter
from app.adapters.auth.supabase_adapter import SupabaseAuthAdapter
from app.adapters.llm.gemini_adapter import GeminiLLMAdapter
from app.adapters.llm.openai_adapter import OpenAILLMAdapter
from app.adapters.ocr.doc_ai_adapter import DocAIAdapter
from app.adapters.ocr.mistral_ocr_adapter import MistralOCRAdapter
from app.adapters.protocols import (
    AuthProvider,
    LLMProvider,
    OCRProvider,
    StorageProvider,
)
from app.adapters.storage.r2_adapter import R2StorageAdapter
from app.core.config import Settings, get_settings


def get_auth_provider(
    settings: Settings = Depends(get_settings),
) -> AuthProvider:
    if settings.auth_provider == "clerk":
        return ClerkAuthAdapter(secret_key=settings.clerk_secret_key)
    return SupabaseAuthAdapter(jwt_secret=settings.supabase_jwt_secret)


def get_storage_provider(
    settings: Settings = Depends(get_settings),
) -> StorageProvider:
    if settings.storage_provider == "r2":
        return R2StorageAdapter(
            endpoint_url=settings.r2_endpoint_url,
            access_key_id=settings.r2_access_key_id,
            secret_access_key=settings.r2_secret_access_key,
            bucket_name=settings.r2_bucket_name,
        )
    raise ValueError(f"Unsupported STORAGE_PROVIDER: {settings.storage_provider}")


def get_llm_provider(
    settings: Settings = Depends(get_settings),
) -> LLMProvider:
    if settings.llm_provider == "openai":
        return OpenAILLMAdapter(api_key=settings.openai_api_key)
    return GeminiLLMAdapter(api_key=settings.gemini_api_key)


def get_ocr_provider(
    settings: Settings = Depends(get_settings),
) -> OCRProvider:
    if settings.ocr_provider == "document_ai":
        return DocAIAdapter(
            project_id=settings.document_ai_project_id,
            processor_id=settings.document_ai_processor_id,
            location=settings.document_ai_location,
        )
    return MistralOCRAdapter(api_key=settings.mistral_api_key)
