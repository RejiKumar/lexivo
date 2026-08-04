"""Unit tests for Celery app config and task registration."""

from app.core.config import Settings
from app.tasks.celery_app import celery_app
from app.tasks.document_processing import enqueue_document_processing, run_ocr
from app.tasks.embeddings import enqueue_generate_embeddings, generate_embeddings
from app.tasks.summary import enqueue_summary, run_summary
import app.tasks.celery_app as celery_mod


def test_celery_app_broker_comes_from_settings() -> None:
    """Celery broker is wired from Settings at app construction."""
    assert celery_mod.settings.celery_broker_url
    assert celery_app.conf.broker_url == celery_mod.settings.celery_broker_url
    # Settings field remains overridable for other processes / workers
    custom = Settings(celery_broker_url="redis://broker-test:6379/9")
    assert custom.celery_broker_url == "redis://broker-test:6379/9"


def test_celery_eager_flag_from_settings() -> None:
    assert Settings(celery_task_always_eager=True).celery_task_always_eager is True
    assert Settings(celery_task_always_eager=False).celery_task_always_eager is False


def test_ocr_task_units_are_registered() -> None:
    registered = set(celery_app.tasks.keys())
    assert "app.tasks.document_processing.run_ocr" in registered
    assert callable(run_ocr)
    assert callable(enqueue_document_processing)


def test_embeddings_task_units_are_registered() -> None:
    registered = set(celery_app.tasks.keys())
    assert "app.tasks.embeddings.generate_embeddings" in registered
    assert callable(generate_embeddings)
    assert callable(enqueue_generate_embeddings)


def test_summary_task_units_are_registered() -> None:
    registered = set(celery_app.tasks.keys())
    assert "app.tasks.summary.run_summary" in registered
    assert callable(run_summary)
    assert callable(enqueue_summary)
