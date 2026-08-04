"""Tests for summary schemas, service, Celery task, and thin API routes."""

from __future__ import annotations

import json
from pathlib import Path
from unittest.mock import AsyncMock, patch

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.adapters.types import UserIdentity
from app.agents.base_agent import AgentResult
from app.models import DocumentStatus, JobStatus, SummaryStatus
from app.repositories.document_repo import DocumentRepository
from app.repositories.job_repo import JobRepository
from app.repositories.user_repo import UserRepository
from app.schemas import DocumentResponse, SummaryStatusResponse
from app.services.base import ConflictError, NotFoundError
from app.services.summary_service import SummaryService
from app.services.user_service import UserService
from app.tasks.provider_overrides import set_task_provider_overrides
from app.tasks.summary import SUMMARY_JOB_TYPE, enqueue_summary, run_summary
from tests.conftest import make_auth_header
from tests.fakes import FakeLLMProvider


def test_document_response_includes_summary_fields() -> None:
    doc = DocumentResponse(
        id="d1",
        user_id="u1",
        title="Lease",
        storage_key="documents/u1/lease.pdf",
        status="ready",
        extracted_text="body",
        short_summary="Short",
        detailed_summary="Detailed",
        summary_status="ready",
        created_at=None,
        updated_at=None,
    )
    dumped = doc.model_dump()
    assert dumped["short_summary"] == "Short"
    assert dumped["detailed_summary"] == "Detailed"
    assert dumped["summary_status"] == "ready"

    idle = DocumentResponse(
        id="d2",
        user_id="u1",
        title="New",
        storage_key=None,
        status="processing",
        extracted_text=None,
        created_at=None,
        updated_at=None,
    )
    assert idle.summary_status == "idle"
    assert idle.short_summary is None

    status = SummaryStatusResponse(id="d1", summary_status="processing")
    assert status.model_dump() == {"id": "d1", "summary_status": "processing"}


def test_summary_task_module_enters_via_master_only() -> None:
    source = (
        Path(__file__).resolve().parents[1] / "app" / "tasks" / "summary.py"
    ).read_text(encoding="utf-8")
    assert "run_master" in source
    assert "from app.agents.master_agent import run_master" in source
    assert "SummaryAgent" not in source
    assert "summary_agent" not in source
    assert "app.agents.summary_agent" not in source


def _ready_doc(db_session: Session, *, subject: str, text: str = "OCR body"):
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject=subject, email=f"{subject}@example.com")
    )
    docs = DocumentRepository(db_session)
    doc = docs.create(
        user_id=user.id,
        title="Ready",
        storage_key="documents/u1/ready.pdf",
        status=DocumentStatus.ready,
        extracted_text=text,
        summary_status=SummaryStatus.idle,
    )
    return user, docs, doc


def test_summary_service_rejects_not_ready(db_session: Session) -> None:
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="sum-nr", email="nr@example.com")
    )
    docs = DocumentRepository(db_session)
    doc = docs.create(
        user_id=user.id,
        title="Processing",
        status=DocumentStatus.processing,
        extracted_text=None,
    )
    service = SummaryService(docs, enqueue_summary=lambda _id: "job")
    with pytest.raises(ConflictError, match="not ready"):
        service.request_summary(document_id=doc.id, user_id=user.id)


def test_summary_service_rejects_empty_extracted_text(db_session: Session) -> None:
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="sum-empty", email="empty@example.com")
    )
    docs = DocumentRepository(db_session)
    doc = docs.create(
        user_id=user.id,
        title="Empty",
        status=DocumentStatus.ready,
        extracted_text="   ",
    )
    service = SummaryService(docs, enqueue_summary=lambda _id: "job")
    with pytest.raises(ConflictError, match="extracted text"):
        service.request_summary(document_id=doc.id, user_id=user.id)


def test_summary_service_rejects_wrong_owner(db_session: Session) -> None:
    user, docs, doc = _ready_doc(db_session, subject="sum-owner")
    other = UserService(UserRepository(db_session)).upsert_from_identity(
        UserIdentity(subject="other", email="other@example.com")
    )
    service = SummaryService(docs, enqueue_summary=lambda _id: "job")
    with pytest.raises(NotFoundError):
        service.request_summary(document_id=doc.id, user_id=other.id)


def test_summary_service_sets_processing_and_enqueues(db_session: Session) -> None:
    user, docs, doc = _ready_doc(db_session, subject="sum-ok")
    enqueued: list[str] = []
    service = SummaryService(
        docs, enqueue_summary=lambda doc_id: enqueued.append(doc_id) or "job-1"
    )
    updated = service.request_summary(document_id=doc.id, user_id=user.id)
    assert updated.summary_status == SummaryStatus.processing
    assert enqueued == [doc.id]


@pytest.mark.asyncio
async def test_run_summary_uses_master_and_persists(
    db_session: Session,
    fake_llm: FakeLLMProvider,
    celery_eager: None,
) -> None:
    user, docs, doc = _ready_doc(db_session, subject="sum-master")
    set_task_provider_overrides(llm=fake_llm)

    jobs = JobRepository(db_session)
    job = jobs.create(
        document_id=doc.id,
        job_type=SUMMARY_JOB_TYPE,
        status=JobStatus.queued,
    )

    master_result = AgentResult(
        success=True,
        data={
            "short_summary": "Short from master",
            "detailed_summary": "Detailed from master",
        },
    )
    with patch(
        "app.tasks.summary.run_master",
        new_callable=AsyncMock,
        return_value=master_result,
    ) as master_mock:
        payload = run_summary(doc.id, job.id)

    master_mock.assert_awaited_once()
    call = master_mock.await_args
    assert call.args[0] == "summary"
    assert call.args[1]["text"] == "OCR body"
    assert call.args[1]["document_id"] == doc.id
    assert call.kwargs["llm"] is fake_llm

    db_session.expire_all()
    assert jobs.get(job.id).status == JobStatus.succeeded
    ready = docs.get(doc.id)
    assert ready.summary_status == SummaryStatus.ready
    assert ready.short_summary == "Short from master"
    assert ready.detailed_summary == "Detailed from master"
    assert payload["summary_status"] == "ready"


@pytest.mark.asyncio
async def test_run_summary_marks_failed_when_master_errors(
    db_session: Session,
    fake_llm: FakeLLMProvider,
    celery_eager: None,
) -> None:
    user, docs, doc = _ready_doc(db_session, subject="sum-fail")
    set_task_provider_overrides(llm=fake_llm)
    jobs = JobRepository(db_session)
    job = jobs.create(
        document_id=doc.id,
        job_type=SUMMARY_JOB_TYPE,
        status=JobStatus.queued,
    )

    with patch(
        "app.tasks.summary.run_master",
        new_callable=AsyncMock,
        return_value=AgentResult(success=False, error="boom"),
    ):
        with pytest.raises(RuntimeError, match="boom"):
            run_summary(doc.id, job.id)

    db_session.expire_all()
    assert jobs.get(job.id).status == JobStatus.failed
    assert docs.get(doc.id).summary_status == SummaryStatus.failed


@pytest.mark.asyncio
async def test_enqueue_summary_runs_eager_with_llm(
    db_session: Session,
    celery_eager: None,
) -> None:
    user, docs, doc = _ready_doc(db_session, subject="sum-eager")
    llm = FakeLLMProvider(
        response=json.dumps(
            {
                "short_summary": "Eager short",
                "detailed_summary": "Eager detailed",
            }
        )
    )
    set_task_provider_overrides(llm=llm)

    job_id = enqueue_summary(doc.id)

    db_session.expire_all()
    jobs = JobRepository(db_session)
    job = jobs.get(job_id)
    assert job is not None
    assert job.job_type == SUMMARY_JOB_TYPE
    assert job.status == JobStatus.succeeded
    refreshed = docs.get(doc.id)
    assert refreshed.summary_status == SummaryStatus.ready
    assert refreshed.short_summary == "Eager short"
    assert refreshed.detailed_summary == "Eager detailed"
    assert llm.prompts


def test_api_post_summary_not_ready(api_client: TestClient) -> None:
    headers = make_auth_header(sub="sum-api-nr", email="nr@example.com")
    create_resp = api_client.post(
        "/api/v1/documents",
        headers=headers,
        files={"file": ("lease.pdf", b"%PDF-lease", "application/pdf")},
        data={"title": "Lease"},
    )
    assert create_resp.status_code == 201
    doc_id = create_resp.json()["id"]

    # Force OCR incomplete for the not-ready gate
    from app.core.db import SessionLocal
    from app.repositories.document_repo import DocumentRepository as Repo

    session = SessionLocal()
    try:
        Repo(session).update(
            doc_id,
            status=DocumentStatus.processing,
            extracted_text=None,
            summary_status=SummaryStatus.idle,
        )
    finally:
        session.close()

    resp = api_client.post(f"/api/v1/documents/{doc_id}/summary", headers=headers)
    assert resp.status_code == 409
    assert "not ready" in resp.json()["detail"].lower()


def test_api_summary_happy_path(api_client: TestClient, fake_llm: FakeLLMProvider) -> None:
    headers = make_auth_header(sub="sum-api-ok", email="ok@example.com")
    create_resp = api_client.post(
        "/api/v1/documents",
        headers=headers,
        files={"file": ("lease.pdf", b"%PDF-lease", "application/pdf")},
        data={"title": "Lease"},
    )
    assert create_resp.status_code == 201
    doc_id = create_resp.json()["id"]

    fake_llm.response = json.dumps(
        {
            "short_summary": "API short",
            "detailed_summary": "API detailed body",
        }
    )
    set_task_provider_overrides(llm=fake_llm)

    post = api_client.post(f"/api/v1/documents/{doc_id}/summary", headers=headers)
    assert post.status_code == 202
    body = post.json()
    # Eager Celery may finish before response serialization
    assert body["summary_status"] in {"processing", "ready"}
    assert body["id"] == doc_id

    status_resp = api_client.get(
        f"/api/v1/documents/{doc_id}/summary/status", headers=headers
    )
    assert status_resp.status_code == 200
    assert status_resp.json()["summary_status"] == "ready"

    get_resp = api_client.get(f"/api/v1/documents/{doc_id}", headers=headers)
    assert get_resp.status_code == 200
    data = get_resp.json()
    assert data["short_summary"] == "API short"
    assert data["detailed_summary"] == "API detailed body"
    assert data["summary_status"] == "ready"


def test_api_summary_requires_auth(api_client: TestClient) -> None:
    assert api_client.post("/api/v1/documents/x/summary").status_code == 401
    assert api_client.get("/api/v1/documents/x/summary/status").status_code == 401


def test_openapi_lists_summary_paths(api_client: TestClient) -> None:
    spec = api_client.get("/openapi.json").json()
    paths = set(spec["paths"].keys())
    assert "/api/v1/documents/{document_id}/summary" in paths
    assert "/api/v1/documents/{document_id}/summary/status" in paths
    props = spec["components"]["schemas"]["DocumentResponse"]["properties"]
    assert "short_summary" in props
    assert "detailed_summary" in props
    assert "summary_status" in props
