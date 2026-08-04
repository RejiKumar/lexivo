"""Chat and ChatMessage repositories — SQL CRUD only."""

from __future__ import annotations

from typing import Any

from sqlalchemy import case
from sqlalchemy.orm import Session

from app.models import Chat, ChatMessage, ChatMessageRole
from app.repositories.base import BaseRepository


class ChatRepository(BaseRepository[Chat]):
    model = Chat

    def __init__(self, session: Session) -> None:
        super().__init__(session)

    def get_by_user_and_document(self, user_id: str, document_id: str) -> Chat | None:
        return (
            self.session.query(Chat)
            .filter(Chat.user_id == user_id, Chat.document_id == document_id)
            .one_or_none()
        )

    def get_or_create(self, *, user_id: str, document_id: str) -> Chat:
        existing = self.get_by_user_and_document(user_id, document_id)
        if existing is not None:
            return existing
        return self.create(user_id=user_id, document_id=document_id)


class ChatMessageRepository(BaseRepository[ChatMessage]):
    model = ChatMessage

    def __init__(self, session: Session) -> None:
        super().__init__(session)

    def list_by_chat(self, chat_id: str) -> list[ChatMessage]:
        role_order = case(
            (ChatMessage.role == ChatMessageRole.user, 0),
            else_=1,
        )
        return (
            self.session.query(ChatMessage)
            .filter(ChatMessage.chat_id == chat_id)
            .order_by(ChatMessage.created_at.asc(), role_order, ChatMessage.id.asc())
            .all()
        )

    def add_message(
        self,
        *,
        chat_id: str,
        role: ChatMessageRole,
        content: str,
        citations: list[dict[str, Any]] | None = None,
        created_at: Any | None = None,
    ) -> ChatMessage:
        fields: dict[str, Any] = {
            "chat_id": chat_id,
            "role": role,
            "content": content,
            "citations": citations,
        }
        if created_at is not None:
            fields["created_at"] = created_at
        return self.create(**fields)
