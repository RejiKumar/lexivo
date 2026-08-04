"""Composable Celery units for document upload/OCR.

OCR runs via Master Agent → OCR Agent → OCRProvider Protocol (no direct provider call here).
Status updates stay at the task layer.
"""

from __future__ import annotations

import asyncio
import concurrent.futures
import inspect
from typing import Any

import httpx

from app.adapters.protocols import StorageProvider
from app.agents.base_agent import AgentContext
from app.agents.master_agent import run_master
from app.core.db import SessionLocal, get_engine
from app.models import DocumentStatus, JobStatus
from app.repositories.document_repo import DocumentRepository
from app.repositories.job_repo import JobRepository
from app.tasks.celery_app import celery_app
from app.tasks.provider_overrides import get_task_ocr_provider, get_task_storage_provider

OCR_JOB_TYPE = "ocr"


def _run_async(coro: Any) -> Any:
    """Run a coroutine from sync Celery — safe if an event loop is already running."""
    try:
        asyncio.get_running_loop()
    except RuntimeError:
        return asyncio.run(coro)
    with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
        return pool.submit(asyncio.run, coro).result()


async def _load_document_bytes(storage: StorageProvider, key: str) -> bytes:
    """Load object bytes via optional get_object (fakes) or signed_url + HTTP."""
    getter = getattr(storage, "get_object", None)
    if callable(getter):
        result = getter(key)
        if inspect.isawaitable(result):
            return await result
        return result

    url = await storage.signed_url(key)
    async with httpx.AsyncClient() as client:
        response = await client.get(url, timeout=120.0)
        response.raise_for_status()
        return response.content


def enqueue_document_processing(document_id: str) -> str:
    """Create/update an OCR job row and queue the run_ocr task unit.

    Returns the job id. Signature stable for DocumentService callers.
    """
    get_engine()
    session = SessionLocal()
    try:
        jobs = JobRepository(session)
        existing = jobs.list(
            {"document_id": document_id, "job_type": OCR_JOB_TYPE}
        )
        if existing:
            job = existing[0]
            jobs.update(job.id, status=JobStatus.queued, error_message="")
            job_id = job.id
        else:
            job = jobs.create(
                document_id=document_id,
                job_type=OCR_JOB_TYPE,
                status=JobStatus.queued,
            )
            job_id = job.id
    finally:
        session.close()

    run_ocr.delay(document_id, job_id)
    return job_id


@celery_app.task(name="app.tasks.document_processing.run_ocr", bind=False)
def run_ocr(document_id: str, job_id: str | None = None) -> dict[str, Any]:
    """OCR task unit: Master → OCR Agent; status updates remain here."""
    return _run_async(_run_ocr_async(document_id, job_id))


async def _run_ocr_async(
    document_id: str,
    job_id: str | None = None,
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
                {"document_id": document_id, "job_type": OCR_JOB_TYPE}
            )
            if not queued:
                job = jobs.create(
                    document_id=document_id,
                    job_type=OCR_JOB_TYPE,
                    status=JobStatus.running,
                )
                job_id = job.id
            else:
                job_id = queued[0].id

        jobs.update(job_id, status=JobStatus.running)
        docs.update(document_id, status=DocumentStatus.processing)

        if not document.storage_key:
            raise ValueError(f"Document {document_id} has no storage_key")

        storage = get_task_storage_provider()
        ocr_provider = get_task_ocr_provider()
        file_bytes = await _load_document_bytes(storage, document.storage_key)

        context = AgentContext(
            document_id=document_id,
            job_id=job_id,
            user_id=document.user_id,
        )
        agent_result = await run_master(
            "ocr",
            {"file_bytes": file_bytes},
            context,
            ocr_provider=ocr_provider,
        )

        if not agent_result.success:
            raise RuntimeError(agent_result.error or "OCR agent failed")

        data = agent_result.data or {}
        pages = int(data.get("pages", 0))
        text = str(data.get("text", ""))

        jobs.update(job_id, status=JobStatus.succeeded, error_message="")
        # Persist OCR body for later RagPipeline.ingest (no RAG call here).
        docs.update(
            document_id,
            status=DocumentStatus.ready,
            extracted_text=text,
        )

        return {
            "document_id": document_id,
            "job_id": job_id,
            "status": DocumentStatus.ready.value,
            "pages": pages,
            "text_length": len(text),
        }
    except Exception as exc:
        if job_id is not None:
            jobs.update(
                job_id,
                status=JobStatus.failed,
                error_message=str(exc),
            )
        docs.update(document_id, status=DocumentStatus.failed)
        raise
    finally:
        session.close()
