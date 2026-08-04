"""Document create/list/status schemas."""

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

DocumentStatusLiteral = Literal["processing", "ready", "failed"]


class DocumentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    title: str | None = None
    storage_key: str | None = None
    status: DocumentStatusLiteral
    created_at: datetime | None = None
    updated_at: datetime | None = None


class DocumentListResponse(BaseModel):
    items: list[DocumentResponse] = Field(default_factory=list)


class DocumentStatusResponse(BaseModel):
    id: str
    status: DocumentStatusLiteral
