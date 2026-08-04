"""Unit tests for QuotaService + QuotaExceededError shape."""

from __future__ import annotations

import pytest
from sqlalchemy.orm import Session

from app.core.config import Settings
from app.models import (
    Chat,
    ChatMessage,
    ChatMessageRole,
    Document,
    DocumentStatus,
    Subscription,
    SubscriptionStatus,
    SubscriptionTier,
    User,
)
from app.services.base import QuotaExceededError
from app.services.quota_service import QuotaService, utc_month_start


@pytest.fixture
def settings() -> Settings:
    return Settings(
        free_tier_docs_per_month=2,
        free_tier_chat_messages_per_day=2,
        free_tier_ocr_pages_per_month=5,
        subscription_paywall_enabled=False,
        database_url="sqlite+pysqlite://",
        celery_task_always_eager=True,
        celery_broker_url="memory://",
        redis_url="cache+memory://",
        supabase_jwt_secret="x" * 32,
    )


def _user(db: Session, external_id: str = "ext-quota") -> User:
    user = User(external_id=external_id, email=f"{external_id}@example.com")
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def _doc(db: Session, user_id: str) -> Document:
    doc = Document(
        user_id=user_id,
        title="t",
        status=DocumentStatus.ready,
    )
    db.add(doc)
    db.commit()
    db.refresh(doc)
    return doc


def test_quota_exceeded_error_detail_shape() -> None:
    err = QuotaExceededError(
        resource="documents",
        limit=20,
        period="month",
        message="too many docs",
    )
    assert err.to_detail() == {
        "code": "quota_exceeded",
        "resource": "documents",
        "limit": 20,
        "period": "month",
        "message": "too many docs",
    }


def test_free_user_under_doc_limit_allows(
    db_session: Session, settings: Settings
) -> None:
    user = _user(db_session)
    quota = QuotaService(db_session, settings)
    _doc(db_session, user.id)
    quota.enforce_document_create(user.id)  # still under limit of 2


def test_free_user_at_doc_limit_rejects(
    db_session: Session, settings: Settings
) -> None:
    user = _user(db_session)
    quota = QuotaService(db_session, settings)
    _doc(db_session, user.id)
    _doc(db_session, user.id)
    with pytest.raises(QuotaExceededError) as exc:
        quota.enforce_document_create(user.id)
    assert exc.value.resource == "documents"
    assert exc.value.limit == 2
    assert exc.value.period == "month"


def test_free_user_chat_daily_cap(
    db_session: Session, settings: Settings
) -> None:
    user = _user(db_session, "ext-chat")
    doc = _doc(db_session, user.id)
    chat = Chat(user_id=user.id, document_id=doc.id)
    db_session.add(chat)
    db_session.commit()
    db_session.refresh(chat)
    for i in range(2):
        db_session.add(
            ChatMessage(
                chat_id=chat.id,
                role=ChatMessageRole.user,
                content=f"q{i}",
            )
        )
    db_session.commit()

    quota = QuotaService(db_session, settings)
    with pytest.raises(QuotaExceededError) as exc:
        quota.enforce_chat_message(user.id)
    assert exc.value.resource == "chat_messages"
    assert exc.value.period == "day"


def test_ocr_pages_estimate_rejects(
    db_session: Session, settings: Settings
) -> None:
    user = _user(db_session, "ext-ocr")
    doc = _doc(db_session, user.id)
    quota = QuotaService(db_session, settings)
    quota.record_ocr_pages(user_id=user.id, document_id=doc.id, pages=4)
    other = _doc(db_session, user.id)
    with pytest.raises(QuotaExceededError) as exc:
        quota.enforce_ocr_pages(
            user_id=user.id, document_id=other.id, estimated_pages=2
        )
    assert exc.value.resource == "ocr_pages"


def test_paid_tier_bypasses_all_caps(
    db_session: Session, settings: Settings
) -> None:
    user = _user(db_session, "ext-paid")
    for _ in range(5):
        _doc(db_session, user.id)
    db_session.add(
        Subscription(
            user_id=user.id,
            tier=SubscriptionTier.paid,
            status=SubscriptionStatus.active,
        )
    )
    db_session.commit()

    quota = QuotaService(db_session, settings)
    quota.enforce_document_create(user.id)
    quota.enforce_chat_message(user.id)
    quota.enforce_ocr_pages(user_id=user.id, estimated_pages=999)


def test_caps_enforce_when_paywall_flag_false(
    db_session: Session, settings: Settings
) -> None:
    assert settings.subscription_paywall_enabled is False
    user = _user(db_session, "ext-flag")
    quota = QuotaService(db_session, settings)
    _doc(db_session, user.id)
    _doc(db_session, user.id)
    with pytest.raises(QuotaExceededError):
        quota.enforce_document_create(user.id)


def test_ocr_idempotent_same_document(
    db_session: Session, settings: Settings
) -> None:
    user = _user(db_session, "ext-idem")
    doc = _doc(db_session, user.id)
    quota = QuotaService(db_session, settings)
    quota.record_ocr_pages(user_id=user.id, document_id=doc.id, pages=3)
    quota.record_ocr_pages(user_id=user.id, document_id=doc.id, pages=3)
    snap = quota.usage_snapshot(user.id)
    assert snap["ocr_pages"]["used"] == 3  # type: ignore[index]
    # Re-OCR same pages does not reject
    quota.enforce_ocr_pages(
        user_id=user.id, document_id=doc.id, estimated_pages=3
    )
    assert utc_month_start().day == 1
