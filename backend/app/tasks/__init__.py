"""Celery task package.

Note: do not bind ``celery_app`` on this package — it would shadow the
``app.tasks.celery_app`` module used by Compose (``celery -A app.tasks.celery_app``).

Embeddings: after OCR persists ``extracted_text``, callers enqueue via
``enqueue_generate_embeddings(document_id, config)`` (not auto-chained from
OCR — keeps the OCR unit free of chunker/retriever logic).
"""

from app.tasks.document_processing import enqueue_document_processing, run_ocr
from app.tasks.embeddings import enqueue_generate_embeddings, generate_embeddings
from app.tasks.export import enqueue_export, run_export
from app.tasks.summary import enqueue_summary, run_summary
from app.tasks.translation import enqueue_translation, run_translation

__all__ = [
    "enqueue_document_processing",
    "run_ocr",
    "enqueue_generate_embeddings",
    "generate_embeddings",
    "enqueue_summary",
    "run_summary",
    "enqueue_translation",
    "run_translation",
    "enqueue_export",
    "run_export",
]
