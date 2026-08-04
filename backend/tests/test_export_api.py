"""Tests for export schemas, service, Celery task, and thin API routes."""

from __future__ import annotations

from pathlib import Path
from unittest.mock import AsyncMock, patch

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.adapters.types import UserIdentity
from app.agents.base_agent import AgentResult
from app.models import (
    ChatMessageRole,
    DocumentStatus,
    ExportStatus,
    JobStatus,
    SummaryStatus,
    TranslationStatus,
)
from app.repositories.chat_repo import ChatMessageRepository, ChatRepository
from app.repositories.document_repo import DocumentRepository
from app.repositories.export_repo import ExportRepository
from app.repositories.job_repo import JobRepository
from app.repositories.user_repo import UserRepository
from app.schemas import ExportRequest, ExportResponse
from app.services.base import ConflictError, NotFoundError, ValidationError
from app.services.export_service import ExportService, assemble_summary_text
from app.services.user_service import UserService
from app.tasks.export import EXPORT_JOB_TYPE, enqueue_export, run_export
from app.tasks.provider_overrides import set_task_provider_overrides
from tests.conftest import make_auth_header
from tests.fakes import FakeStorageProvider


def test_export_request_response_serialization() -> None:
    req = ExportRequest(
        include_summary=True,
        include_translation=False,
        include_chat=True,
    )
    assert req.model_dump() == {
        "include_summary": True,
        "include_translation": False,
        "include_chat": True,
    }

    resp = ExportResponse(
        id="e1",
        document_id="d1",
        include_summary=True,
        include_translation=False,
        include_chat=False,
        export_status="processing",
        storage_key=None,
        signed_url=None,
    )
    dumped = resp.model_dump()
    assert dumped["export_status"] == "processing"
    assert dumped["include_summary"] is True
    assert dumped["signed_url"] is None

    ready = ExportResponse(
        id="e2",
        document_id="d1",
        include_summary=True,
        include_translation=True,
        include_chat=True,
        export_status="ready",
        storage_key="exports/d1/e2.pdf",
        signed_url="https://signed.test/exports/d1/e2.pdf",
    )
    assert ready.model_dump()["signed_url"].startswith("https://")


def test_export_task_module_enters_via_master_only() -> None:
    source = (
        Path(__file__).resolve().parents[1] / "app" / "tasks" / "export.py"
    ).read_text(encoding="utf-8")
    assert "run_master" in source
    assert "from app.agents.master_agent import run_master" in source
    assert "ExportAgent" not in source
    assert "export_agent" not in source
    assert "app.agents.export_agent" not in source


def _seed_user_doc(
    db_session: Session,
    *,
    subject: str,
    summary: bool = True,
    translation: bool = True,
    chat: bool = True,
):
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject=subject, email=f"{subject}@example.com")
    )
    docs = DocumentRepository(db_session)
    fields: dict = {
        "user_id": user.id,
        "title": "Lease",
        "storage_key": "documents/u1/lease.pdf",
        "status": DocumentStatus.ready,
        "extracted_text": "OCR body",
    }
    if summary:
        fields.update(
            summary_status=SummaryStatus.ready,
            short_summary="Short summary",
            detailed_summary="Detailed summary body",
        )
    if translation:
        fields.update(
            translation_status=TranslationStatus.ready,
            translated_text="Texto traducido",
            source_lang="en",
            target_lang="es",
        )
    doc = docs.create(**fields)

    if chat:
        chats = ChatRepository(db_session)
        messages = ChatMessageRepository(db_session)
        thread = chats.create(user_id=user.id, document_id=doc.id)
        messages.add_message(
            chat_id=thread.id,
            role=ChatMessageRole.user,
            content="What is the rent?",
        )
        messages.add_message(
            chat_id=thread.id,
            role=ChatMessageRole.assistant,
            content="The rent is $1200.",
        )

    exports = ExportRepository(db_session)
    return user, docs, doc, exports


def _service(db_session: Session, enqueue=None) -> ExportService:
    return ExportService(
        ExportRepository(db_session),
        DocumentRepository(db_session),
        ChatRepository(db_session),
        ChatMessageRepository(db_session),
        enqueue_export=enqueue or (lambda _id: "job"),
    )


def test_assemble_summary_prefers_detailed() -> None:
    class Doc:
        short_summary = "Short"
        detailed_summary = "Detailed"

    assert assemble_summary_text(Doc()) == "Short\n\nDetailed"

    class OnlyDetailed:
        short_summary = None
        detailed_summary = "Only detailed"

    assert assemble_summary_text(OnlyDetailed()) == "Only detailed"


def test_export_service_rejects_zero_toggles(db_session: Session) -> None:
    user, _, doc, _ = _seed_user_doc(db_session, subject="exp-zero")
    with pytest.raises(ValidationError, match="At least one"):
        _service(db_session).request_export(
            document_id=doc.id,
            user_id=user.id,
            include_summary=False,
            include_translation=False,
            include_chat=False,
        )


def test_export_service_rejects_wrong_owner(db_session: Session) -> None:
    user, _, doc, _ = _seed_user_doc(db_session, subject="exp-owner")
    other = UserService(UserRepository(db_session)).upsert_from_identity(
        UserIdentity(subject="other-exp", email="other@example.com")
    )
    with pytest.raises(NotFoundError):
        _service(db_session).request_export(
            document_id=doc.id,
            user_id=other.id,
            include_summary=True,
        )


def test_export_service_rejects_summary_not_ready(db_session: Session) -> None:
    user, _, doc, _ = _seed_user_doc(
        db_session, subject="exp-sum-nr", summary=False, translation=False, chat=False
    )
    with pytest.raises(ConflictError, match="Summary is not ready"):
        _service(db_session).request_export(
            document_id=doc.id,
            user_id=user.id,
            include_summary=True,
        )


def test_export_service_rejects_translation_not_ready(db_session: Session) -> None:
    user, _, doc, _ = _seed_user_doc(
        db_session, subject="exp-tr-nr", translation=False, chat=False
    )
    with pytest.raises(ConflictError, match="Translation is not ready"):
        _service(db_session).request_export(
            document_id=doc.id,
            user_id=user.id,
            include_translation=True,
        )


def test_export_service_rejects_empty_chat(db_session: Session) -> None:
    user, _, doc, _ = _seed_user_doc(
        db_session, subject="exp-chat-nr", chat=False
    )
    with pytest.raises(ConflictError, match="No chat messages"):
        _service(db_session).request_export(
            document_id=doc.id,
            user_id=user.id,
            include_chat=True,
        )


def test_export_service_sets_processing_and_enqueues(db_session: Session) -> None:
    user, _, doc, exports = _seed_user_doc(db_session, subject="exp-ok")
    enqueued: list[str] = []
    service = _service(
        db_session,
        enqueue=lambda export_id: enqueued.append(export_id) or "job-1",
    )
    created = service.request_export(
        document_id=doc.id,
        user_id=user.id,
        include_summary=True,
        include_translation=True,
        include_chat=True,
    )
    assert created.status == ExportStatus.processing
    assert created.include_summary is True
    assert enqueued == [created.id]
    assert exports.get(created.id) is not None


@pytest.mark.asyncio
async def test_run_export_uses_master_and_persists(
    db_session: Session,
    fake_storage: FakeStorageProvider,
    celery_eager: None,
) -> None:
    user, _, doc, exports = _seed_user_doc(db_session, subject="exp-master")
    export = exports.create(
        user_id=user.id,
        document_id=doc.id,
        include_summary=True,
        include_translation=True,
        include_chat=True,
        status=ExportStatus.processing,
    )
    set_task_provider_overrides(storage=fake_storage)

    jobs = JobRepository(db_session)
    job = jobs.create(
        document_id=doc.id,
        job_type=EXPORT_JOB_TYPE,
        status=JobStatus.queued,
    )

    master_result = AgentResult(
        success=True,
        data={
            "storage_key": f"exports/{doc.id}/{export.id}.pdf",
            "signed_url": f"https://signed.test/exports/{doc.id}/{export.id}.pdf",
        },
    )
    with patch(
        "app.tasks.export.run_master",
        new_callable=AsyncMock,
        return_value=master_result,
    ) as master_mock:
        payload = run_export(export.id, job.id)

    master_mock.assert_awaited_once()
    call = master_mock.await_args
    assert call.args[0] == "export"
    assert call.args[1]["include_summary"] is True
    assert call.args[1]["include_translation"] is True
    assert call.args[1]["include_chat"] is True
    assert "summary" in call.args[1]
    assert "translation" in call.args[1]
    assert "chat" in call.args[1]
    assert "User:" in call.args[1]["chat"]
    assert call.kwargs["storage"] is fake_storage

    db_session.expire_all()
    assert jobs.get(job.id).status == JobStatus.succeeded
    ready = exports.get(export.id)
    assert ready.status == ExportStatus.ready
    assert ready.signed_url.startswith("https://")
    assert payload["export_status"] == "ready"


@pytest.mark.asyncio
async def test_run_export_summary_only_omits_other_sections(
    db_session: Session,
    fake_storage: FakeStorageProvider,
    celery_eager: None,
) -> None:
    user, _, doc, exports = _seed_user_doc(db_session, subject="exp-sum-only")
    export = exports.create(
        user_id=user.id,
        document_id=doc.id,
        include_summary=True,
        include_translation=False,
        include_chat=False,
        status=ExportStatus.processing,
    )
    set_task_provider_overrides(storage=fake_storage)
    jobs = JobRepository(db_session)
    job = jobs.create(
        document_id=doc.id,
        job_type=EXPORT_JOB_TYPE,
        status=JobStatus.queued,
    )

    with patch(
        "app.tasks.export.run_master",
        new_callable=AsyncMock,
        return_value=AgentResult(
            success=True,
            data={
                "storage_key": "exports/x.pdf",
                "signed_url": "https://signed.test/exports/x.pdf",
            },
        ),
    ) as master_mock:
        run_export(export.id, job.id)

    payload = master_mock.await_args.args[1]
    assert payload["include_summary"] is True
    assert payload["include_translation"] is False
    assert payload["include_chat"] is False
    assert "summary" in payload
    assert "translation" not in payload
    assert "chat" not in payload


@pytest.mark.asyncio
async def test_run_export_marks_failed_when_master_errors(
    db_session: Session,
    fake_storage: FakeStorageProvider,
    celery_eager: None,
) -> None:
    user, _, doc, exports = _seed_user_doc(db_session, subject="exp-fail")
    export = exports.create(
        user_id=user.id,
        document_id=doc.id,
        include_summary=True,
        status=ExportStatus.processing,
    )
    set_task_provider_overrides(storage=fake_storage)
    jobs = JobRepository(db_session)
    job = jobs.create(
        document_id=doc.id,
        job_type=EXPORT_JOB_TYPE,
        status=JobStatus.queued,
    )

    with patch(
        "app.tasks.export.run_master",
        new_callable=AsyncMock,
        return_value=AgentResult(success=False, error="boom"),
    ):
        with pytest.raises(RuntimeError, match="boom"):
            run_export(export.id, job.id)

    db_session.expire_all()
    assert jobs.get(job.id).status == JobStatus.failed
    assert exports.get(export.id).status == ExportStatus.failed


@pytest.mark.asyncio
async def test_enqueue_export_runs_eager_with_storage(
    db_session: Session,
    fake_storage: FakeStorageProvider,
    celery_eager: None,
) -> None:
    user, _, doc, exports = _seed_user_doc(db_session, subject="exp-eager")
    export = exports.create(
        user_id=user.id,
        document_id=doc.id,
        include_summary=True,
        include_translation=False,
        include_chat=False,
        status=ExportStatus.processing,
    )
    set_task_provider_overrides(storage=fake_storage)

    job_id = enqueue_export(export.id)

    db_session.expire_all()
    jobs = JobRepository(db_session)
    job = jobs.get(job_id)
    assert job is not None
    assert job.job_type == EXPORT_JOB_TYPE
    assert job.status == JobStatus.succeeded
    refreshed = exports.get(export.id)
    assert refreshed.status == ExportStatus.ready
    assert refreshed.signed_url
    assert refreshed.storage_key
    assert any(k.startswith("exports/") for k in fake_storage.objects)


def _seed_api_doc(api_client: TestClient, headers: dict) -> str:
    from app.core.db import SessionLocal

    create_resp = api_client.post(
        "/api/v1/documents",
        headers=headers,
        files={"file": ("lease.pdf", b"%PDF-lease", "application/pdf")},
        data={"title": "Lease"},
    )
    assert create_resp.status_code == 201
    doc_id = create_resp.json()["id"]

    session = SessionLocal()
    try:
        docs = DocumentRepository(session)
        docs.update(
            doc_id,
            status=DocumentStatus.ready,
            extracted_text="OCR body",
            summary_status=SummaryStatus.ready,
            short_summary="Short",
            detailed_summary="Detailed",
            translation_status=TranslationStatus.ready,
            translated_text="Traducido",
            source_lang="en",
            target_lang="es",
        )
        # Resolve user via document
        doc = docs.get(doc_id)
        assert doc is not None
        chats = ChatRepository(session)
        messages = ChatMessageRepository(session)
        thread = chats.create(user_id=doc.user_id, document_id=doc_id)
        messages.add_message(
            chat_id=thread.id,
            role=ChatMessageRole.user,
            content="Hello?",
        )
        messages.add_message(
            chat_id=thread.id,
            role=ChatMessageRole.assistant,
            content="Hi there.",
        )
    finally:
        session.close()
    return doc_id


def test_api_post_export_no_toggles_422(api_client: TestClient) -> None:
    headers = make_auth_header(sub="exp-api-422", email="e422@example.com")
    doc_id = _seed_api_doc(api_client, headers)
    resp = api_client.post(
        f"/api/v1/documents/{doc_id}/export",
        headers=headers,
        json={
            "include_summary": False,
            "include_translation": False,
            "include_chat": False,
        },
    )
    assert resp.status_code == 422
    assert "toggle" in resp.json()["detail"].lower()


def test_api_post_export_section_not_ready_409(api_client: TestClient) -> None:
    headers = make_auth_header(sub="exp-api-409", email="e409@example.com")
    create_resp = api_client.post(
        "/api/v1/documents",
        headers=headers,
        files={"file": ("lease.pdf", b"%PDF-lease", "application/pdf")},
        data={"title": "Lease"},
    )
    doc_id = create_resp.json()["id"]

    from app.core.db import SessionLocal

    session = SessionLocal()
    try:
        DocumentRepository(session).update(
            doc_id,
            status=DocumentStatus.ready,
            extracted_text="body",
            summary_status=SummaryStatus.idle,
        )
    finally:
        session.close()

    resp = api_client.post(
        f"/api/v1/documents/{doc_id}/export",
        headers=headers,
        json={"include_summary": True},
    )
    assert resp.status_code == 409
    assert "summary" in resp.json()["detail"].lower()


def test_api_export_happy_path(
    api_client: TestClient, fake_storage: FakeStorageProvider
) -> None:
    headers = make_auth_header(sub="exp-api-ok", email="eok@example.com")
    doc_id = _seed_api_doc(api_client, headers)
    set_task_provider_overrides(storage=fake_storage)

    post = api_client.post(
        f"/api/v1/documents/{doc_id}/export",
        headers=headers,
        json={
            "include_summary": True,
            "include_translation": True,
            "include_chat": True,
        },
    )
    assert post.status_code == 202
    body = post.json()
    assert body["export_status"] in {"processing", "ready"}
    assert body["document_id"] == doc_id
    assert body["include_summary"] is True
    export_id = body["id"]

    status_resp = api_client.get(
        f"/api/v1/documents/{doc_id}/export/status", headers=headers
    )
    assert status_resp.status_code == 200
    status_body = status_resp.json()
    assert status_body["export_status"] == "ready"
    assert status_body["signed_url"]
    assert status_body["signed_url"].startswith("https://")

    by_id = api_client.get(f"/api/v1/exports/{export_id}", headers=headers)
    assert by_id.status_code == 200
    assert by_id.json()["signed_url"] == status_body["signed_url"]


def test_api_export_failed_allows_retry(
    api_client: TestClient, fake_storage: FakeStorageProvider
) -> None:
    headers = make_auth_header(sub="exp-api-retry", email="retry@example.com")
    doc_id = _seed_api_doc(api_client, headers)

    from app.core.db import SessionLocal

    session = SessionLocal()
    try:
        doc = DocumentRepository(session).get(doc_id)
        assert doc is not None
        ExportRepository(session).create(
            user_id=doc.user_id,
            document_id=doc_id,
            include_summary=True,
            status=ExportStatus.failed,
            error_message="pdf boom",
        )
    finally:
        session.close()

    failed_status = api_client.get(
        f"/api/v1/documents/{doc_id}/export/status", headers=headers
    )
    assert failed_status.status_code == 200
    assert failed_status.json()["export_status"] == "failed"

    set_task_provider_overrides(storage=fake_storage)
    retry = api_client.post(
        f"/api/v1/documents/{doc_id}/export",
        headers=headers,
        json={"include_summary": True},
    )
    assert retry.status_code == 202
    retry_body = retry.json()
    assert retry_body["id"] != failed_status.json()["id"]
    assert retry_body["export_status"] in {"processing", "ready"}

    status_resp = api_client.get(
        f"/api/v1/documents/{doc_id}/export/status", headers=headers
    )
    assert status_resp.status_code == 200
    assert status_resp.json()["id"] == retry_body["id"]
    assert status_resp.json()["export_status"] == "ready"
    assert status_resp.json()["signed_url"]


def test_api_export_requires_auth(api_client: TestClient) -> None:
    assert (
        api_client.post(
            "/api/v1/documents/x/export",
            json={"include_summary": True},
        ).status_code
        == 401
    )
    assert api_client.get("/api/v1/documents/x/export/status").status_code == 401
    assert api_client.get("/api/v1/exports/x").status_code == 401


def test_openapi_lists_export_paths(api_client: TestClient) -> None:
    spec = api_client.get("/openapi.json").json()
    paths = set(spec["paths"].keys())
    assert "/api/v1/documents/{document_id}/export" in paths
    assert "/api/v1/documents/{document_id}/export/status" in paths
    assert "/api/v1/exports/{export_id}" in paths
    schemas = spec["components"]["schemas"]
    assert "ExportRequest" in schemas
    assert "ExportResponse" in schemas
    props = schemas["ExportResponse"]["properties"]
    assert "export_status" in props
    assert "signed_url" in props
    assert "include_summary" in props
