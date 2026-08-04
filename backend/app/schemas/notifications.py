"""Notification list / mark-read schemas."""

from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class NotificationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    type: str
    title: str
    body: str
    payload: dict[str, Any] = Field(default_factory=dict)
    read_at: datetime | None = None
    created_at: datetime | None = None

    @classmethod
    def from_record(cls, record: dict[str, Any]) -> "NotificationResponse":
        return cls(
            id=str(record["id"]),
            type=str(record.get("type") or ""),
            title=str(record.get("title") or ""),
            body=str(record.get("body") or ""),
            payload=dict(record.get("payload") or {}),
            read_at=record.get("read_at"),
            created_at=record.get("created_at"),
        )


class NotificationListResponse(BaseModel):
    items: list[NotificationResponse]
    total: int
