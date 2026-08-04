"""Document domain service — metadata, storage upload, status lifecycle."""

from __future__ import annotations

import uuid
from collections.abc import Callable
from typing import Any

from app.adapters.protocols import StorageProvider
from app.models import Document, DocumentStatus
from app.repositories.document_repo import DocumentRepository
from app.services.base import BaseService
from app.services.page_estimate import estimate_page_count
from app.services.quota_service import QuotaService

EnqueueFn = Callable[..., str | None]


class DocumentService(BaseService[Document]):
    def __init__(
        self,
        repository: DocumentRepository,
        storage: StorageProvider,
        enqueue_processing: EnqueueFn | None = None,
        quota: QuotaService | None = None,
    ) -> None:
        super().__init__(repository)
        self._documents = repository
        self._storage = storage
        # Wired to Celery enqueue_document_processing (OCR task unit)
        self._enqueue_processing = enqueue_processing
        self._quota = quota

    async def create_with_upload(
        self,
        *,
        user_id: str,
        title: str | None,
        file_bytes: bytes,
        filename: str,
    ) -> Document:
        if self._quota is not None:
            self._quota.enforce_document_create(user_id)
            # OCR pages checked before insert so over-cap never leaves an orphan row.
            estimate = estimate_page_count(file_bytes, filename)
            self._quota.enforce_ocr_pages(
                user_id=user_id,
                estimated_pages=estimate,
            )

        key = f"documents/{user_id}/{uuid.uuid4().hex}_{filename}"
        await self._storage.upload(key, file_bytes)
        document = self.create(
            {
                "user_id": user_id,
                "title": title,
                "storage_key": key,
                "status": DocumentStatus.processing,
            }
        )
        if self._enqueue_processing is not None:
            # OCR page quota already enforced above; enqueue signature stays
            # ``(document_id)`` for test doubles and Celery wiring.
            self._enqueue_processing(document.id)
        return document

    def list_for_user(
        self,
        user_id: str,
        status: DocumentStatus | None = None,
    ) -> list[Document]:
        filters: dict[str, Any] = {"user_id": user_id}
        if status is not None:
            filters["status"] = status
        return self.list(filters)

    def get_status(self, document_id: str) -> DocumentStatus:
        return self.get(document_id).status

    def mark_status(self, document_id: str, status: DocumentStatus) -> Document:
        return self.update(document_id, {"status": status})
