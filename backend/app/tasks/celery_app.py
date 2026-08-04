"""Minimal Celery application for Compose worker entry (task units land in §9)."""

from celery import Celery

from app.core.config import get_settings

settings = get_settings()

celery_app = Celery(
    "lexivo",
    broker=settings.celery_broker_url,
    include=[],
)

celery_app.conf.update(
    result_backend=settings.redis_url,
    task_track_started=True,
)
