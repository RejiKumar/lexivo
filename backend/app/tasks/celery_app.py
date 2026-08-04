"""Celery application — broker from Settings; Compose worker entry: celery -A app.tasks.celery_app."""

from celery import Celery

from app.core.config import get_settings

settings = get_settings()

celery_app = Celery(
    "lexivo",
    broker=settings.celery_broker_url,
    include=["app.tasks.document_processing"],
)

celery_app.conf.update(
    result_backend=settings.redis_url,
    task_track_started=True,
    task_always_eager=settings.celery_task_always_eager,
    task_eager_propagates=settings.celery_task_always_eager,
)

# Register task units (safe: celery_app already constructed above).
import app.tasks.document_processing  # noqa: E402, F401
