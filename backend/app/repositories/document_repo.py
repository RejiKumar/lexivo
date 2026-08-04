"""Document table repository (SQL only)."""

from typing import Any

from app.models import Document, DocumentStatus
from app.repositories.base import BaseRepository


class DocumentRepository(BaseRepository[Document]):
    model = Document

    def create(
        self,
        *,
        user_id: str,
        title: str | None = None,
        storage_key: str | None = None,
        status: DocumentStatus = DocumentStatus.processing,
        **fields: Any,
    ) -> Document:
        return super().create(
            user_id=user_id,
            title=title,
            storage_key=storage_key,
            status=status,
            **fields,
        )
