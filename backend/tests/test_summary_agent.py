"""Unit tests for SummaryAgent (LLMProvider + prompts/summary only)."""

from __future__ import annotations

import json
from pathlib import Path
from unittest.mock import patch

import pytest

from app.agents.base_agent import AgentContext, BaseAgent
from app.agents.summary_agent import SummaryAgent
from app.prompts.prompt_loader import PromptTemplate
from tests.fakes import FakeLLMProvider


def test_summary_agent_is_base_agent_with_stable_name() -> None:
    agent = SummaryAgent(FakeLLMProvider())
    assert isinstance(agent, BaseAgent)
    assert agent.name == "summary"


@pytest.mark.asyncio
async def test_summary_agent_missing_text_fails() -> None:
    agent = SummaryAgent(FakeLLMProvider())
    result = await agent.run({}, AgentContext(document_id="d1"))
    assert result.success is False
    assert "text" in (result.error or "").lower()
    assert result.metadata["agent"] == "summary"


@pytest.mark.asyncio
async def test_summary_agent_empty_text_fails() -> None:
    agent = SummaryAgent(FakeLLMProvider())
    result = await agent.run({"text": "   "}, AgentContext())
    assert result.success is False
    assert result.metadata["error_type"] == "ValueError"


@pytest.mark.asyncio
async def test_summary_agent_success_loads_prompt_and_calls_llm() -> None:
    payload = {"short_summary": "Short.", "detailed_summary": "Detailed body."}
    fake = FakeLLMProvider(response=json.dumps(payload))
    agent = SummaryAgent(fake)
    result = await agent.run(
        {"extracted_text": "Document body about contracts."},
        AgentContext(document_id="d1", job_id="j1"),
    )
    assert result.success is True
    assert result.data["short_summary"] == "Short."
    assert result.data["detailed_summary"] == "Detailed body."
    assert result.data["prompt_name"] == "summary"
    assert result.data["prompt_version"] == "v1"
    assert len(fake.prompts) == 1
    assert "Document body about contracts." in fake.prompts[0]


@pytest.mark.asyncio
async def test_summary_agent_llm_failure_uses_on_error() -> None:
    class BoomLLM:
        async def complete(self, prompt: str, **kwargs: object) -> str:
            raise RuntimeError("LLM down")

    agent = SummaryAgent(BoomLLM())  # type: ignore[arg-type]
    result = await agent.run({"text": "ok"}, AgentContext(job_id="j1"))
    assert result.success is False
    assert result.error == "LLM down"
    assert result.metadata["agent"] == "summary"
    assert result.metadata["error_type"] == "RuntimeError"


@pytest.mark.asyncio
async def test_summary_agent_uses_prompt_loader_not_inline() -> None:
    fake = FakeLLMProvider(
        response=json.dumps(
            {"short_summary": "S", "detailed_summary": "D"}
        )
    )
    agent = SummaryAgent(fake)
    stub = PromptTemplate(
        name="summary",
        version="v1",
        template="Stub summary prompt:\n{text}",
        metadata={},
    )
    with patch(
        "app.agents.summary_agent.prompt_loader.load",
        return_value=stub,
    ) as load_mock:
        result = await agent.run({"text": "body"}, AgentContext())
    load_mock.assert_called_once_with("summary", version="v1")
    assert result.success is True
    assert fake.prompts[0] == "Stub summary prompt:\nbody"


def test_summary_agent_module_has_no_vendor_sdk_or_inline_prompt() -> None:
    source = (
        Path(__file__).resolve().parents[1] / "app" / "agents" / "summary_agent.py"
    ).read_text(encoding="utf-8")
    forbidden = (
        "google.generativeai",
        "openai",
        "anthropic",
        "mistralai",
    )
    for token in forbidden:
        assert token not in source, f"Vendor SDK import marker {token!r}"
    assert "You are Lexivo's summarization assistant" not in source
    assert "prompt_loader" in source
