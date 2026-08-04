"""SQLAlchemy NotificationStore — persists in-app notification rows."""

from __future__ import annotations

from datetime import UTC, datetime
from typing import Any

from sqlalchemy.orm import Session

from app.models import Notification


def _serialize(row: Notification) -> dict[str, Any]:
    return {
        "id": row.id,
        "user_id": row.user_id,
        "type": row.type,
        "title": row.title,
        "body": row.body,
        "payload": dict(row.payload) if row.payload else {},
        "read_at": row.read_at,
        "created_at": row.created_at,
    }


class SqlNotificationStore:
    """NotificationStore Protocol adapter backed by the notifications table."""

    def __init__(self, session: Session) -> None:
        self._session = session

    async def create_notification(
        self,
        user_id: str,
        type: str,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        payload_copy = dict(payload)
        title = str(payload_copy.get("title") or "Lexivo")
        body = str(payload_copy.get("body") or "")
        now = datetime.now(UTC)
        row = Notification(
            user_id=user_id,
            type=type,
            title=title,
            body=body,
            payload=payload_copy,
            read_at=None,
            created_at=now,
        )
        self._session.add(row)
        self._session.commit()
        self._session.refresh(row)
        return _serialize(row)

    async def list_for_user(
        self,
        user_id: str,
        *,
        unread_only: bool = False,
    ) -> list[dict[str, Any]]:
        query = self._session.query(Notification).filter(
            Notification.user_id == user_id
        )
        if unread_only:
            query = query.filter(Notification.read_at.is_(None))
        rows = (
            query.order_by(
                Notification.created_at.desc(),
                Notification.id.desc(),
            ).all()
        )
        return [_serialize(r) for r in rows]

    async def mark_read(
        self,
        user_id: str,
        notification_id: str,
    ) -> dict[str, Any] | None:
        row = (
            self._session.query(Notification)
            .filter(
                Notification.id == notification_id,
                Notification.user_id == user_id,
            )
            .first()
        )
        if row is None:
            return None
        if row.read_at is None:
            row.read_at = datetime.now(UTC)
            self._session.commit()
            self._session.refresh(row)
        return _serialize(row)
