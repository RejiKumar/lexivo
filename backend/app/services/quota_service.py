"""Shared free-tier quota gateway — single module for docs / chat / OCR caps."""

from __future__ import annotations

from datetime import UTC, datetime, timedelta
from typing import Literal

from sqlalchemy.orm import Session

from app.core.config import Settings
from app.models import SubscriptionTier
from app.repositories.subscription_repo import (
    QuotaUsageRepository,
    SubscriptionRepository,
    UsageEventRepository,
)
from app.services.base import QuotaExceededError

ResourceName = Literal["documents", "chat_messages", "ocr_pages"]
PeriodName = Literal["month", "day"]


def utc_month_start(now: datetime | None = None) -> datetime:
    current = now or datetime.now(UTC)
    if current.tzinfo is None:
        current = current.replace(tzinfo=UTC)
    return current.astimezone(UTC).replace(
        day=1, hour=0, minute=0, second=0, microsecond=0
    )


def utc_month_end(period_start: datetime) -> datetime:
    if period_start.month == 12:
        return period_start.replace(year=period_start.year + 1, month=1)
    return period_start.replace(month=period_start.month + 1)


def utc_day_start(now: datetime | None = None) -> datetime:
    current = now or datetime.now(UTC)
    if current.tzinfo is None:
        current = current.replace(tzinfo=UTC)
    return current.astimezone(UTC).replace(
        hour=0, minute=0, second=0, microsecond=0
    )


def utc_day_end(period_start: datetime) -> datetime:
    return period_start + timedelta(days=1)


class QuotaService:
    """Enforce Settings-driven free-tier caps; paid tier bypasses all caps."""

    def __init__(self, session: Session, settings: Settings) -> None:
        self._session = session
        self._settings = settings
        self._subscriptions = SubscriptionRepository(session)
        self._usage = QuotaUsageRepository(session)
        self._events = UsageEventRepository(session)

    def is_paid(self, user_id: str) -> bool:
        sub = self._subscriptions.get_or_create_free(user_id)
        return sub.tier == SubscriptionTier.paid

    def enforce_document_create(self, user_id: str) -> None:
        if self.is_paid(user_id):
            return
        start = utc_month_start()
        end = utc_month_end(start)
        used = self._usage.count_documents_in_period(
            user_id=user_id, period_start=start, period_end=end
        )
        limit = self._settings.free_tier_docs_per_month
        if used >= limit:
            raise QuotaExceededError(
                resource="documents",
                limit=limit,
                period="month",
                message=(
                    f"Document limit of {limit} per month exceeded "
                    f"({used}/{limit} used)"
                ),
            )

    def enforce_chat_message(self, user_id: str) -> None:
        if self.is_paid(user_id):
            return
        start = utc_day_start()
        end = utc_day_end(start)
        used = self._usage.count_user_chat_messages_in_period(
            user_id=user_id, period_start=start, period_end=end
        )
        limit = self._settings.free_tier_chat_messages_per_day
        if used >= limit:
            raise QuotaExceededError(
                resource="chat_messages",
                limit=limit,
                period="day",
                message=(
                    f"Chat message limit of {limit} per day exceeded "
                    f"({used}/{limit} used)"
                ),
            )

    def enforce_ocr_pages(
        self,
        *,
        user_id: str,
        estimated_pages: int,
        document_id: str | None = None,
    ) -> None:
        """Reject when used + estimate would exceed monthly OCR page cap.

        When ``document_id`` is set, re-OCR only charges the delta above pages
        already recorded for that document in-period (idempotent ceiling).
        """
        if self.is_paid(user_id):
            return
        pages = max(1, int(estimated_pages))
        start = utc_month_start()
        already_for_doc = 0
        if document_id is not None:
            already_for_doc = self._usage.ocr_pages_for_document(
                user_id=user_id, document_id=document_id, period_start=start
            )
        # Net new pages this job would add after idempotent upsert to `pages`.
        net_new = max(0, pages - already_for_doc)
        if net_new == 0:
            return
        used = self._usage.ocr_pages_used(user_id=user_id, period_start=start)
        limit = self._settings.free_tier_ocr_pages_per_month
        if used + net_new > limit:
            raise QuotaExceededError(
                resource="ocr_pages",
                limit=limit,
                period="month",
                message=(
                    f"OCR page limit of {limit} per month exceeded "
                    f"({used}/{limit} used, need {net_new} more)"
                ),
            )

    def record_ocr_pages(
        self,
        *,
        user_id: str,
        document_id: str,
        pages: int,
    ) -> None:
        """Persist actual OCR pages for the document in the current UTC month."""
        amount = max(0, int(pages))
        start = utc_month_start()
        self._events.upsert_document_amount(
            user_id=user_id,
            resource="ocr_pages",
            document_id=document_id,
            period_start=start,
            amount=amount,
        )

    def usage_snapshot(self, user_id: str) -> dict[str, object]:
        """Return used/limit/period buckets for GET /subscriptions/me."""
        month_start = utc_month_start()
        month_end = utc_month_end(month_start)
        day_start = utc_day_start()
        day_end = utc_day_end(day_start)
        return {
            "documents": {
                "used": self._usage.count_documents_in_period(
                    user_id=user_id,
                    period_start=month_start,
                    period_end=month_end,
                ),
                "limit": self._settings.free_tier_docs_per_month,
                "period": "month",
            },
            "chat_messages": {
                "used": self._usage.count_user_chat_messages_in_period(
                    user_id=user_id,
                    period_start=day_start,
                    period_end=day_end,
                ),
                "limit": self._settings.free_tier_chat_messages_per_day,
                "period": "day",
            },
            "ocr_pages": {
                "used": self._usage.ocr_pages_used(
                    user_id=user_id, period_start=month_start
                ),
                "limit": self._settings.free_tier_ocr_pages_per_month,
                "period": "month",
            },
        }
