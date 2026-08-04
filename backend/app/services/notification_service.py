"""Thin notification service — list/mark-read + job-complete emit via Master only."""

from __future__ import annotations

import logging
from typing import Any

from app.adapters.protocols import NotificationStore, PushProvider
from app.adapters.push import StubPushProvider
from app.agents.base_agent import AgentContext
from app.agents.master_agent import run_master
from app.services.base import NotFoundError

logger = logging.getLogger(__name__)

_JOB_COPY: dict[str, tuple[str, str]] = {
    "ocr": ("OCR complete", "Your document text is ready."),
    "summary": ("Summary ready", "Your document summary is ready."),
    "translation": ("Translation ready", "Your translation is ready."),
    "export": ("PDF export ready", "Your PDF export is ready to download."),
}


class NotificationService:
    """List + mark-read via NotificationStore. Never imports the specialist agent."""

    def __init__(self, store: NotificationStore) -> None:
        self._store = store

    async def list_notifications(
        self,
        user_id: str,
        *,
        unread_only: bool = False,
    ) -> list[dict[str, Any]]:
        return await self._store.list_for_user(user_id, unread_only=unread_only)

    async def mark_read(
        self,
        user_id: str,
        notification_id: str,
    ) -> dict[str, Any]:
        record = await self._store.mark_read(user_id, notification_id)
        if record is None:
            raise NotFoundError("Notification not found")
        return record


async def emit_job_complete_notification(
    *,
    user_id: str,
    job_type: str,
    document_id: str | None = None,
    job_id: str | None = None,
    title: str | None = None,
    body: str | None = None,
    push_enabled: bool = True,
    notification_store: NotificationStore | None = None,
    push: PushProvider | None = None,
) -> dict[str, Any] | None:
    """Emit processing-complete via Master ``notification`` intent only.

    Soft-fails: logs and returns None on Master/agent errors so callers can
    continue treating the parent job as succeeded.
    """
    if notification_store is None:
        logger.warning(
            "emit_job_complete_notification skipped: no NotificationStore"
        )
        return None

    default_title, default_body = _JOB_COPY.get(
        job_type,
        ("Processing complete", f"Your {job_type} job finished."),
    )
    push_provider = push if push is not None else StubPushProvider()

    try:
        result = await run_master(
            "notification",
            {
                "user_id": user_id,
                "event_type": "processing_complete",
                "job_type": job_type,
                "type": "processing_complete",
                "title": title or default_title,
                "body": body or default_body,
                "document_id": document_id,
                "job_id": job_id,
                "push_enabled": push_enabled,
            },
            AgentContext(
                user_id=user_id,
                document_id=document_id,
                job_id=job_id,
            ),
            notification_store=notification_store,
            push=push_provider,
        )
        if not result.success:
            logger.warning(
                "notification emit soft-failed: %s",
                result.error or "unknown",
            )
            return None
        return result.data
    except Exception:
        logger.exception("notification emit soft-failed")
        return None
