"""Thin Celery unit: generate_embeddings → RagPipeline.ingest.

Composable; does not import Search/Citation agents or require Master.
"""

from __future__ import annotations

import asyncio
import concurrent.futures
from typing import Any

from app.core.db import SessionLocal, get_engine
from app.models import JobStatus
from app.rag.chunker import Chunker
from app.rag.context_builder import ContextBuilder
from app.rag.embedder import Embedder
from app.rag.pipeline import RagPipeline
from app.rag.presets import resolve_config
from app.rag.retriever import HybridRetriever
from app.repositories.chunk_repo import DocumentChunkRepository
from app.repositories.document_repo import DocumentRepository
from app.repositories.job_repo import JobRepository
from app.tasks.celery_app import celery_app
from app.tasks.provider_overrides import get_task_embedding_provider

EMBEDDINGS_JOB_TYPE = "generate_embeddings"


def _run_async(coro: Any) -> Any:
    try:
        asyncio.get_running_loop()
    except RuntimeError:
        return asyncio.run(coro)
    with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
        return pool.submit(asyncio.run, coro).result()


def enqueue_generate_embeddings(
    document_id: str,
    config: str | dict | None = None,
) -> str:
    """Create/update embeddings job and queue generate_embeddings."""
    get_engine()
    session = SessionLocal()
    try:
        jobs = JobRepository(session)
        existing = jobs.list(
            {"document_id": document_id, "job_type": EMBEDDINGS_JOB_TYPE}
        )
        if existing:
            job = existing[0]
            jobs.update(job.id, status=JobStatus.queued, error_message="")
            job_id = job.id
        else:
            job = jobs.create(
                document_id=document_id,
                job_type=EMBEDDINGS_JOB_TYPE,
                status=JobStatus.queued,
            )
            job_id = job.id
    finally:
        session.close()

    generate_embeddings.delay(document_id, job_id, config)
    return job_id


@celery_app.task(name="app.tasks.embeddings.generate_embeddings", bind=False)
def generate_embeddings(
    document_id: str,
    job_id: str | None = None,
    config: str | dict | None = None,
) -> dict[str, Any]:
    """Load document extracted_text, resolve RagConfig, call RagPipeline.ingest."""
    return _run_async(_generate_embeddings_async(document_id, job_id, config))


async def _generate_embeddings_async(
    document_id: str,
    job_id: str | None,
    config: str | dict | None,
) -> dict[str, Any]:
    get_engine()
    session = SessionLocal()
    docs = DocumentRepository(session)
    jobs = JobRepository(session)
    try:
        document = docs.get(document_id)
        if document is None:
            raise ValueError(f"Document not found: {document_id}")

        if job_id is None:
            queued = jobs.list(
                {"document_id": document_id, "job_type": EMBEDDINGS_JOB_TYPE}
            )
            if not queued:
                job = jobs.create(
                    document_id=document_id,
                    job_type=EMBEDDINGS_JOB_TYPE,
                    status=JobStatus.running,
                )
                job_id = job.id
            else:
                job_id = queued[0].id

        jobs.update(job_id, status=JobStatus.running)

        rag_config = resolve_config(config or "default")
        provider = get_task_embedding_provider()
        pipeline = RagPipeline(
            chunker=Chunker(),
            embedder=Embedder(provider),
            retriever=HybridRetriever(session),
            context_builder=ContextBuilder(),
            chunk_store=DocumentChunkRepository(session),
            default_config=rag_config,
        )
        await pipeline.ingest(document, rag_config)

        chunk_count = len(DocumentChunkRepository(session).list_by_document(document_id))
        jobs.update(job_id, status=JobStatus.succeeded, error_message="")
        return {
            "document_id": document_id,
            "job_id": job_id,
            "status": JobStatus.succeeded.value,
            "chunk_count": chunk_count,
        }
    except Exception as exc:
        if job_id is not None:
            jobs.update(
                job_id,
                status=JobStatus.failed,
                error_message=str(exc),
            )
        raise
    finally:
        session.close()
