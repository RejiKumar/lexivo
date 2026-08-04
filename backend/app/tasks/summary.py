"""Composable Celery units for document summarization.

Summary runs via Master Agent → Summary Agent → LLMProvider (no specialist import here).
Status updates stay at the task layer.
"""

from __future__ import annotations

import asyncio
import concurrent.futures
from typing import Any

from app.agents.base_agent import AgentContext
from app.agents.master_agent import run_master
from app.core.db import SessionLocal, get_engine
from app.models import JobStatus, SummaryStatus
from app.repositories.document_repo import DocumentRepository
from app.repositories.job_repo import JobRepository
from app.tasks.celery_app import celery_app
from app.tasks.provider_overrides import get_task_llm_provider

SUMMARY_JOB_TYPE = "summary"


def _run_async(coro: Any) -> Any:
    """Run a coroutine from sync Celery — safe if an event loop is already running."""
    try:
        asyncio.get_running_loop()
    except RuntimeError:
        return asyncio.run(coro)
    with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
        return pool.submit(asyncio.run, coro).result()


def enqueue_summary(document_id: str) -> str:
    """Create/update a summary job row and queue the run_summary task unit.

    Returns the job id.
    """
    get_engine()
    session = SessionLocal()
    try:
        jobs = JobRepository(session)
        existing = jobs.list(
            {"document_id": document_id, "job_type": SUMMARY_JOB_TYPE}
        )
        if existing:
            job = existing[0]
            jobs.update(job.id, status=JobStatus.queued, error_message="")
            job_id = job.id
        else:
            job = jobs.create(
                document_id=document_id,
                job_type=SUMMARY_JOB_TYPE,
                status=JobStatus.queued,
            )
            job_id = job.id
    finally:
        session.close()

    run_summary.delay(document_id, job_id)
    return job_id


@celery_app.task(name="app.tasks.summary.run_summary", bind=False)
def run_summary(document_id: str, job_id: str | None = None) -> dict[str, Any]:
    """Summary task unit: Master → Summary Agent; status updates remain here."""
    return _run_async(_run_summary_async(document_id, job_id))


async def _run_summary_async(
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
                {"document_id": document_id, "job_type": SUMMARY_JOB_TYPE}
            )
            if not queued:
                job = jobs.create(
                    document_id=document_id,
                    job_type=SUMMARY_JOB_TYPE,
                    status=JobStatus.running,
                )
                job_id = job.id
            else:
                job_id = queued[0].id

        jobs.update(job_id, status=JobStatus.running)
        docs.update(document_id, summary_status=SummaryStatus.processing)

        text = (document.extracted_text or "").strip()
        if not text:
            raise ValueError(f"Document {document_id} has no extracted_text")

        llm = get_task_llm_provider()
        context = AgentContext(
            document_id=document_id,
            job_id=job_id,
            user_id=document.user_id,
        )
        agent_result = await run_master(
            "summary",
            {"text": text, "document_id": document_id},
            context,
            llm=llm,
        )

        if not agent_result.success:
            raise RuntimeError(agent_result.error or "Summary agent failed")

        data = agent_result.data or {}
        short_summary = str(data.get("short_summary", ""))
        detailed_summary = str(data.get("detailed_summary", ""))

        jobs.update(job_id, status=JobStatus.succeeded, error_message="")
        docs.update(
            document_id,
            summary_status=SummaryStatus.ready,
            short_summary=short_summary,
            detailed_summary=detailed_summary,
        )

        return {
            "document_id": document_id,
            "job_id": job_id,
            "summary_status": SummaryStatus.ready.value,
            "short_length": len(short_summary),
            "detailed_length": len(detailed_summary),
        }
    except Exception as exc:
        if job_id is not None:
            jobs.update(
                job_id,
                status=JobStatus.failed,
                error_message=str(exc),
            )
        docs.update(document_id, summary_status=SummaryStatus.failed)
        raise
    finally:
        session.close()
