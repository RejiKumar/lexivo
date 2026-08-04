"""Thin ChatService — ask via Master only (ask / rag_chat → Search→Citation).

Does not import specialist agents or the RAG pipeline type (pipeline is injected).
Prefer Master intent ``ask`` (alias ``rag_chat`` accepted by Master ASK_INTENTS).
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta
from typing import Any

from app.adapters.protocols import LLMProvider
from app.agents.base_agent import AgentContext
from app.agents.master_agent import run_master
from app.models import Chat, ChatMessage, ChatMessageRole, DocumentStatus
from app.repositories.chat_repo import ChatMessageRepository, ChatRepository
from app.repositories.chunk_repo import DocumentChunkRepository
from app.repositories.document_repo import DocumentRepository
from app.services.base import BaseService, ConflictError, NotFoundError, ValidationError
from app.services.quota_service import QuotaService

# Prefer ``ask``; Master also accepts alias ``rag_chat``.
ASK_INTENT = "ask"
CANNOT_ANSWER = "I cannot answer from the document."


class ChatService(BaseService[Chat]):
    """Ensure chat, list messages, and synchronous ask via ``run_master``."""

    def __init__(
        self,
        chat_repository: ChatRepository,
        message_repository: ChatMessageRepository,
        document_repository: DocumentRepository,
        chunk_repository: DocumentChunkRepository,
        *,
        llm: LLMProvider,
        rag_pipeline: Any,
        quota: QuotaService | None = None,
    ) -> None:
        super().__init__(chat_repository)
        self._chats = chat_repository
        self._messages = message_repository
        self._documents = document_repository
        self._chunks = chunk_repository
        self._llm = llm
        self._rag_pipeline = rag_pipeline
        self._quota = quota

    def ensure_chat(self, *, document_id: str, user_id: str) -> Chat:
        self._require_owned_document(document_id=document_id, user_id=user_id)
        return self._chats.get_or_create(user_id=user_id, document_id=document_id)

    def list_messages(self, *, document_id: str, user_id: str) -> list[ChatMessage]:
        chat = self.ensure_chat(document_id=document_id, user_id=user_id)
        return self._messages.list_by_chat(chat.id)

    async def ask(
        self,
        *,
        document_id: str,
        user_id: str,
        content: str,
    ) -> ChatMessage:
        question = content.strip()
        if not question:
            raise ValidationError("Message content must not be empty")

        document = self._require_owned_document(
            document_id=document_id, user_id=user_id
        )
        self._require_rag_ready(document)

        if self._quota is not None:
            self._quota.enforce_chat_message(user_id)

        chat = self._chats.get_or_create(user_id=user_id, document_id=document_id)
        asked_at = datetime.now(UTC)
        self._messages.add_message(
            chat_id=chat.id,
            role=ChatMessageRole.user,
            content=question,
            created_at=asked_at,
        )

        context = AgentContext(
            document_id=document_id,
            user_id=user_id,
        )
        result = await run_master(
            ASK_INTENT,
            {"question": question, "document_id": document_id},
            context,
            llm=self._llm,
            rag_pipeline=self._rag_pipeline,
        )

        answer, citations = self._shape_assistant(result)
        return self._messages.add_message(
            chat_id=chat.id,
            role=ChatMessageRole.assistant,
            content=answer,
            citations=citations,
            created_at=asked_at + timedelta(milliseconds=1),
        )

    def _require_owned_document(self, *, document_id: str, user_id: str):
        document = self._documents.get(document_id)
        if document is None or document.user_id != user_id:
            raise NotFoundError("Document not found")
        return document

    def _require_rag_ready(self, document) -> None:
        if document.status != DocumentStatus.ready:
            raise ConflictError(
                "Document OCR is not ready; chat requires status=ready"
            )
        chunks = self._chunks.list_by_document(document.id)
        if not chunks:
            raise ConflictError(
                "Document is not ingested; generate embeddings before chat"
            )

    @staticmethod
    def _shape_assistant(result: Any) -> tuple[str, list[dict[str, Any]] | None]:
        """Map Master/Citation AgentResult to persisted assistant content + citations."""
        data = getattr(result, "data", None) or {}
        success = bool(getattr(result, "success", False))

        if not success:
            return CANNOT_ANSWER, []

        answer = data.get("answer")
        if not isinstance(answer, str) or not answer.strip():
            return CANNOT_ANSWER, []

        raw_citations = data.get("citations")
        citations: list[dict[str, Any]] | None
        if isinstance(raw_citations, list):
            citations = [c for c in raw_citations if isinstance(c, dict)]
        else:
            citations = []

        if data.get("cannot_answer") or data.get("ungrounded"):
            return answer.strip(), citations

        return answer.strip(), citations or None
