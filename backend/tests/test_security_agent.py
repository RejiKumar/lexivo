"""Unit tests for SecurityAgent (deterministic payload checks)."""

from __future__ import annotations

from pathlib import Path

import pytest

from app.agents.base_agent import AgentContext, BaseAgent
from app.agents.security_agent import SecurityAgent


def test_security_agent_is_base_agent_with_stable_name() -> None:
    agent = SecurityAgent()
    assert isinstance(agent, BaseAgent)
    assert agent.name == "security"


@pytest.mark.asyncio
async def test_security_agent_allows_clean_payload() -> None:
    agent = SecurityAgent()
    result = await agent.run(
        {
            "action": "validate_payload",
            "payload": {"text": "Clean document text"},
        },
        AgentContext(user_id="u1", document_id="d1"),
    )
    assert result.success is True
    assert result.data["allowed"] is True
    assert any(c["name"] == "context_ids" for c in result.data["checks"])


@pytest.mark.asyncio
async def test_security_agent_rejects_oversized_and_blocked() -> None:
    agent = SecurityAgent(max_text_chars=20)
    oversized = await agent.run(
        {"payload": {"text": "x" * 50}},
        AgentContext(),
    )
    assert oversized.success is False
    assert oversized.data["allowed"] is False

    blocked = await agent.run(
        {"payload": {"text": "hello <script>alert(1)</script>"}},
        AgentContext(),
    )
    assert blocked.success is False
    assert blocked.data["allowed"] is False


@pytest.mark.asyncio
async def test_security_agent_rejects_unknown_action() -> None:
    agent = SecurityAgent()
    result = await agent.run({"action": "drop_tables"}, AgentContext())
    assert result.success is False
    assert result.data["allowed"] is False


def test_security_agent_no_specialist_or_vendor_sdk() -> None:
    source = (
        Path(__file__).resolve().parents[1] / "app" / "agents" / "security_agent.py"
    ).read_text(encoding="utf-8")
    for token in ("summary_agent", "openai", "recaptcha", "cloudflare"):
        assert token not in source
    assert "responsibilities (STEP 3.6)" in source
