"""Thin summary service — enqueue Master summary; never imports SummaryAgent."""

from __future__ import annotations

import logging
from collections.abc import Callable

from app.models import Document, DocumentStatus, SummaryStatus
from app.prompts import prompt_loader
from app.repositories.document_repo import DocumentRepository
from app.services.base import BaseService, ConflictError, NotFoundError

logger = logging.getLogger(__name__)

EnqueueSummaryFn = Callable[[str], str]

SUMMARY_PROMPT_NAME = "summary"
SUMMARY_PROMPT_VERSION = "v1"


def current_summary_prompt_version() -> str:
    """Active summary template version used for cache keys."""
    return prompt_loader.load(
        SUMMARY_PROMPT_NAME, version=SUMMARY_PROMPT_VERSION
    ).version


def has_fresh_cached_summary(document: Document) -> bool:
    """True when a ready summary already exists for the current prompt version."""
    if document.summary_status != SummaryStatus.ready:
        return False
    if not (document.short_summary or "").strip():
        return False
    if not (document.detailed_summary or "").strip():
        return False
    cached_version = (document.summary_prompt_version or "").strip()
    if not cached_version:
        # Legacy rows (pre-version column) — treat ready text as current-version cache.
        return True
    return cached_version == current_summary_prompt_version()


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

        if has_fresh_cached_summary(document):
            logger.info(
                "Skipping summary LLM for document=%s (cached prompt_version=%s)",
                document_id,
                document.summary_prompt_version or current_summary_prompt_version(),
            )
            return document

        if self._enqueue_summary is None:
            raise RuntimeError("Summary enqueue function is not configured")

        self._documents.update(
            document_id,
            summary_status=SummaryStatus.processing,
            short_summary=None,
            detailed_summary=None,
            summary_prompt_version=None,
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
