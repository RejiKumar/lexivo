"""Unit tests for adapter DI bindings (defaults + selector swaps)."""

import pytest

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
from app.core.dependencies import (
    get_auth_provider,
    get_llm_provider,
    get_ocr_provider,
    get_storage_provider,
)


@pytest.fixture(autouse=True)
def _clear_settings_cache() -> None:
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


def test_default_bindings_resolve_to_launch_adapters() -> None:
    settings = Settings(
        auth_provider="supabase",
        storage_provider="r2",
        llm_provider="gemini",
        ocr_provider="mistral",
    )

    auth = get_auth_provider(settings)
    storage = get_storage_provider(settings)
    llm = get_llm_provider(settings)
    ocr = get_ocr_provider(settings)

    assert isinstance(auth, SupabaseAuthAdapter)
    assert isinstance(storage, R2StorageAdapter)
    assert isinstance(llm, GeminiLLMAdapter)
    assert isinstance(ocr, MistralOCRAdapter)

    assert isinstance(auth, AuthProvider)
    assert isinstance(storage, StorageProvider)
    assert isinstance(llm, LLMProvider)
    assert isinstance(ocr, OCRProvider)


def test_alternate_bindings_resolve_via_selectors() -> None:
    settings = Settings(
        auth_provider="clerk",
        storage_provider="r2",
        llm_provider="openai",
        ocr_provider="document_ai",
    )

    assert isinstance(get_auth_provider(settings), ClerkAuthAdapter)
    assert isinstance(get_storage_provider(settings), R2StorageAdapter)
    assert isinstance(get_llm_provider(settings), OpenAILLMAdapter)
    assert isinstance(get_ocr_provider(settings), DocAIAdapter)


def test_default_settings_env_selectors_match_launch_bindings(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    for key in ("AUTH_PROVIDER", "OCR_PROVIDER", "LLM_PROVIDER", "STORAGE_PROVIDER"):
        monkeypatch.delenv(key, raising=False)

    settings = Settings()
    assert isinstance(get_auth_provider(settings), SupabaseAuthAdapter)
    assert isinstance(get_storage_provider(settings), R2StorageAdapter)
    assert isinstance(get_llm_provider(settings), GeminiLLMAdapter)
    assert isinstance(get_ocr_provider(settings), MistralOCRAdapter)
