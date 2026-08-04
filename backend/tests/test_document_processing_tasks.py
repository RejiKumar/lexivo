"""Tests for enqueue_document_processing and run_ocr Celery units.

STEP 3.4: run_ocr must orchestrate via Master → OCR Agent (not OCRProvider directly).
"""

from __future__ import annotations

from pathlib import Path
from unittest.mock import AsyncMock, patch

import pytest
from sqlalchemy.orm import Session

from app.adapters.types import UserIdentity
from app.agents.base_agent import AgentResult
from app.models import DocumentStatus, JobStatus
from app.repositories.document_repo import DocumentRepository
from app.repositories.job_repo import JobRepository
from app.repositories.user_repo import UserRepository
from app.services.document_service import DocumentService
from app.services.user_service import UserService
from app.tasks.document_processing import OCR_JOB_TYPE, enqueue_document_processing, run_ocr
from app.tasks.provider_overrides import set_task_provider_overrides
from tests.fakes import FakeOCRProvider, FakeStorageProvider


def test_run_ocr_task_module_does_not_call_extract_text_directly() -> None:
    source = (
        Path(__file__).resolve().parents[1]
        / "app"
        / "tasks"
        / "document_processing.py"
    ).read_text(encoding="utf-8")
    assert ".extract_text" not in source
    assert "await ocr" not in source
    assert "run_master" in source
    assert "AgentContext" in source


@pytest.mark.asyncio
async def test_run_ocr_uses_master_not_direct_provider(
    db_session: Session,
    fake_storage: FakeStorageProvider,
    fake_ocr: FakeOCRProvider,
    celery_eager: None,
) -> None:
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="master-path", email="master@example.com")
    )
    docs = DocumentRepository(db_session)
    doc = docs.create(
        user_id=user.id,
        title="Scan",
        storage_key="documents/u1/scan.pdf",
        status=DocumentStatus.processing,
    )
    await fake_storage.upload(doc.storage_key, b"%PDF-ocr-fixture")
    set_task_provider_overrides(ocr=fake_ocr, storage=fake_storage)

    jobs = JobRepository(db_session)
    job = jobs.create(
        document_id=doc.id,
        job_type=OCR_JOB_TYPE,
        status=JobStatus.queued,
    )

    master_result = AgentResult(
        success=True,
        data={"text": "from-master", "pages": 2},
    )
    with patch(
        "app.tasks.document_processing.run_master",
        new_callable=AsyncMock,
        return_value=master_result,
    ) as master_mock:
        payload = run_ocr(doc.id, job.id)

    master_mock.assert_awaited_once()
    call_kwargs = master_mock.await_args
    assert call_kwargs.args[0] == "ocr"
    assert call_kwargs.args[1]["file_bytes"] == b"%PDF-ocr-fixture"
    assert call_kwargs.kwargs["ocr_provider"] is fake_ocr
    assert fake_ocr.calls == []  # provider only used inside agent, not when Master mocked

    db_session.expire_all()
    assert jobs.get(job.id).status == JobStatus.succeeded
    assert docs.get(doc.id).status == DocumentStatus.ready
    assert payload["pages"] == 2
    assert payload["text_length"] == len("from-master")


@pytest.mark.asyncio
async def test_enqueue_creates_job_and_queues_ocr(
    db_session: Session,
    fake_storage: FakeStorageProvider,
    fake_ocr: FakeOCRProvider,
    celery_eager: None,
) -> None:
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="ocr-user", email="ocr@example.com")
    )
    docs = DocumentRepository(db_session)
    doc = docs.create(
        user_id=user.id,
        title="Scan",
        storage_key="documents/u1/scan.pdf",
        status=DocumentStatus.processing,
    )
    await fake_storage.upload(doc.storage_key, b"%PDF-ocr-fixture")

    set_task_provider_overrides(ocr=fake_ocr, storage=fake_storage)

    job_id = enqueue_document_processing(doc.id)

    db_session.expire_all()
    jobs = JobRepository(db_session)
    job = jobs.get(job_id)
    assert job is not None
    assert job.document_id == doc.id
    assert job.job_type == OCR_JOB_TYPE
    # Eager mode runs run_ocr immediately → succeeded
    assert job.status == JobStatus.succeeded

    refreshed = docs.get(doc.id)
    assert refreshed is not None
    assert refreshed.status == DocumentStatus.ready
    assert fake_ocr.calls
    assert fake_ocr.calls[0] == b"%PDF-ocr-fixture"


@pytest.mark.asyncio
async def test_run_ocr_marks_failed_on_ocr_error(
    db_session: Session,
    fake_storage: FakeStorageProvider,
    celery_eager: None,
) -> None:
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="ocr-fail", email="fail@example.com")
    )
    docs = DocumentRepository(db_session)
    doc = docs.create(
        user_id=user.id,
        title="Bad",
        storage_key="documents/u1/bad.pdf",
        status=DocumentStatus.processing,
    )
    await fake_storage.upload(doc.storage_key, b"bad")

    failing = FakeOCRProvider(fail=True)
    set_task_provider_overrides(ocr=failing, storage=fake_storage)

    jobs = JobRepository(db_session)
    job = jobs.create(
        document_id=doc.id,
        job_type=OCR_JOB_TYPE,
        status=JobStatus.queued,
    )

    with pytest.raises(RuntimeError, match="OCR failed"):
        run_ocr(doc.id, job.id)

    db_session.expire_all()
    assert jobs.get(job.id).status == JobStatus.failed
    assert docs.get(doc.id).status == DocumentStatus.failed


@pytest.mark.asyncio
async def test_run_ocr_marks_failed_when_master_returns_error(
    db_session: Session,
    fake_storage: FakeStorageProvider,
    fake_ocr: FakeOCRProvider,
    celery_eager: None,
) -> None:
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="master-fail", email="mfail@example.com")
    )
    docs = DocumentRepository(db_session)
    doc = docs.create(
        user_id=user.id,
        title="Bad",
        storage_key="documents/u1/bad2.pdf",
        status=DocumentStatus.processing,
    )
    await fake_storage.upload(doc.storage_key, b"bad")
    set_task_provider_overrides(ocr=fake_ocr, storage=fake_storage)

    jobs = JobRepository(db_session)
    job = jobs.create(
        document_id=doc.id,
        job_type=OCR_JOB_TYPE,
        status=JobStatus.queued,
    )

    with patch(
        "app.tasks.document_processing.run_master",
        new_callable=AsyncMock,
        return_value=AgentResult(success=False, error="agent shaped failure"),
    ):
        with pytest.raises(RuntimeError, match="agent shaped failure"):
            run_ocr(doc.id, job.id)

    db_session.expire_all()
    assert jobs.get(job.id).status == JobStatus.failed
    assert "agent shaped failure" in (jobs.get(job.id).error_message or "")
    assert docs.get(doc.id).status == DocumentStatus.failed


@pytest.mark.asyncio
async def test_document_service_create_enqueues_processing(
    db_session: Session,
    fake_storage: FakeStorageProvider,
    fake_ocr: FakeOCRProvider,
    celery_eager: None,
) -> None:
    set_task_provider_overrides(ocr=fake_ocr, storage=fake_storage)

    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="svc-user", email="svc@example.com")
    )
    service = DocumentService(
        DocumentRepository(db_session),
        storage=fake_storage,
        enqueue_processing=enqueue_document_processing,
    )

    doc = await service.create_with_upload(
        user_id=user.id,
        title="Lease",
        file_bytes=b"%PDF-lease",
        filename="lease.pdf",
    )

    db_session.expire_all()
    refreshed = DocumentRepository(db_session).get(doc.id)
    assert refreshed is not None
    assert refreshed.status == DocumentStatus.ready
    jobs = JobRepository(db_session).list(
        {"document_id": doc.id, "job_type": OCR_JOB_TYPE}
    )
    assert len(jobs) == 1
    assert jobs[0].status == JobStatus.succeeded
    assert fake_ocr.calls


def test_upload_api_eager_ocr_status_ready(
    api_client,
    fake_ocr: FakeOCRProvider,
    auth_header: dict[str, str],
) -> None:
    """Integration: upload → Master → OCR Agent → FakeOCRProvider → status ready."""
    create_resp = api_client.post(
        "/api/v1/documents",
        headers=auth_header,
        files={"file": ("lease.pdf", b"%PDF-lease", "application/pdf")},
        data={"title": "Lease"},
    )
    assert create_resp.status_code == 201
    doc_id = create_resp.json()["id"]
    status_resp = api_client.get(
        f"/api/v1/documents/{doc_id}/status",
        headers=auth_header,
    )
    assert status_resp.status_code == 200
    assert status_resp.json() == {"id": doc_id, "status": "ready"}
    assert fake_ocr.calls
