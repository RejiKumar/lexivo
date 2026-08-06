"""Composable Celery units for document translation.

Translation runs via Master Agent → Translation Agent → LLMProvider
(no specialist import here). Status updates stay at the task layer.
"""

from __future__ import annotations

import asyncio
import concurrent.futures
from typing import Any

from app.adapters.notifications import SqlNotificationStore
from app.adapters.push import StubPushProvider
from app.agents.base_agent import AgentContext
from app.agents.master_agent import run_master
from app.core.db import SessionLocal, get_engine
from app.models import JobStatus, TranslationStatus
from app.repositories.document_repo import DocumentRepository
from app.repositories.job_repo import JobRepository
from app.services.notification_service import emit_job_complete_notification
from app.tasks.agent_errors import agent_failure_error
from app.tasks.celery_app import celery_app
from app.tasks.provider_overrides import get_task_llm_provider

TRANSLATION_JOB_TYPE = "translation"


def _run_async(coro: Any) -> Any:
    """Run a coroutine from sync Celery — safe if an event loop is already running."""
    try:
        asyncio.get_running_loop()
    except RuntimeError:
        return asyncio.run(coro)
    with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
        return pool.submit(asyncio.run, coro).result()


def enqueue_translation(document_id: str) -> str:
    """Create/update a translation job row and queue the run_translation task unit.

    Returns the job id.
    """
    get_engine()
    session = SessionLocal()
    try:
        jobs = JobRepository(session)
        existing = jobs.list(
            {"document_id": document_id, "job_type": TRANSLATION_JOB_TYPE}
        )
        if existing:
            job = existing[0]
            jobs.update(job.id, status=JobStatus.queued, error_message="")
            job_id = job.id
        else:
            job = jobs.create(
                document_id=document_id,
                job_type=TRANSLATION_JOB_TYPE,
                status=JobStatus.queued,
            )
            job_id = job.id
    finally:
        session.close()

    run_translation.delay(document_id, job_id)
    return job_id


@celery_app.task(name="app.tasks.translation.run_translation", bind=False)
def run_translation(document_id: str, job_id: str | None = None) -> dict[str, Any]:
    """Translation task unit: Master → Translation Agent; status updates remain here."""
    return _run_async(_run_translation_async(document_id, job_id))


async def _run_translation_async(
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
                {"document_id": document_id, "job_type": TRANSLATION_JOB_TYPE}
            )
            if not queued:
                job = jobs.create(
                    document_id=document_id,
                    job_type=TRANSLATION_JOB_TYPE,
                    status=JobStatus.running,
                )
                job_id = job.id
            else:
                job_id = queued[0].id

        jobs.update(job_id, status=JobStatus.running)
        docs.update(document_id, translation_status=TranslationStatus.processing)

        text = (document.extracted_text or "").strip()
        if not text:
            raise ValueError(f"Document {document_id} has no extracted_text")

        source_lang = (document.source_lang or "").strip().lower()
        target_lang = (document.target_lang or "").strip().lower()
        if not source_lang or not target_lang:
            raise ValueError(
                f"Document {document_id} missing source_lang/target_lang"
            )

        llm = get_task_llm_provider()
        context = AgentContext(
            document_id=document_id,
            job_id=job_id,
            user_id=document.user_id,
        )
        agent_result = await run_master(
            "translation",
            {
                "text": text,
                "source_lang": source_lang,
                "target_lang": target_lang,
                "document_id": document_id,
            },
            context,
            llm=llm,
        )

        if not agent_result.success:
            raise agent_failure_error(agent_result, "Translation agent failed")

        data = agent_result.data or {}
        translated_text = str(data.get("translated_text", ""))
        persisted_source = str(data.get("source_lang", source_lang))
        persisted_target = str(data.get("target_lang", target_lang))

        jobs.update(job_id, status=JobStatus.succeeded, error_message="")
        docs.update(
            document_id,
            translation_status=TranslationStatus.ready,
            translated_text=translated_text,
            source_lang=persisted_source,
            target_lang=persisted_target,
        )

        await emit_job_complete_notification(
            user_id=document.user_id,
            job_type=TRANSLATION_JOB_TYPE,
            document_id=document_id,
            job_id=job_id,
            notification_store=SqlNotificationStore(session),
            push=StubPushProvider(),
        )

        return {
            "document_id": document_id,
            "job_id": job_id,
            "translation_status": TranslationStatus.ready.value,
            "translated_length": len(translated_text),
            "source_lang": persisted_source,
            "target_lang": persisted_target,
        }
    except Exception as exc:
        if job_id is not None:
            jobs.update(
                job_id,
                status=JobStatus.failed,
                error_message=str(exc),
            )
        docs.update(document_id, translation_status=TranslationStatus.failed)
        raise
    finally:
        session.close()
