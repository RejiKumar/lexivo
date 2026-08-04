"""Thin export service — enqueue Master export; never imports the export specialist."""

from __future__ import annotations

from collections.abc import Callable

from app.models import (
    Export,
    ExportStatus,
    SummaryStatus,
    TranslationStatus,
)
from app.repositories.chat_repo import ChatMessageRepository, ChatRepository
from app.repositories.document_repo import DocumentRepository
from app.repositories.export_repo import ExportRepository
from app.services.base import (
    BaseService,
    ConflictError,
    NotFoundError,
    ValidationError,
)

EnqueueExportFn = Callable[[str], str]


def assemble_summary_text(document) -> str:
    """Prefer detailed summary; else short; else short+detailed joined."""
    detailed = (getattr(document, "detailed_summary", None) or "").strip()
    short = (getattr(document, "short_summary", None) or "").strip()
    if detailed and short and detailed != short:
        return f"{short}\n\n{detailed}"
    if detailed:
        return detailed
    return short


def format_chat_annotations(messages: list) -> str:
    """Format owned chat messages as User:/Assistant: lines."""
    lines: list[str] = []
    for msg in messages:
        role = getattr(msg, "role", None)
        role_value = role.value if hasattr(role, "value") else str(role or "")
        label = "User" if role_value == "user" else "Assistant"
        content = (getattr(msg, "content", None) or "").strip()
        if content:
            lines.append(f"{label}: {content}")
    return "\n".join(lines)


class ExportService(BaseService[Export]):
    """Validate section toggles / readiness and enqueue PDF export."""

    def __init__(
        self,
        repository: ExportRepository,
        documents: DocumentRepository,
        chats: ChatRepository,
        messages: ChatMessageRepository,
        enqueue_export: EnqueueExportFn | None = None,
    ) -> None:
        super().__init__(repository)
        self._exports = repository
        self._documents = documents
        self._chats = chats
        self._messages = messages
        self._enqueue_export = enqueue_export

    def request_export(
        self,
        *,
        document_id: str,
        user_id: str,
        include_summary: bool = False,
        include_translation: bool = False,
        include_chat: bool = False,
    ) -> Export:
        if not (include_summary or include_translation or include_chat):
            raise ValidationError(
                "At least one section toggle must be enabled "
                "(include_summary, include_translation, or include_chat)"
            )

        document = self._documents.get(document_id)
        if document is None or document.user_id != user_id:
            raise NotFoundError("Document not found")

        if include_summary:
            if document.summary_status != SummaryStatus.ready:
                raise ConflictError(
                    "Summary is not ready; complete summarization before export"
                )
            if not assemble_summary_text(document):
                raise ConflictError(
                    "Summary content is empty; complete summarization before export"
                )

        if include_translation:
            if document.translation_status != TranslationStatus.ready:
                raise ConflictError(
                    "Translation is not ready; complete translation before export"
                )
            translated = (document.translated_text or "").strip()
            if not translated:
                raise ConflictError(
                    "Translation content is empty; complete translation before export"
                )

        if include_chat:
            chat = self._chats.get_by_user_and_document(user_id, document_id)
            if chat is None:
                raise ConflictError(
                    "No chat messages found; ask the document before exporting chat"
                )
            msgs = self._messages.list_by_chat(chat.id)
            if not msgs or not format_chat_annotations(msgs).strip():
                raise ConflictError(
                    "No chat messages found; ask the document before exporting chat"
                )

        if self._enqueue_export is None:
            raise RuntimeError("Export enqueue function is not configured")

        export = self._exports.create(
            user_id=user_id,
            document_id=document_id,
            include_summary=include_summary,
            include_translation=include_translation,
            include_chat=include_chat,
            status=ExportStatus.processing,
        )
        self._enqueue_export(export.id)
        refreshed = self._exports.get(export.id)
        if refreshed is None:
            raise NotFoundError("Export not found")
        return refreshed

    def get_export_status(
        self, *, document_id: str, user_id: str
    ) -> Export:
        document = self._documents.get(document_id)
        if document is None or document.user_id != user_id:
            raise NotFoundError("Document not found")
        export = self._exports.get_latest_for_document(
            document_id=document_id, user_id=user_id
        )
        if export is None:
            raise NotFoundError("Export not found")
        return export

    def get_export(self, *, export_id: str, user_id: str) -> Export:
        export = self._exports.get(export_id)
        if export is None or export.user_id != user_id:
            raise NotFoundError("Export not found")
        return export
