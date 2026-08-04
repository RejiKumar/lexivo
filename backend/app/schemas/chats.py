"""Chat / chat message request and response schemas."""

from datetime import datetime
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field

ChatMessageRoleLiteral = Literal["user", "assistant"]


class CitationPayload(BaseModel):
    model_config = ConfigDict(extra="ignore")

    chunk_id: str | None = None
    index: int | None = None
    snippet: str | None = None
    page: int | None = None
    label: str | None = None


class ChatResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    document_id: str
    created_at: datetime | None = None
    updated_at: datetime | None = None


class ChatMessageCreate(BaseModel):
    content: str = Field(..., min_length=1)


class ChatMessageResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    chat_id: str
    role: ChatMessageRoleLiteral
    content: str
    citations: list[dict[str, Any]] | None = None
    created_at: datetime | None = None


class ChatMessageListResponse(BaseModel):
    items: list[ChatMessageResponse] = Field(default_factory=list)
