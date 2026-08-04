"""Thin translation service — enqueue Master translation; never imports TranslationAgent."""

from __future__ import annotations

from collections.abc import Callable

from app.models import Document, DocumentStatus, TranslationStatus
from app.repositories.document_repo import DocumentRepository
from app.services.base import BaseService, ConflictError, NotFoundError, ValidationError

EnqueueTranslationFn = Callable[[str], str]

SUPPORTED_LANGS = frozenset({"en", "es", "fr", "de", "hi", "pt"})


def normalize_lang(value: str) -> str:
    code = value.strip().lower()
    if code not in SUPPORTED_LANGS:
        raise ValidationError(f"Unsupported language code: {value!r}")
    return code


def validate_language_pair(source_lang: str, target_lang: str) -> tuple[str, str]:
    source = normalize_lang(source_lang)
    target = normalize_lang(target_lang)
    if source == target:
        raise ValidationError("source_lang and target_lang must differ")
    if source != "en" and target != "en":
        raise ValidationError(
            "Unsupported language pair; v1 requires EN↔ES,FR,DE,HI,PT "
            "(English on one side)"
        )
    return source, target


class TranslationService(BaseService[Document]):
    """Enqueue translation for OCR-ready documents."""

    def __init__(
        self,
        repository: DocumentRepository,
        enqueue_translation: EnqueueTranslationFn | None = None,
    ) -> None:
        super().__init__(repository)
        self._documents = repository
        self._enqueue_translation = enqueue_translation

    def request_translation(
        self,
        *,
        document_id: str,
        user_id: str,
        source_lang: str,
        target_lang: str,
    ) -> Document:
        document = self._documents.get(document_id)
        if document is None or document.user_id != user_id:
            raise NotFoundError("Document not found")

        source, target = validate_language_pair(source_lang, target_lang)

        if document.status != DocumentStatus.ready:
            raise ConflictError(
                "Document OCR is not ready; translation requires status=ready"
            )
        text = (document.extracted_text or "").strip()
        if not text:
            raise ConflictError(
                "Document has no extracted text; complete OCR before translation"
            )

        if self._enqueue_translation is None:
            raise RuntimeError("Translation enqueue function is not configured")

        self._documents.update(
            document_id,
            translation_status=TranslationStatus.processing,
            source_lang=source,
            target_lang=target,
            translated_text=None,
        )
        self._enqueue_translation(document_id)
        refreshed = self._documents.get(document_id)
        if refreshed is None:
            raise NotFoundError("Document not found")
        return refreshed

    def get_translation_status(self, *, document_id: str, user_id: str) -> Document:
        document = self._documents.get(document_id)
        if document is None or document.user_id != user_id:
            raise NotFoundError("Document not found")
        return document
