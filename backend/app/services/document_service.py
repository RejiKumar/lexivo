"""Document domain service — metadata, storage upload, status lifecycle."""

from __future__ import annotations

import uuid
from collections.abc import Callable
from typing import Any

from app.adapters.protocols import StorageProvider
from app.models import Document, DocumentStatus
from app.repositories.document_repo import DocumentRepository
from app.services.base import BaseService

EnqueueFn = Callable[[str], None]


class DocumentService(BaseService[Document]):
    def __init__(
        self,
        repository: DocumentRepository,
        storage: StorageProvider,
        enqueue_processing: EnqueueFn | None = None,
    ) -> None:
        super().__init__(repository)
        self._documents = repository
        self._storage = storage
        # Stubbed until Celery task units land in §9
        self._enqueue_processing = enqueue_processing

    async def create_with_upload(
        self,
        *,
        user_id: str,
        title: str | None,
        file_bytes: bytes,
        filename: str,
    ) -> Document:
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
