"""Optional Protocol overrides for Celery tasks (tests / DI without FastAPI)."""

from __future__ import annotations

from app.adapters.protocols import OCRProvider, StorageProvider
from app.core.provider_factory import build_ocr_provider, build_storage_provider

_ocr_override: OCRProvider | None = None
_storage_override: StorageProvider | None = None


def set_task_provider_overrides(
    *,
    ocr: OCRProvider | None = None,
    storage: StorageProvider | None = None,
) -> None:
    global _ocr_override, _storage_override
    if ocr is not None:
        _ocr_override = ocr
    if storage is not None:
        _storage_override = storage


def clear_task_provider_overrides() -> None:
    global _ocr_override, _storage_override
    _ocr_override = None
    _storage_override = None


def get_task_ocr_provider() -> OCRProvider:
    if _ocr_override is not None:
        return _ocr_override
    return build_ocr_provider()


def get_task_storage_provider() -> StorageProvider:
    if _storage_override is not None:
        return _storage_override
    return build_storage_provider()
