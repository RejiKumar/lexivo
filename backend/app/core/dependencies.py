"""FastAPI dependency providers for adapter Protocols."""

from fastapi import Depends

from app.adapters.protocols import (
    AuthProvider,
    LLMProvider,
    OCRProvider,
    StorageProvider,
)
from app.core.config import Settings, get_settings
from app.core.provider_factory import (
    build_auth_provider,
    build_llm_provider,
    build_ocr_provider,
    build_storage_provider,
)


def get_auth_provider(
    settings: Settings = Depends(get_settings),
) -> AuthProvider:
    return build_auth_provider(settings)


def get_storage_provider(
    settings: Settings = Depends(get_settings),
) -> StorageProvider:
    return build_storage_provider(settings)


def get_llm_provider(
    settings: Settings = Depends(get_settings),
) -> LLMProvider:
    return build_llm_provider(settings)


def get_ocr_provider(
    settings: Settings = Depends(get_settings),
) -> OCRProvider:
    return build_ocr_provider(settings)
