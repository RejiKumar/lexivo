"""Unit tests for DocumentService upload + status lifecycle."""

from collections.abc import Generator
from typing import Any

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.adapters.types import UserIdentity
from app.core.db import Base
from app.models import DocumentStatus
from app.repositories.document_repo import DocumentRepository
from app.repositories.user_repo import UserRepository
from app.services.document_service import DocumentService
from app.services.user_service import UserService


class FakeStorage:
    def __init__(self) -> None:
        self.uploads: list[tuple[str, bytes]] = []

    async def upload(self, key: str, file: bytes) -> str:
        self.uploads.append((key, file))
        return f"s3://bucket/{key}"

    async def signed_url(self, key: str) -> str:
        return f"https://signed.example/{key}"


@pytest.fixture
def document_setup() -> Generator[tuple[DocumentService, FakeStorage, str], None, None]:
    engine = create_engine(
        "sqlite+pysqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    SessionLocal = sessionmaker(bind=engine, expire_on_commit=False)
    session = SessionLocal()
    storage = FakeStorage()
    enqueued: list[str] = []

    def enqueue(document_id: str) -> None:
        enqueued.append(document_id)

    users = UserService(UserRepository(session))
    user = users.upsert_from_identity(
        UserIdentity(subject="doc-user", email="doc@example.com")
    )
    service = DocumentService(
        DocumentRepository(session),
        storage=storage,
        enqueue_processing=enqueue,
    )
    storage.enqueued = enqueued  # type: ignore[attr-defined]
    try:
        yield service, storage, user.id
    finally:
        session.close()
        Base.metadata.drop_all(engine)
        engine.dispose()


@pytest.mark.asyncio
async def test_create_document_uploads_and_sets_processing(
    document_setup: tuple[DocumentService, FakeStorage, str],
) -> None:
    service, storage, user_id = document_setup
    doc = await service.create_with_upload(
        user_id=user_id,
        title="Lease",
        file_bytes=b"%PDF-1.4",
        filename="lease.pdf",
    )
    assert doc.user_id == user_id
    assert doc.title == "Lease"
    assert doc.status == DocumentStatus.processing
    assert doc.storage_key is not None
    assert storage.uploads
    assert storage.uploads[0][1] == b"%PDF-1.4"
    assert getattr(storage, "enqueued") == [doc.id]


@pytest.mark.asyncio
async def test_status_lifecycle_and_list_by_user(
    document_setup: tuple[DocumentService, FakeStorage, str],
) -> None:
    service, _storage, user_id = document_setup
    doc = await service.create_with_upload(
        user_id=user_id,
        title="Invoice",
        file_bytes=b"img",
        filename="invoice.png",
    )
    assert service.get_status(doc.id) == DocumentStatus.processing

    ready = service.mark_status(doc.id, DocumentStatus.ready)
    assert ready.status == DocumentStatus.ready
    assert service.get_status(doc.id) == DocumentStatus.ready

    failed = service.mark_status(doc.id, DocumentStatus.failed)
    assert failed.status == DocumentStatus.failed

    listed = service.list_for_user(user_id)
    assert len(listed) == 1
    assert listed[0].id == doc.id

    filtered = service.list_for_user(user_id, status=DocumentStatus.failed)
    assert len(filtered) == 1


@pytest.mark.asyncio
async def test_create_metadata_without_upload_hook(
    document_setup: tuple[DocumentService, FakeStorage, str],
) -> None:
    service, storage, user_id = document_setup
    doc = service.create(
        {
            "user_id": user_id,
            "title": "Draft",
            "status": DocumentStatus.processing,
        }
    )
    assert doc.storage_key is None
    assert storage.uploads == []
