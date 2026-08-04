"""Thin summary service — enqueue Master summary; never imports SummaryAgent."""

from __future__ import annotations

from collections.abc import Callable

from app.models import Document, DocumentStatus, SummaryStatus
from app.repositories.document_repo import DocumentRepository
from app.services.base import BaseService, ConflictError, NotFoundError

EnqueueSummaryFn = Callable[[str], str]


class SummaryService(BaseService[Document]):
    """Enqueue summarization for OCR-ready documents."""

    def __init__(
        self,
        repository: DocumentRepository,
        enqueue_summary: EnqueueSummaryFn | None = None,
    ) -> None:
        super().__init__(repository)
        self._documents = repository
        self._enqueue_summary = enqueue_summary

    def request_summary(self, *, document_id: str, user_id: str) -> Document:
        document = self._documents.get(document_id)
        if document is None or document.user_id != user_id:
            raise NotFoundError("Document not found")

        if document.status != DocumentStatus.ready:
            raise ConflictError(
                "Document OCR is not ready; summarization requires status=ready"
            )
        text = (document.extracted_text or "").strip()
        if not text:
            raise ConflictError(
                "Document has no extracted text; complete OCR before summarization"
            )

        if self._enqueue_summary is None:
            raise RuntimeError("Summary enqueue function is not configured")

        self._documents.update(
            document_id,
            summary_status=SummaryStatus.processing,
            short_summary=None,
            detailed_summary=None,
        )
        self._enqueue_summary(document_id)
        refreshed = self._documents.get(document_id)
        if refreshed is None:
            raise NotFoundError("Document not found")
        return refreshed

    def get_summary_status(self, *, document_id: str, user_id: str) -> Document:
        document = self._documents.get(document_id)
        if document is None or document.user_id != user_id:
            raise NotFoundError("Document not found")
        return document
