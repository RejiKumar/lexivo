"""Unit tests for NotificationAgent (in-app + push; no email)."""

from __future__ import annotations

from pathlib import Path

import pytest

from app.agents.base_agent import AgentContext, BaseAgent
from app.agents.notification_agent import NotificationAgent
from tests.fakes import FakeNotificationStore, FakePushProvider


def test_notification_agent_is_base_agent_with_stable_name() -> None:
    agent = NotificationAgent(FakeNotificationStore(), FakePushProvider())
    assert isinstance(agent, BaseAgent)
    assert agent.name == "notification"


@pytest.mark.asyncio
async def test_notification_agent_in_app_and_push() -> None:
    store = FakeNotificationStore()
    push = FakePushProvider()
    agent = NotificationAgent(store, push)
    result = await agent.run(
        {
            "user_id": "u1",
            "event_type": "processing_complete",
            "job_type": "ocr",
            "title": "Ready",
            "body": "OCR finished",
            "push_enabled": True,
        },
        AgentContext(user_id="u1", document_id="d1"),
    )
    assert result.success is True
    assert result.data["in_app"] is True
    assert result.data["push_sent"] is True
    assert result.data["email_sent"] is False
    assert len(store.records) == 1
    assert len(push.sent) == 1


@pytest.mark.asyncio
async def test_notification_agent_push_disabled_in_app_only() -> None:
    store = FakeNotificationStore()
    push = FakePushProvider()
    agent = NotificationAgent(store, push)
    result = await agent.run(
        {
            "user_id": "u1",
            "event_type": "reminder",
            "body": "Reminder",
            "push_enabled": False,
        },
        AgentContext(),
    )
    assert result.success is True
    assert result.data["push_sent"] is False
    assert len(store.records) == 1
    assert push.sent == []


@pytest.mark.asyncio
async def test_notification_agent_push_failure_partial_success() -> None:
    store = FakeNotificationStore()
    push = FakePushProvider(fail=True)
    agent = NotificationAgent(store, push)
    result = await agent.run(
        {
            "user_id": "u1",
            "event_type": "processing_complete",
            "body": "Done",
            "push_enabled": True,
        },
        AgentContext(),
    )
    assert result.success is True
    assert result.data["in_app"] is True
    assert result.data["push_sent"] is False
    assert result.data["push_error"] == "push failed"


@pytest.mark.asyncio
async def test_notification_agent_rejects_email() -> None:
    agent = NotificationAgent(FakeNotificationStore(), FakePushProvider())
    result = await agent.run(
        {
            "user_id": "u1",
            "event_type": "processing_complete",
            "body": "x",
            "send_email": True,
        },
        AgentContext(),
    )
    assert result.success is False
    assert "email" in (result.error or "").lower()


def test_notification_agent_no_email_sdk() -> None:
    source = (
        Path(__file__).resolve().parents[1]
        / "app"
        / "agents"
        / "notification_agent.py"
    ).read_text(encoding="utf-8")
    for token in ("smtp", "sendgrid", "ses", "summary_agent", "firebase_admin"):
        assert token not in source
