"""Unit tests for AnalyticsAgent (AnalyticsProvider Protocol)."""

from __future__ import annotations

from pathlib import Path

import pytest

from app.agents.analytics_agent import AnalyticsAgent
from app.agents.base_agent import AgentContext, BaseAgent
from tests.fakes import FakeAnalyticsProvider


def test_analytics_agent_is_base_agent_with_stable_name() -> None:
    agent = AnalyticsAgent(FakeAnalyticsProvider())
    assert isinstance(agent, BaseAgent)
    assert agent.name == "analytics"


@pytest.mark.asyncio
async def test_analytics_agent_tracks_valid_event() -> None:
    fake = FakeAnalyticsProvider()
    agent = AnalyticsAgent(fake)
    result = await agent.run(
        {
            "name": "document_opened",
            "user_id": "u1",
            "properties": {"source": "home"},
        },
        AgentContext(document_id="d1"),
    )
    assert result.success is True
    assert result.data["tracked"] is True
    assert result.data["event"] == "document_opened"
    assert len(fake.events) == 1
    assert fake.events[0]["properties"]["document_id"] == "d1"


@pytest.mark.asyncio
async def test_analytics_agent_missing_name_no_provider_call() -> None:
    fake = FakeAnalyticsProvider()
    agent = AnalyticsAgent(fake)
    result = await agent.run({"properties": {}}, AgentContext())
    assert result.success is False
    assert fake.events == []


@pytest.mark.asyncio
async def test_analytics_agent_provider_failure_soft_fails() -> None:
    agent = AnalyticsAgent(FakeAnalyticsProvider(fail=True))
    result = await agent.run({"event": "x"}, AgentContext())
    assert result.success is False
    assert result.error == "analytics failed"


def test_analytics_agent_no_posthog_sdk() -> None:
    source = (
        Path(__file__).resolve().parents[1] / "app" / "agents" / "analytics_agent.py"
    ).read_text(encoding="utf-8")
    for token in ("posthog", "summary_agent", "segment"):
        assert token not in source
    assert "responsibilities (STEP 3.6)" in source