"""Composable Celery units for PDF export.

Export runs via Master Agent → Export Agent → StorageProvider (no specialist import).
Status updates stay at the task/service layer.
"""

from __future__ import annotations

import asyncio
import concurrent.futures
from typing import Any

from app.agents.base_agent import AgentContext
from app.agents.master_agent import run_master
from app.core.db import SessionLocal, get_engine
from app.models import ExportStatus, JobStatus
from app.repositories.chat_repo import ChatMessageRepository, ChatRepository
from app.repositories.document_repo import DocumentRepository
from app.repositories.export_repo import ExportRepository
from app.repositories.job_repo import JobRepository
from app.services.export_service import assemble_summary_text, format_chat_annotations
from app.tasks.celery_app import celery_app
from app.tasks.provider_overrides import get_task_storage_provider

EXPORT_JOB_TYPE = "export"


def _run_async(coro: Any) -> Any:
    """Run a coroutine from sync Celery — safe if an event loop is already running."""
    try:
        asyncio.get_running_loop()
    except RuntimeError:
        return asyncio.run(coro)
    with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
        return pool.submit(asyncio.run, coro).result()


def enqueue_export(export_id: str) -> str:
    """Create/update an export job row and queue the run_export task unit.

    Returns the job id.
    """
    get_engine()
    session = SessionLocal()
    try:
        exports = ExportRepository(session)
        export = exports.get(export_id)
        if export is None:
            raise ValueError(f"Export not found: {export_id}")
        document_id = export.document_id

        jobs = JobRepository(session)
        existing = jobs.list(
            {"document_id": document_id, "job_type": EXPORT_JOB_TYPE}
        )
        if existing:
            job = existing[0]
            jobs.update(job.id, status=JobStatus.queued, error_message="")
            job_id = job.id
        else:
            job = jobs.create(
                document_id=document_id,
                job_type=EXPORT_JOB_TYPE,
                status=JobStatus.queued,
            )
            job_id = job.id
    finally:
        session.close()

    run_export.delay(export_id, job_id)
    return job_id


@celery_app.task(name="app.tasks.export.run_export", bind=False)
def run_export(export_id: str, job_id: str | None = None) -> dict[str, Any]:
    """Export task unit: assemble content → Master → Export Agent; persist signed URL."""
    return _run_async(_run_export_async(export_id, job_id))


async def _run_export_async(
    export_id: str,
    job_id: str | None = None,
) -> dict[str, Any]:
    get_engine()
    session = SessionLocal()
    exports = ExportRepository(session)
    docs = DocumentRepository(session)
    chats = ChatRepository(session)
    messages = ChatMessageRepository(session)
    jobs = JobRepository(session)
    document_id: str | None = None
    try:
        export = exports.get(export_id)
        if export is None:
            raise ValueError(f"Export not found: {export_id}")
        document_id = export.document_id

        document = docs.get(document_id)
        if document is None:
            raise ValueError(f"Document not found: {document_id}")

        if job_id is None:
            queued = jobs.list(
                {"document_id": document_id, "job_type": EXPORT_JOB_TYPE}
            )
            if not queued:
                job = jobs.create(
                    document_id=document_id,
                    job_type=EXPORT_JOB_TYPE,
                    status=JobStatus.running,
                )
                job_id = job.id
            else:
                job_id = queued[0].id

        jobs.update(job_id, status=JobStatus.running)
        exports.update(export_id, status=ExportStatus.processing)

        master_input: dict[str, Any] = {
            "document_id": document_id,
            "include_summary": bool(export.include_summary),
            "include_translation": bool(export.include_translation),
            "include_chat": bool(export.include_chat),
            "storage_key": f"exports/{document_id}/{export_id}.pdf",
        }

        if export.include_summary:
            master_input["summary"] = assemble_summary_text(document)
        if export.include_translation:
            master_input["translation"] = (document.translated_text or "").strip()
        if export.include_chat:
            chat = chats.get_by_user_and_document(export.user_id, document_id)
            chat_text = ""
            if chat is not None:
                chat_text = format_chat_annotations(messages.list_by_chat(chat.id))
            master_input["chat"] = chat_text

        storage = get_task_storage_provider()
        context = AgentContext(
            document_id=document_id,
            job_id=job_id,
            user_id=export.user_id,
        )
        agent_result = await run_master(
            "export",
            master_input,
            context,
            storage=storage,
        )

        if not agent_result.success:
            raise RuntimeError(agent_result.error or "Export agent failed")

        data = agent_result.data or {}
        storage_key = str(data.get("storage_key") or "")
        signed_url = str(data.get("signed_url") or "")
        if not storage_key or not signed_url:
            raise RuntimeError("Export agent did not return storage_key and signed_url")

        jobs.update(job_id, status=JobStatus.succeeded, error_message="")
        exports.update(
            export_id,
            status=ExportStatus.ready,
            storage_key=storage_key,
            signed_url=signed_url,
            error_message="",
        )

        return {
            "export_id": export_id,
            "document_id": document_id,
            "job_id": job_id,
            "export_status": ExportStatus.ready.value,
            "storage_key": storage_key,
            "signed_url": signed_url,
        }
    except Exception as exc:
        if job_id is not None:
            jobs.update(
                job_id,
                status=JobStatus.failed,
                error_message=str(exc),
            )
        exports.update(
            export_id,
            status=ExportStatus.failed,
            error_message=str(exc),
        )
        raise
    finally:
        session.close()
