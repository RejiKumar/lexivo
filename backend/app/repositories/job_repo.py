"""Job table repository (SQL only)."""

from typing import Any

from app.models import Job, JobStatus
from app.repositories.base import BaseRepository


class JobRepository(BaseRepository[Job]):
    model = Job

    def create(
        self,
        *,
        document_id: str,
        job_type: str,
        status: JobStatus = JobStatus.queued,
        error_message: str | None = None,
        **fields: Any,
    ) -> Job:
        return super().create(
            document_id=document_id,
            job_type=job_type,
            status=status,
            error_message=error_message,
            **fields,
        )
