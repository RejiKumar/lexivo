"""Celery generate_embeddings task unit tests."""

from __future__ import annotations

from pathlib import Path

import pytest
from sqlalchemy.orm import Session

from app.models import DocumentStatus, JobStatus
from app.repositories.chunk_repo import DocumentChunkRepository
from app.repositories.document_repo import DocumentRepository
from app.repositories.job_repo import JobRepository
from app.repositories.user_repo import UserRepository
from app.tasks.celery_app import celery_app
from app.tasks.embeddings import (
    EMBEDDINGS_JOB_TYPE,
    enqueue_generate_embeddings,
    generate_embeddings,
)
from app.tasks.provider_overrides import set_task_provider_overrides
from tests.fakes import FakeEmbedder


def test_embeddings_task_registered() -> None:
    assert "app.tasks.embeddings.generate_embeddings" in celery_app.tasks


def test_embeddings_module_does_not_import_search_or_master() -> None:
    source = (
        Path(__file__).resolve().parents[1] / "app" / "tasks" / "embeddings.py"
    ).read_text(encoding="utf-8")
    assert "search_agent" not in source
    assert "citation_agent" not in source
    assert "master_agent" not in source
    assert "run_master" not in source
    assert "RagPipeline" in source


@pytest.mark.asyncio
async def test_generate_embeddings_ingests_document(
    db_session: Session,
    celery_eager: None,
) -> None:
    users = UserRepository(db_session)
    docs = DocumentRepository(db_session)
    owner = users.create(external_id="emb-u", email="emb@example.com")
    doc = docs.create(
        user_id=owner.id,
        title="Emb",
        status=DocumentStatus.ready,
        extracted_text="Embedding task body with enough text to chunk. " * 10,
    )
    fake = FakeEmbedder()
    set_task_provider_overrides(embedding=fake)

    jobs = JobRepository(db_session)
    job = jobs.create(
        document_id=doc.id,
        job_type=EMBEDDINGS_JOB_TYPE,
        status=JobStatus.queued,
    )

    payload = generate_embeddings(doc.id, job.id, "default")
    assert payload["chunk_count"] > 0
    db_session.expire_all()
    assert jobs.get(job.id).status == JobStatus.succeeded
    assert DocumentChunkRepository(db_session).list_by_document(doc.id)


@pytest.mark.asyncio
async def test_enqueue_generate_embeddings(
    db_session: Session,
    celery_eager: None,
) -> None:
    users = UserRepository(db_session)
    docs = DocumentRepository(db_session)
    owner = users.create(external_id="emb-u2", email="emb2@example.com")
    doc = docs.create(
        user_id=owner.id,
        title="Emb2",
        status=DocumentStatus.ready,
        extracted_text="Short body for enqueue path.",
    )
    set_task_provider_overrides(embedding=FakeEmbedder())
    job_id = enqueue_generate_embeddings(doc.id, "receipt")
    db_session.expire_all()
    job = JobRepository(db_session).get(job_id)
    assert job is not None
    assert job.status == JobStatus.succeeded
