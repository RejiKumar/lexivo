"""Tests for translation schemas, service, Celery task, and thin API routes."""

from __future__ import annotations

from pathlib import Path
from unittest.mock import AsyncMock, patch

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.adapters.types import UserIdentity
from app.agents.base_agent import AgentResult
from app.models import DocumentStatus, JobStatus, TranslationStatus
from app.repositories.document_repo import DocumentRepository
from app.repositories.job_repo import JobRepository
from app.repositories.user_repo import UserRepository
from app.schemas import DocumentResponse, TranslationRequest, TranslationStatusResponse
from app.services.base import ConflictError, NotFoundError, ValidationError
from app.services.translation_service import TranslationService
from app.services.user_service import UserService
from app.tasks.provider_overrides import set_task_provider_overrides
from app.tasks.translation import (
    TRANSLATION_JOB_TYPE,
    enqueue_translation,
    run_translation,
)
from tests.conftest import make_auth_header
from tests.fakes import FakeLLMProvider


def test_document_response_includes_translation_fields() -> None:
    doc = DocumentResponse(
        id="d1",
        user_id="u1",
        title="Lease",
        storage_key="documents/u1/lease.pdf",
        status="ready",
        extracted_text="body",
        translated_text="cuerpo",
        source_lang="en",
        target_lang="es",
        translation_status="ready",
        created_at=None,
        updated_at=None,
    )
    dumped = doc.model_dump()
    assert dumped["translated_text"] == "cuerpo"
    assert dumped["source_lang"] == "en"
    assert dumped["target_lang"] == "es"
    assert dumped["translation_status"] == "ready"

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
    assert idle.translation_status == "idle"
    assert idle.translated_text is None
    assert idle.source_lang is None

    status = TranslationStatusResponse(
        id="d1",
        translation_status="processing",
        source_lang="en",
        target_lang="fr",
    )
    assert status.model_dump() == {
        "id": "d1",
        "translation_status": "processing",
        "source_lang": "en",
        "target_lang": "fr",
    }

    req = TranslationRequest(source_lang="en", target_lang="de")
    assert req.model_dump() == {"source_lang": "en", "target_lang": "de"}


def test_translation_task_module_enters_via_master_only() -> None:
    source = (
        Path(__file__).resolve().parents[1] / "app" / "tasks" / "translation.py"
    ).read_text(encoding="utf-8")
    assert "run_master" in source
    assert "from app.agents.master_agent import run_master" in source
    assert "TranslationAgent" not in source
    assert "translation_agent" not in source
    assert "app.agents.translation_agent" not in source


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
        translation_status=TranslationStatus.idle,
    )
    return user, docs, doc


def test_translation_service_rejects_not_ready(db_session: Session) -> None:
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="tr-nr", email="nr@example.com")
    )
    docs = DocumentRepository(db_session)
    doc = docs.create(
        user_id=user.id,
        title="Processing",
        status=DocumentStatus.processing,
        extracted_text=None,
    )
    service = TranslationService(docs, enqueue_translation=lambda _id: "job")
    with pytest.raises(ConflictError, match="not ready"):
        service.request_translation(
            document_id=doc.id,
            user_id=user.id,
            source_lang="en",
            target_lang="es",
        )


def test_translation_service_rejects_empty_extracted_text(db_session: Session) -> None:
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="tr-empty", email="empty@example.com")
    )
    docs = DocumentRepository(db_session)
    doc = docs.create(
        user_id=user.id,
        title="Empty",
        status=DocumentStatus.ready,
        extracted_text="   ",
    )
    service = TranslationService(docs, enqueue_translation=lambda _id: "job")
    with pytest.raises(ConflictError, match="extracted text"):
        service.request_translation(
            document_id=doc.id,
            user_id=user.id,
            source_lang="en",
            target_lang="es",
        )


def test_translation_service_rejects_wrong_owner(db_session: Session) -> None:
    user, docs, doc = _ready_doc(db_session, subject="tr-owner")
    other = UserService(UserRepository(db_session)).upsert_from_identity(
        UserIdentity(subject="other", email="other@example.com")
    )
    service = TranslationService(docs, enqueue_translation=lambda _id: "job")
    with pytest.raises(NotFoundError):
        service.request_translation(
            document_id=doc.id,
            user_id=other.id,
            source_lang="en",
            target_lang="es",
        )


@pytest.mark.parametrize(
    "source_lang,target_lang,match",
    [
        ("en", "en", "must differ"),
        ("es", "fr", "English"),
        ("xx", "en", "Unsupported language"),
        ("en", "zh", "Unsupported language"),
    ],
)
def test_translation_service_rejects_invalid_langs(
    db_session: Session,
    source_lang: str,
    target_lang: str,
    match: str,
) -> None:
    user, docs, doc = _ready_doc(db_session, subject=f"tr-lang-{source_lang}-{target_lang}")
    service = TranslationService(docs, enqueue_translation=lambda _id: "job")
    with pytest.raises(ValidationError, match=match):
        service.request_translation(
            document_id=doc.id,
            user_id=user.id,
            source_lang=source_lang,
            target_lang=target_lang,
        )


def test_translation_service_sets_processing_and_enqueues(db_session: Session) -> None:
    user, docs, doc = _ready_doc(db_session, subject="tr-ok")
    enqueued: list[str] = []
    service = TranslationService(
        docs,
        enqueue_translation=lambda doc_id: enqueued.append(doc_id) or "job-1",
    )
    updated = service.request_translation(
        document_id=doc.id,
        user_id=user.id,
        source_lang="en",
        target_lang="es",
    )
    assert updated.translation_status == TranslationStatus.processing
    assert updated.source_lang == "en"
    assert updated.target_lang == "es"
    assert updated.translated_text is None
    assert enqueued == [doc.id]


@pytest.mark.asyncio
async def test_run_translation_uses_master_and_persists(
    db_session: Session,
    fake_llm: FakeLLMProvider,
    celery_eager: None,
) -> None:
    user, docs, doc = _ready_doc(db_session, subject="tr-master")
    docs.update(
        doc.id,
        source_lang="en",
        target_lang="es",
        translation_status=TranslationStatus.processing,
    )
    set_task_provider_overrides(llm=fake_llm)

    jobs = JobRepository(db_session)
    job = jobs.create(
        document_id=doc.id,
        job_type=TRANSLATION_JOB_TYPE,
        status=JobStatus.queued,
    )

    master_result = AgentResult(
        success=True,
        data={
            "translated_text": "Texto traducido",
            "source_lang": "en",
            "target_lang": "es",
        },
    )
    with patch(
        "app.tasks.translation.run_master",
        new_callable=AsyncMock,
        return_value=master_result,
    ) as master_mock:
        payload = run_translation(doc.id, job.id)

    master_mock.assert_awaited_once()
    call = master_mock.await_args
    assert call.args[0] == "translation"
    assert call.args[1]["text"] == "OCR body"
    assert call.args[1]["source_lang"] == "en"
    assert call.args[1]["target_lang"] == "es"
    assert call.args[1]["document_id"] == doc.id
    assert call.kwargs["llm"] is fake_llm

    db_session.expire_all()
    assert jobs.get(job.id).status == JobStatus.succeeded
    ready = docs.get(doc.id)
    assert ready.translation_status == TranslationStatus.ready
    assert ready.translated_text == "Texto traducido"
    assert ready.source_lang == "en"
    assert ready.target_lang == "es"
    assert payload["translation_status"] == "ready"


@pytest.mark.asyncio
async def test_run_translation_marks_failed_when_master_errors(
    db_session: Session,
    fake_llm: FakeLLMProvider,
    celery_eager: None,
) -> None:
    user, docs, doc = _ready_doc(db_session, subject="tr-fail")
    docs.update(
        doc.id,
        source_lang="en",
        target_lang="fr",
        translation_status=TranslationStatus.processing,
    )
    set_task_provider_overrides(llm=fake_llm)
    jobs = JobRepository(db_session)
    job = jobs.create(
        document_id=doc.id,
        job_type=TRANSLATION_JOB_TYPE,
        status=JobStatus.queued,
    )

    with patch(
        "app.tasks.translation.run_master",
        new_callable=AsyncMock,
        return_value=AgentResult(success=False, error="boom"),
    ):
        with pytest.raises(RuntimeError, match="boom"):
            run_translation(doc.id, job.id)

    db_session.expire_all()
    assert jobs.get(job.id).status == JobStatus.failed
    assert docs.get(doc.id).translation_status == TranslationStatus.failed


@pytest.mark.asyncio
async def test_enqueue_translation_runs_eager_with_llm(
    db_session: Session,
    celery_eager: None,
) -> None:
    user, docs, doc = _ready_doc(db_session, subject="tr-eager")
    docs.update(doc.id, source_lang="en", target_lang="de")
    llm = FakeLLMProvider(response="Deutsche Übersetzung")
    set_task_provider_overrides(llm=llm)

    job_id = enqueue_translation(doc.id)

    db_session.expire_all()
    jobs = JobRepository(db_session)
    job = jobs.get(job_id)
    assert job is not None
    assert job.job_type == TRANSLATION_JOB_TYPE
    assert job.status == JobStatus.succeeded
    refreshed = docs.get(doc.id)
    assert refreshed.translation_status == TranslationStatus.ready
    assert refreshed.translated_text == "Deutsche Übersetzung"
    assert llm.prompts


def test_api_post_translation_not_ready(api_client: TestClient) -> None:
    headers = make_auth_header(sub="tr-api-nr", email="nr@example.com")
    create_resp = api_client.post(
        "/api/v1/documents",
        headers=headers,
        files={"file": ("lease.pdf", b"%PDF-lease", "application/pdf")},
        data={"title": "Lease"},
    )
    assert create_resp.status_code == 201
    doc_id = create_resp.json()["id"]

    from app.core.db import SessionLocal
    from app.repositories.document_repo import DocumentRepository as Repo

    session = SessionLocal()
    try:
        Repo(session).update(
            doc_id,
            status=DocumentStatus.processing,
            extracted_text=None,
            translation_status=TranslationStatus.idle,
        )
    finally:
        session.close()

    resp = api_client.post(
        f"/api/v1/documents/{doc_id}/translation",
        headers=headers,
        json={"source_lang": "en", "target_lang": "es"},
    )
    assert resp.status_code == 409
    assert "not ready" in resp.json()["detail"].lower()


def test_api_post_translation_unsupported_lang(api_client: TestClient) -> None:
    headers = make_auth_header(sub="tr-api-lang", email="lang@example.com")
    create_resp = api_client.post(
        "/api/v1/documents",
        headers=headers,
        files={"file": ("lease.pdf", b"%PDF-lease", "application/pdf")},
        data={"title": "Lease"},
    )
    assert create_resp.status_code == 201
    doc_id = create_resp.json()["id"]

    # Pydantic rejects unknown literal before service (422)
    resp = api_client.post(
        f"/api/v1/documents/{doc_id}/translation",
        headers=headers,
        json={"source_lang": "en", "target_lang": "zh"},
    )
    assert resp.status_code == 422


def test_api_post_translation_same_lang_pair(api_client: TestClient) -> None:
    headers = make_auth_header(sub="tr-api-same", email="same@example.com")
    create_resp = api_client.post(
        "/api/v1/documents",
        headers=headers,
        files={"file": ("lease.pdf", b"%PDF-lease", "application/pdf")},
        data={"title": "Lease"},
    )
    assert create_resp.status_code == 201
    doc_id = create_resp.json()["id"]

    resp = api_client.post(
        f"/api/v1/documents/{doc_id}/translation",
        headers=headers,
        json={"source_lang": "en", "target_lang": "en"},
    )
    assert resp.status_code == 422
    assert "differ" in resp.json()["detail"].lower()


def test_api_translation_happy_path(
    api_client: TestClient, fake_llm: FakeLLMProvider
) -> None:
    headers = make_auth_header(sub="tr-api-ok", email="ok@example.com")
    create_resp = api_client.post(
        "/api/v1/documents",
        headers=headers,
        files={"file": ("lease.pdf", b"%PDF-lease", "application/pdf")},
        data={"title": "Lease"},
    )
    assert create_resp.status_code == 201
    doc_id = create_resp.json()["id"]

    fake_llm.response = "Texto traducido via API"
    set_task_provider_overrides(llm=fake_llm)

    post = api_client.post(
        f"/api/v1/documents/{doc_id}/translation",
        headers=headers,
        json={"source_lang": "en", "target_lang": "es"},
    )
    assert post.status_code == 202
    body = post.json()
    assert body["translation_status"] in {"processing", "ready"}
    assert body["id"] == doc_id
    assert body["source_lang"] == "en"
    assert body["target_lang"] == "es"

    status_resp = api_client.get(
        f"/api/v1/documents/{doc_id}/translation/status", headers=headers
    )
    assert status_resp.status_code == 200
    assert status_resp.json()["translation_status"] == "ready"

    get_resp = api_client.get(f"/api/v1/documents/{doc_id}", headers=headers)
    assert get_resp.status_code == 200
    data = get_resp.json()
    assert data["translated_text"] == "Texto traducido via API"
    assert data["translation_status"] == "ready"
    assert data["source_lang"] == "en"
    assert data["target_lang"] == "es"


def test_api_translation_requires_auth(api_client: TestClient) -> None:
    assert (
        api_client.post(
            "/api/v1/documents/x/translation",
            json={"source_lang": "en", "target_lang": "es"},
        ).status_code
        == 401
    )
    assert api_client.get("/api/v1/documents/x/translation/status").status_code == 401


def test_openapi_lists_translation_paths(api_client: TestClient) -> None:
    spec = api_client.get("/openapi.json").json()
    paths = set(spec["paths"].keys())
    assert "/api/v1/documents/{document_id}/translation" in paths
    assert "/api/v1/documents/{document_id}/translation/status" in paths
    props = spec["components"]["schemas"]["DocumentResponse"]["properties"]
    assert "translated_text" in props
    assert "source_lang" in props
    assert "target_lang" in props
    assert "translation_status" in props
    assert "TranslationRequest" in spec["components"]["schemas"]
    assert "TranslationStatusResponse" in spec["components"]["schemas"]
