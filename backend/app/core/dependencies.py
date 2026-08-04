"""FastAPI dependency providers for adapter Protocols."""

from fastapi import Depends

from app.adapters.auth.stubs import ClerkAuthAdapter, SupabaseAuthAdapter
from app.adapters.llm.stubs import GeminiLLMAdapter, OpenAILLMAdapter
from app.adapters.ocr.stubs import DocAIAdapter, MistralOCRAdapter
from app.adapters.protocols import (
    AuthProvider,
    LLMProvider,
    OCRProvider,
    StorageProvider,
)
from app.adapters.storage.stubs import R2StorageAdapter
from app.core.config import Settings, get_settings


def get_auth_provider(
    settings: Settings = Depends(get_settings),
) -> AuthProvider:
    if settings.auth_provider == "clerk":
        return ClerkAuthAdapter()
    return SupabaseAuthAdapter()


def get_storage_provider(
    settings: Settings = Depends(get_settings),
) -> StorageProvider:
    if settings.storage_provider == "r2":
        return R2StorageAdapter()
    raise ValueError(f"Unsupported STORAGE_PROVIDER: {settings.storage_provider}")


def get_llm_provider(
    settings: Settings = Depends(get_settings),
) -> LLMProvider:
    if settings.llm_provider == "openai":
        return OpenAILLMAdapter()
    return GeminiLLMAdapter()


def get_ocr_provider(
    settings: Settings = Depends(get_settings),
) -> OCRProvider:
    if settings.ocr_provider == "document_ai":
        return DocAIAdapter()
    return MistralOCRAdapter()
