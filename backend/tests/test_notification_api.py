"""Tests for notification schemas, store, service, emit, and thin API routes."""

from __future__ import annotations

from pathlib import Path
from unittest.mock import AsyncMock, patch

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.adapters.notifications import SqlNotificationStore
from app.adapters.types import UserIdentity
from app.agents.base_agent import AgentResult
from app.schemas import NotificationListResponse, NotificationResponse
from app.services.base import NotFoundError
from app.services.notification_service import (
    NotificationService,
    emit_job_complete_notification,
)
from app.services.user_service import UserService
from app.repositories.user_repo import UserRepository
from tests.conftest import make_auth_header
from tests.fakes import FakeNotificationStore, FakePushProvider


def test_notification_response_serialization_read_vs_unread() -> None:
    unread = NotificationResponse(
        id="n1",
        type="processing_complete",
        title="OCR complete",
        body="Your document text is ready.",
        payload={"document_id": "d1", "job_type": "ocr"},
        read_at=None,
        created_at=None,
    )
    dumped = unread.model_dump()
    assert dumped["read_at"] is None
    assert dumped["title"] == "OCR complete"
    assert dumped["payload"]["job_type"] == "ocr"

    from datetime import UTC, datetime

    read = NotificationResponse(
        id="n2",
        type="processing_complete",
        title="PDF export ready",
        body="Done",
        payload={},
        read_at=datetime(2026, 8, 4, tzinfo=UTC),
        created_at=datetime(2026, 8, 4, tzinfo=UTC),
    )
    assert read.model_dump()["read_at"] is not None

    listing = NotificationListResponse(items=[unread, read], total=2)
    assert listing.total == 2
    assert len(listing.items) == 2


@pytest.mark.asyncio
async def test_fake_store_list_and_mark_read() -> None:
    store = FakeNotificationStore()
    await store.create_notification(
        "u1", "processing_complete", {"title": "A", "body": "1"}
    )
    await store.create_notification(
        "u1", "processing_complete", {"title": "B", "body": "2"}
    )
    await store.create_notification(
        "u2", "processing_complete", {"title": "Other", "body": "x"}
    )

    rows = await store.list_for_user("u1")
    assert len(rows) == 2
    assert all(r["user_id"] == "u1" for r in rows)

    first_id = rows[-1]["id"]  # older of the two after newest-first sort
    marked = await store.mark_read("u1", first_id)
    assert marked is not None
    assert marked["read_at"] is not None

    again = await store.mark_read("u1", first_id)
    assert again is not None
    assert again["read_at"] == marked["read_at"]

    assert await store.mark_read("u2", first_id) is None
    unread = await store.list_for_user("u1", unread_only=True)
    assert all(r["read_at"] is None for r in unread)


@pytest.mark.asyncio
async def test_sql_store_create_list_mark_read(db_session: Session) -> None:
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="notif-owner", email="n@example.com")
    )
    other = users.upsert_from_identity(
        UserIdentity(subject="notif-other", email="o@example.com")
    )

    store = SqlNotificationStore(db_session)
    first = await store.create_notification(
        user.id,
        "processing_complete",
        {"title": "OCR complete", "body": "Ready", "document_id": "d1"},
    )
    second = await store.create_notification(
        user.id,
        "processing_complete",
        {"title": "Summary ready", "body": "Ready", "job_type": "summary"},
    )
    await store.create_notification(
        other.id,
        "processing_complete",
        {"title": "Other", "body": "x"},
    )

    rows = await store.list_for_user(user.id)
    assert len(rows) == 2
    assert rows[0]["id"] == second["id"]
    assert rows[0]["title"] == "Summary ready"

    marked = await store.mark_read(user.id, first["id"])
    assert marked is not None
    assert marked["read_at"] is not None
    again = await store.mark_read(user.id, first["id"])
    assert again is not None
    assert again["read_at"] == marked["read_at"]

    assert await store.mark_read(other.id, first["id"]) is None
    unread = await store.list_for_user(user.id, unread_only=True)
    assert len(unread) == 1
    assert unread[0]["id"] == second["id"]


@pytest.mark.asyncio
async def test_notification_service_list_ownership_and_mark_read() -> None:
    store = FakeNotificationStore()
    svc = NotificationService(store)
    await store.create_notification(
        "u1", "processing_complete", {"title": "Mine", "body": "a"}
    )
    await store.create_notification(
        "u2", "processing_complete", {"title": "Theirs", "body": "b"}
    )

    mine = await svc.list_notifications("u1")
    assert len(mine) == 1
    assert mine[0]["title"] == "Mine"

    marked = await svc.mark_read("u1", mine[0]["id"])
    assert marked["read_at"] is not None

    with pytest.raises(NotFoundError):
        await svc.mark_read("u1", "missing")
    with pytest.raises(NotFoundError):
        await svc.mark_read("u1", (await store.list_for_user("u2"))[0]["id"])


@pytest.mark.asyncio
async def test_emit_job_complete_calls_run_master_notification() -> None:
    store = FakeNotificationStore()
    push = FakePushProvider()

    with patch(
        "app.services.notification_service.run_master",
        new_callable=AsyncMock,
    ) as mock_run:
        mock_run.return_value = AgentResult(
            success=True,
            data={"in_app": True, "push_sent": True, "email_sent": False},
        )
        data = await emit_job_complete_notification(
            user_id="u1",
            job_type="ocr",
            document_id="d1",
            job_id="j1",
            notification_store=store,
            push=push,
        )

    assert data is not None
    assert data["in_app"] is True
    mock_run.assert_awaited_once()
    args, kwargs = mock_run.await_args
    assert args[0] == "notification"
    assert args[1]["user_id"] == "u1"
    assert args[1]["job_type"] == "ocr"
    assert args[1]["event_type"] == "processing_complete"
    assert args[1]["push_enabled"] is True
    assert kwargs["notification_store"] is store
    assert kwargs["push"] is push


@pytest.mark.asyncio
async def test_emit_job_complete_creates_in_app_via_master() -> None:
    store = FakeNotificationStore()
    push = FakePushProvider()
    data = await emit_job_complete_notification(
        user_id="u1",
        job_type="translation",
        document_id="d1",
        job_id="j1",
        notification_store=store,
        push=push,
    )
    assert data is not None
    assert data["in_app"] is True
    assert data["email_sent"] is False
    assert len(store.records) == 1
    assert store.records[0]["title"] == "Translation ready"
    assert len(push.sent) == 1


@pytest.mark.asyncio
async def test_emit_soft_fails_on_master_error() -> None:
    store = FakeNotificationStore()
    with patch(
        "app.services.notification_service.run_master",
        new_callable=AsyncMock,
        side_effect=RuntimeError("boom"),
    ):
        data = await emit_job_complete_notification(
            user_id="u1",
            job_type="export",
            notification_store=store,
            push=FakePushProvider(),
        )
    assert data is None


def test_notification_service_and_router_no_agent_or_email_imports() -> None:
    service_src = (
        Path(__file__).resolve().parents[1]
        / "app"
        / "services"
        / "notification_service.py"
    ).read_text(encoding="utf-8")
    router_src = (
        Path(__file__).resolve().parents[1]
        / "app"
        / "api"
        / "v1"
        / "routers"
        / "notifications.py"
    ).read_text(encoding="utf-8")
    for source in (service_src, router_src):
        assert "run_master" in service_src or "NotificationService" in source
        assert "NotificationAgent" not in source
        assert "notification_agent" not in source
        assert "send_email" not in source
        assert "smtplib" not in source
        assert "PushProvider" not in router_src or source is service_src

    assert "run_master" in service_src
    assert "NotificationAgent" not in service_src
    assert "NotificationAgent" not in router_src
    assert "PushProvider" not in router_src


def test_task_modules_emit_via_helper_not_agent() -> None:
    tasks_dir = Path(__file__).resolve().parents[1] / "app" / "tasks"
    for name in (
        "document_processing.py",
        "summary.py",
        "translation.py",
        "export.py",
    ):
        source = (tasks_dir / name).read_text(encoding="utf-8")
        assert "emit_job_complete_notification" in source
        assert "NotificationAgent" not in source
        assert "notification_agent" not in source
        assert "send_email" not in source


def test_list_notifications_requires_auth(api_client: TestClient) -> None:
    response = api_client.get("/api/v1/notifications")
    assert response.status_code in (401, 403)


def test_list_notifications_empty_and_populated(
    api_client: TestClient,
    db_session: Session,
) -> None:
    header = make_auth_header(sub="notif-list", email="nl@example.com")
    empty = api_client.get("/api/v1/notifications", headers=header)
    assert empty.status_code == 200
    body = empty.json()
    assert body["items"] == []
    assert body["total"] == 0

    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="notif-list", email="nl@example.com")
    )
    store = SqlNotificationStore(db_session)

    import asyncio

    asyncio.run(
        store.create_notification(
            user.id,
            "processing_complete",
            {
                "title": "OCR complete",
                "body": "Your document text is ready.",
                "document_id": "d1",
                "job_type": "ocr",
            },
        )
    )

    populated = api_client.get("/api/v1/notifications", headers=header)
    assert populated.status_code == 200
    data = populated.json()
    assert data["total"] == 1
    assert data["items"][0]["title"] == "OCR complete"
    assert data["items"][0]["read_at"] is None


def test_mark_notification_read_auth_ownership_idempotent(
    api_client: TestClient,
    db_session: Session,
) -> None:
    owner_header = make_auth_header(
        sub="notif-owner-api", email="no@example.com"
    )
    other_header = make_auth_header(
        sub="notif-other-api", email="nx@example.com"
    )

    users = UserService(UserRepository(db_session))
    owner = users.upsert_from_identity(
        UserIdentity(subject="notif-owner-api", email="no@example.com")
    )
    store = SqlNotificationStore(db_session)

    import asyncio

    record = asyncio.run(
        store.create_notification(
            owner.id,
            "processing_complete",
            {"title": "Ready", "body": "Done"},
        )
    )

    first = api_client.post(
        f"/api/v1/notifications/{record['id']}/read",
        headers=owner_header,
    )
    assert first.status_code == 200
    assert first.json()["read_at"] is not None

    second = api_client.post(
        f"/api/v1/notifications/{record['id']}/read",
        headers=owner_header,
    )
    assert second.status_code == 200
    assert second.json()["read_at"] == first.json()["read_at"]

    wrong = api_client.post(
        f"/api/v1/notifications/{record['id']}/read",
        headers=other_header,
    )
    assert wrong.status_code == 404

    missing = api_client.post(
        "/api/v1/notifications/does-not-exist/read",
        headers=owner_header,
    )
    assert missing.status_code == 404


def test_openapi_includes_notification_paths(api_client: TestClient) -> None:
    schema = api_client.get("/openapi.json").json()
    paths = schema["paths"]
    assert "/api/v1/notifications" in paths
    assert "/api/v1/notifications/{notification_id}/read" in paths
    schemas = schema["components"]["schemas"]
    assert "NotificationResponse" in schemas
    assert "NotificationListResponse" in schemas
