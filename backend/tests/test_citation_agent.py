"""Unit tests for CitationAgent (LLM grounding + citation shaping)."""

from __future__ import annotations

import json
from pathlib import Path
from unittest.mock import patch

import pytest

from app.agents.base_agent import AgentContext, BaseAgent
from app.agents.citation_agent import CANNOT_ANSWER, CitationAgent
from app.prompts.prompt_loader import PromptTemplate
from tests.fakes import FakeLLMProvider


def test_citation_agent_is_base_agent_with_stable_name() -> None:
    agent = CitationAgent(FakeLLMProvider())
    assert isinstance(agent, BaseAgent)
    assert agent.name == "citation"


@pytest.mark.asyncio
async def test_citation_agent_missing_question_fails() -> None:
    agent = CitationAgent(FakeLLMProvider())
    result = await agent.run({"context": "x", "chunks": []}, AgentContext())
    assert result.success is False


@pytest.mark.asyncio
async def test_citation_agent_success_shapes_citations() -> None:
    payload = {
        "answer": "Aurora is northern lights.",
        "citations": [{"index": 0, "snippet": "aurora_borealis"}],
    }
    fake = FakeLLMProvider(response=json.dumps(payload))
    agent = CitationAgent(fake)
    result = await agent.run(
        {
            "question": "What is aurora?",
            "context": "aurora_borealis lights",
            "chunks": [{"text": "aurora_borealis lights", "index": 0, "score": 0.9}],
        },
        AgentContext(document_id="d1"),
    )
    assert result.success is True
    assert result.data["answer"] == "Aurora is northern lights."
    assert result.data["citations"][0]["index"] == 0
    assert result.data["cannot_answer"] is False
    assert len(fake.prompts) == 1


@pytest.mark.asyncio
async def test_citation_agent_empty_chunks_cannot_answer_without_llm() -> None:
    fake = FakeLLMProvider(response="should-not-run")
    agent = CitationAgent(fake)
    result = await agent.run(
        {
            "question": "What?",
            "context": "",
            "chunks": [],
            "ungrounded": True,
        },
        AgentContext(),
    )
    assert result.success is True
    assert result.data["answer"] == CANNOT_ANSWER
    assert result.data["cannot_answer"] is True
    assert result.data["citations"] == []
    assert fake.prompts == []


@pytest.mark.asyncio
async def test_citation_agent_uses_prompt_loader() -> None:
    fake = FakeLLMProvider(
        response=json.dumps({"answer": "A", "citations": []})
    )
    agent = CitationAgent(fake)
    stub = PromptTemplate(
        name="citation",
        version="v1",
        template="Q:{question}\nC:{context}",
        metadata={},
    )
    with patch(
        "app.agents.citation_agent.prompt_loader.load",
        return_value=stub,
    ) as load_mock:
        result = await agent.run(
            {
                "question": "Q?",
                "context": "ctx",
                "chunks": [{"index": 1, "text": "ctx"}],
            },
            AgentContext(),
        )
    load_mock.assert_called_once_with("citation", version="v1")
    assert result.success is True
    assert fake.prompts[0] == "Q:Q?\nC:ctx"


def test_citation_agent_no_search_imports() -> None:
    source = (
        Path(__file__).resolve().parents[1] / "app" / "agents" / "citation_agent.py"
    ).read_text(encoding="utf-8")
    for token in ("search_agent", "RagPipeline", "openai"):
        assert token not in source
    assert "You are Lexivo's citation assistant" not in source
