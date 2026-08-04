"""Optional Protocol overrides for Celery tasks (tests / DI without FastAPI)."""

from __future__ import annotations

from app.adapters.protocols import LLMProvider, OCRProvider, StorageProvider
from app.core.provider_factory import (
    build_llm_provider,
    build_ocr_provider,
    build_storage_provider,
)
from app.rag.embedder import EmbeddingProvider

_ocr_override: OCRProvider | None = None
_storage_override: StorageProvider | None = None
_embedding_override: EmbeddingProvider | None = None
_llm_override: LLMProvider | None = None


def set_task_provider_overrides(
    *,
    ocr: OCRProvider | None = None,
    storage: StorageProvider | None = None,
    embedding: EmbeddingProvider | None = None,
    llm: LLMProvider | None = None,
) -> None:
    global _ocr_override, _storage_override, _embedding_override, _llm_override
    if ocr is not None:
        _ocr_override = ocr
    if storage is not None:
        _storage_override = storage
    if embedding is not None:
        _embedding_override = embedding
    if llm is not None:
        _llm_override = llm


def clear_task_provider_overrides() -> None:
    global _ocr_override, _storage_override, _embedding_override, _llm_override
    _ocr_override = None
    _storage_override = None
    _embedding_override = None
    _llm_override = None


def get_task_ocr_provider() -> OCRProvider:
    if _ocr_override is not None:
        return _ocr_override
    return build_ocr_provider()


def get_task_storage_provider() -> StorageProvider:
    if _storage_override is not None:
        return _storage_override
    return build_storage_provider()


def get_task_llm_provider() -> LLMProvider:
    if _llm_override is not None:
        return _llm_override
    return build_llm_provider()


def get_task_embedding_provider() -> EmbeddingProvider:
    """Return override or raise — real embedding adapter lands in a later binding step."""
    if _embedding_override is not None:
        return _embedding_override
    raise RuntimeError(
        "No EmbeddingProvider configured. Set task override (tests) or wire a "
        "real adapter via DI before calling generate_embeddings."
    )
