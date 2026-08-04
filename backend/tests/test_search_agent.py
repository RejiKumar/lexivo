"""Unit tests for SearchAgent (RagPipeline.query only)."""

from __future__ import annotations

from pathlib import Path
from unittest.mock import AsyncMock

import pytest

from app.agents.base_agent import AgentContext, BaseAgent
from app.agents.search_agent import SearchAgent
from app.rag.types import RagAnswer, RankedChunk


def test_search_agent_is_base_agent_with_stable_name() -> None:
    pipeline = AsyncMock()
    agent = SearchAgent(pipeline)  # type: ignore[arg-type]
    assert isinstance(agent, BaseAgent)
    assert agent.name == "search"


@pytest.mark.asyncio
async def test_search_agent_missing_fields_fail() -> None:
    pipeline = AsyncMock()
    agent = SearchAgent(pipeline)  # type: ignore[arg-type]
    missing_doc = await agent.run({"question": "Q?"}, AgentContext())
    assert missing_doc.success is False
    missing_q = await agent.run({"document_id": "d1"}, AgentContext())
    assert missing_q.success is False
    pipeline.query.assert_not_called()


@pytest.mark.asyncio
async def test_search_agent_success_maps_rag_answer() -> None:
    pipeline = AsyncMock()
    pipeline.query = AsyncMock(
        return_value=RagAnswer(
            document_id="d1",
            question="What is aurora?",
            context="aurora_borealis lights",
            chunks=[
                RankedChunk(text="aurora_borealis lights", index=0, score=0.9),
            ],
            answer=None,
        )
    )
    agent = SearchAgent(pipeline)  # type: ignore[arg-type]
    result = await agent.run(
        {"document_id": "d1", "question": "What is aurora?"},
        AgentContext(document_id="d1"),
    )
    assert result.success is True
    assert result.data["context"] == "aurora_borealis lights"
    assert result.data["chunks"][0]["index"] == 0
    assert result.data["ungrounded"] is False
    assert result.data["answer"] is None
    pipeline.query.assert_awaited_once_with("d1", "What is aurora?", config=None)


@pytest.mark.asyncio
async def test_search_agent_empty_retrieval_marks_ungrounded() -> None:
    pipeline = AsyncMock()
    pipeline.query = AsyncMock(
        return_value=RagAnswer(
            document_id="d1",
            question="unknown?",
            context="",
            chunks=[],
            answer=None,
        )
    )
    agent = SearchAgent(pipeline)  # type: ignore[arg-type]
    result = await agent.run(
        {"document_id": "d1", "question": "unknown?"},
        AgentContext(),
    )
    assert result.success is True
    assert result.data["ungrounded"] is True
    assert result.data["answer"] is None
    assert result.data["chunks"] == []


def test_search_agent_no_citation_or_vendor_imports() -> None:
    source = (
        Path(__file__).resolve().parents[1] / "app" / "agents" / "search_agent.py"
    ).read_text(encoding="utf-8")
    for token in (
        "citation_agent",
        "openai",
        "pinecone",
        "weaviate",
        "qdrant",
    ):
        assert token not in source
    assert "from app.agents." not in source or "base_agent" in source
