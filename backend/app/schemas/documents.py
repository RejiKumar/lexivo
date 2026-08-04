"""Document create/list/status schemas."""

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

DocumentStatusLiteral = Literal["processing", "ready", "failed"]
SummaryStatusLiteral = Literal["idle", "processing", "ready", "failed"]
TranslationStatusLiteral = Literal["idle", "processing", "ready", "failed"]
SupportedLangLiteral = Literal["en", "es", "fr", "de", "hi", "pt"]


class DocumentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    title: str | None = None
    storage_key: str | None = None
    status: DocumentStatusLiteral
    extracted_text: str | None = None
    short_summary: str | None = None
    detailed_summary: str | None = None
    summary_status: SummaryStatusLiteral = "idle"
    translated_text: str | None = None
    source_lang: str | None = None
    target_lang: str | None = None
    translation_status: TranslationStatusLiteral = "idle"
    created_at: datetime | None = None
    updated_at: datetime | None = None


class DocumentListResponse(BaseModel):
    items: list[DocumentResponse] = Field(default_factory=list)


class DocumentStatusResponse(BaseModel):
    id: str
    status: DocumentStatusLiteral


class SummaryStatusResponse(BaseModel):
    id: str
    summary_status: SummaryStatusLiteral


class TranslationRequest(BaseModel):
    source_lang: SupportedLangLiteral
    target_lang: SupportedLangLiteral


class TranslationStatusResponse(BaseModel):
    id: str
    translation_status: TranslationStatusLiteral
    source_lang: str | None = None
    target_lang: str | None = None
