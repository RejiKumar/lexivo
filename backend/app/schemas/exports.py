"""Export request/response schemas."""

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict

ExportStatusLiteral = Literal["idle", "processing", "ready", "failed"]


class ExportRequest(BaseModel):
    include_summary: bool = False
    include_translation: bool = False
    include_chat: bool = False


class ExportResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    document_id: str
    include_summary: bool = False
    include_translation: bool = False
    include_chat: bool = False
    export_status: ExportStatusLiteral
    storage_key: str | None = None
    signed_url: str | None = None
    error_message: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None

    @classmethod
    def from_orm_export(cls, export: object) -> "ExportResponse":
        status = getattr(export, "status")
        status_value = status.value if hasattr(status, "value") else str(status)
        return cls(
            id=getattr(export, "id"),
            document_id=getattr(export, "document_id"),
            include_summary=bool(getattr(export, "include_summary")),
            include_translation=bool(getattr(export, "include_translation")),
            include_chat=bool(getattr(export, "include_chat")),
            export_status=status_value,  # type: ignore[arg-type]
            storage_key=getattr(export, "storage_key", None),
            signed_url=getattr(export, "signed_url", None),
            error_message=getattr(export, "error_message", None),
            created_at=getattr(export, "created_at", None),
            updated_at=getattr(export, "updated_at", None),
        )
