"""Celery task package.

Note: do not bind ``celery_app`` on this package — it would shadow the
``app.tasks.celery_app`` module used by Compose (``celery -A app.tasks.celery_app``).
"""

from app.tasks.document_processing import enqueue_document_processing, run_ocr

__all__ = [
    "enqueue_document_processing",
    "run_ocr",
]
