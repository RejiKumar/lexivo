"""SQLAlchemy ORM models for core STEP 3.3 / 3.5 domains."""

import enum
import json
import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import (
    Boolean,
    DateTime,
    Enum,
    ForeignKey,
    Integer,
    JSON,
    String,
    Text,
    TypeDecorator,
    UniqueConstraint,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.types import TEXT

from app.core.db import Base


class DocumentStatus(str, enum.Enum):
    processing = "processing"
    ready = "ready"
    failed = "failed"


class SummaryStatus(str, enum.Enum):
    idle = "idle"
    processing = "processing"
    ready = "ready"
    failed = "failed"


class TranslationStatus(str, enum.Enum):
    idle = "idle"
    processing = "processing"
    ready = "ready"
    failed = "failed"


class JobStatus(str, enum.Enum):
    queued = "queued"
    running = "running"
    succeeded = "succeeded"
    failed = "failed"


class ChatMessageRole(str, enum.Enum):
    user = "user"
    assistant = "assistant"


class ExportStatus(str, enum.Enum):
    idle = "idle"
    processing = "processing"
    ready = "ready"
    failed = "failed"


class SubscriptionTier(str, enum.Enum):
    free = "free"
    paid = "paid"


class SubscriptionStatus(str, enum.Enum):
    active = "active"
    canceled = "canceled"


class UsageResource(str, enum.Enum):
    documents = "documents"
    chat_messages = "chat_messages"
    ocr_pages = "ocr_pages"


class EmbeddingVector(TypeDecorator):
    """Dialect-safe embedding column: pgvector on Postgres, JSON text elsewhere.

    SQLite unit tests store float lists as JSON. Postgres production uses
    ``vector`` via the pgvector SQLAlchemy type when available.
    """

    impl = TEXT
    cache_ok = True

    def load_dialect_impl(self, dialect):  # type: ignore[override]
        if dialect.name == "postgresql":
            try:
                from pgvector.sqlalchemy import Vector

                # Dimension deferred — store as unbounded vector; cast at query time.
                return dialect.type_descriptor(Vector(None))
            except Exception:
                return dialect.type_descriptor(TEXT())
        return dialect.type_descriptor(TEXT())

    def process_bind_param(self, value: Any, dialect) -> Any:
        if value is None:
            return None
        if dialect.name == "postgresql":
            return value
        if isinstance(value, str):
            return value
        return json.dumps([float(x) for x in value])

    def process_result_value(self, value: Any, dialect) -> list[float] | None:
        if value is None:
            return None
        if isinstance(value, list):
            return [float(x) for x in value]
        if isinstance(value, str):
            return [float(x) for x in json.loads(value)]
        # pgvector may return a numpy-like / sequence
        try:
            return [float(x) for x in value]
        except TypeError:
            return None


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    external_id: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    email: Mapped[str | None] = mapped_column(String(320), nullable=True)
    display_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    documents: Mapped[list["Document"]] = relationship(back_populates="owner")
    chats: Mapped[list["Chat"]] = relationship(back_populates="owner")
    exports: Mapped[list["Export"]] = relationship(back_populates="owner")
    notifications: Mapped[list["Notification"]] = relationship(
        back_populates="owner"
    )
    subscription: Mapped["Subscription | None"] = relationship(
        back_populates="owner",
        uselist=False,
    )
    usage_events: Mapped[list["UsageEvent"]] = relationship(
        back_populates="owner"
    )


class Document(Base):
    __tablename__ = "documents"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    title: Mapped[str | None] = mapped_column(String(512), nullable=True)
    storage_key: Mapped[str | None] = mapped_column(String(1024), nullable=True)
    extracted_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    short_summary: Mapped[str | None] = mapped_column(Text, nullable=True)
    detailed_summary: Mapped[str | None] = mapped_column(Text, nullable=True)
    summary_prompt_version: Mapped[str | None] = mapped_column(
        String(16), nullable=True
    )
    summary_status: Mapped[SummaryStatus] = mapped_column(
        Enum(SummaryStatus, name="summary_status"),
        default=SummaryStatus.idle,
    )
    translated_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    source_lang: Mapped[str | None] = mapped_column(String(16), nullable=True)
    target_lang: Mapped[str | None] = mapped_column(String(16), nullable=True)
    translation_status: Mapped[TranslationStatus] = mapped_column(
        Enum(TranslationStatus, name="translation_status"),
        default=TranslationStatus.idle,
    )
    status: Mapped[DocumentStatus] = mapped_column(
        Enum(DocumentStatus, name="document_status"),
        default=DocumentStatus.processing,
    )
    page_count: Mapped[int | None] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    owner: Mapped[User] = relationship(back_populates="documents")
    jobs: Mapped[list["Job"]] = relationship(back_populates="document")
    chunks: Mapped[list["DocumentChunk"]] = relationship(
        back_populates="document",
        cascade="all, delete-orphan",
    )
    chats: Mapped[list["Chat"]] = relationship(
        back_populates="document",
        cascade="all, delete-orphan",
    )
    exports: Mapped[list["Export"]] = relationship(
        back_populates="document",
        cascade="all, delete-orphan",
    )


class DocumentChunk(Base):
    __tablename__ = "document_chunks"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    document_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("documents.id", ondelete="CASCADE"), index=True
    )
    chunk_index: Mapped[int] = mapped_column(Integer, nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    embedding: Mapped[list[float] | None] = mapped_column(
        EmbeddingVector(), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    document: Mapped[Document] = relationship(back_populates="chunks")


class Job(Base):
    __tablename__ = "jobs"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    document_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("documents.id", ondelete="CASCADE"), index=True
    )
    job_type: Mapped[str] = mapped_column(String(64))
    status: Mapped[JobStatus] = mapped_column(
        Enum(JobStatus, name="job_status"),
        default=JobStatus.queued,
    )
    error_message: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    document: Mapped[Document] = relationship(back_populates="jobs")


class Chat(Base):
    """Per-user, per-document chat thread (ask-the-document)."""

    __tablename__ = "chats"
    __table_args__ = (
        UniqueConstraint("user_id", "document_id", name="uq_chats_user_document"),
    )

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    document_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("documents.id", ondelete="CASCADE"), index=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    owner: Mapped[User] = relationship(back_populates="chats")
    document: Mapped[Document] = relationship(back_populates="chats")
    messages: Mapped[list["ChatMessage"]] = relationship(
        back_populates="chat",
        cascade="all, delete-orphan",
        order_by="ChatMessage.created_at",
    )


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    chat_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("chats.id", ondelete="CASCADE"), index=True
    )
    role: Mapped[ChatMessageRole] = mapped_column(
        Enum(ChatMessageRole, name="chat_message_role"),
        nullable=False,
    )
    content: Mapped[str] = mapped_column(Text, nullable=False)
    citations: Mapped[list[dict[str, Any]] | None] = mapped_column(
        JSON, nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    chat: Mapped[Chat] = relationship(back_populates="messages")


class Export(Base):
    """PDF export job — section toggles + StorageProvider signed URL."""

    __tablename__ = "exports"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    document_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("documents.id", ondelete="CASCADE"), index=True
    )
    include_summary: Mapped[bool] = mapped_column(Boolean, default=False)
    include_translation: Mapped[bool] = mapped_column(Boolean, default=False)
    include_chat: Mapped[bool] = mapped_column(Boolean, default=False)
    status: Mapped[ExportStatus] = mapped_column(
        Enum(ExportStatus, name="export_status"),
        default=ExportStatus.idle,
    )
    storage_key: Mapped[str | None] = mapped_column(String(1024), nullable=True)
    signed_url: Mapped[str | None] = mapped_column(String(2048), nullable=True)
    error_message: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    owner: Mapped[User] = relationship(back_populates="exports")
    document: Mapped[Document] = relationship(back_populates="exports")


class Notification(Base):
    """In-app notification row — no email delivery in v1."""

    __tablename__ = "notifications"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    type: Mapped[str] = mapped_column(String(64), nullable=False)
    title: Mapped[str] = mapped_column(String(512), nullable=False, default="")
    body: Mapped[str] = mapped_column(Text, nullable=False, default="")
    payload: Mapped[dict[str, Any] | None] = mapped_column(JSON, nullable=True)
    read_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    owner: Mapped[User] = relationship(back_populates="notifications")


class Subscription(Base):
    """Per-user subscription tier — free by default; paid skips free-tier caps."""

    __tablename__ = "subscriptions"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    user_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("users.id", ondelete="CASCADE"),
        unique=True,
        index=True,
    )
    tier: Mapped[SubscriptionTier] = mapped_column(
        Enum(SubscriptionTier, name="subscription_tier"),
        default=SubscriptionTier.free,
    )
    status: Mapped[SubscriptionStatus] = mapped_column(
        Enum(SubscriptionStatus, name="subscription_status"),
        default=SubscriptionStatus.active,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    owner: Mapped[User] = relationship(back_populates="subscription")


class UsageEvent(Base):
    """Usage ledger for quota enforcement (OCR pages + optional counters).

    OCR rows are idempotent per ``(user_id, resource, document_id, period_start)``.
    """

    __tablename__ = "usage_events"
    __table_args__ = (
        UniqueConstraint(
            "user_id",
            "resource",
            "document_id",
            "period_start",
            name="uq_usage_events_user_resource_doc_period",
        ),
    )

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    resource: Mapped[str] = mapped_column(String(64), nullable=False, index=True)
    amount: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    period_start: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, index=True
    )
    document_id: Mapped[str | None] = mapped_column(
        String(36),
        ForeignKey("documents.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    owner: Mapped[User] = relationship(back_populates="usage_events")
