"""Subscription + usage ledger repositories."""

from __future__ import annotations

from datetime import datetime

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models import (
    Chat,
    ChatMessage,
    ChatMessageRole,
    Document,
    Subscription,
    SubscriptionStatus,
    SubscriptionTier,
    UsageEvent,
)
from app.repositories.base import BaseRepository


class SubscriptionRepository(BaseRepository[Subscription]):
    model = Subscription

    def get_by_user_id(self, user_id: str) -> Subscription | None:
        return (
            self.session.query(Subscription)
            .filter(Subscription.user_id == user_id)
            .one_or_none()
        )

    def get_or_create_free(self, user_id: str) -> Subscription:
        existing = self.get_by_user_id(user_id)
        if existing is not None:
            return existing
        return self.create(
            user_id=user_id,
            tier=SubscriptionTier.free,
            status=SubscriptionStatus.active,
        )


class UsageEventRepository(BaseRepository[UsageEvent]):
    model = UsageEvent

    def sum_amount(
        self,
        *,
        user_id: str,
        resource: str,
        period_start: datetime,
    ) -> int:
        total = (
            self.session.query(func.coalesce(func.sum(UsageEvent.amount), 0))
            .filter(
                UsageEvent.user_id == user_id,
                UsageEvent.resource == resource,
                UsageEvent.period_start == period_start,
            )
            .scalar()
        )
        return int(total or 0)

    def get_for_document_period(
        self,
        *,
        user_id: str,
        resource: str,
        document_id: str,
        period_start: datetime,
    ) -> UsageEvent | None:
        return (
            self.session.query(UsageEvent)
            .filter(
                UsageEvent.user_id == user_id,
                UsageEvent.resource == resource,
                UsageEvent.document_id == document_id,
                UsageEvent.period_start == period_start,
            )
            .one_or_none()
        )

    def upsert_document_amount(
        self,
        *,
        user_id: str,
        resource: str,
        document_id: str,
        period_start: datetime,
        amount: int,
    ) -> UsageEvent:
        """Set OCR page usage for a document in-period (idempotent; no double-count)."""
        existing = self.get_for_document_period(
            user_id=user_id,
            resource=resource,
            document_id=document_id,
            period_start=period_start,
        )
        if existing is not None:
            existing.amount = amount
            self.session.commit()
            self.session.refresh(existing)
            return existing
        return self.create(
            user_id=user_id,
            resource=resource,
            document_id=document_id,
            period_start=period_start,
            amount=amount,
        )


class QuotaUsageRepository:
    """Read usage from domain tables + OCR ledger (single place for counts)."""

    def __init__(self, session: Session) -> None:
        self.session = session
        self.usage_events = UsageEventRepository(session)

    def count_documents_in_period(
        self, *, user_id: str, period_start: datetime, period_end: datetime
    ) -> int:
        return (
            self.session.query(func.count(Document.id))
            .filter(
                Document.user_id == user_id,
                Document.created_at >= period_start,
                Document.created_at < period_end,
            )
            .scalar()
            or 0
        )

    def count_user_chat_messages_in_period(
        self, *, user_id: str, period_start: datetime, period_end: datetime
    ) -> int:
        return (
            self.session.query(func.count(ChatMessage.id))
            .join(Chat, ChatMessage.chat_id == Chat.id)
            .filter(
                Chat.user_id == user_id,
                ChatMessage.role == ChatMessageRole.user,
                ChatMessage.created_at >= period_start,
                ChatMessage.created_at < period_end,
            )
            .scalar()
            or 0
        )

    def ocr_pages_used(self, *, user_id: str, period_start: datetime) -> int:
        return self.usage_events.sum_amount(
            user_id=user_id,
            resource="ocr_pages",
            period_start=period_start,
        )

    def ocr_pages_for_document(
        self, *, user_id: str, document_id: str, period_start: datetime
    ) -> int:
        row = self.usage_events.get_for_document_period(
            user_id=user_id,
            resource="ocr_pages",
            document_id=document_id,
            period_start=period_start,
        )
        return int(row.amount) if row is not None else 0
