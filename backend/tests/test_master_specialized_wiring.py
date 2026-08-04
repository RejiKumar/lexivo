"""Master wiring tests for all specialized agents + Search→Citation sequence."""

from __future__ import annotations

import json
from typing import Any
from unittest.mock import AsyncMock

import pytest

from app.agents.base_agent import AgentContext
from app.agents.master_agent import (
    MasterAgent,
    NodeRegistry,
    UnknownAgentError,
    build_master_agent,
    run_master,
)
from app.agents.ocr_agent import OCRAgent
from app.rag.types import RagAnswer, RankedChunk
from tests.fakes import (
    FakeAnalyticsProvider,
    FakeLLMProvider,
    FakeNotificationStore,
    FakeOCRProvider,
    FakePushProvider,
    FakeStorageProvider,
)


def _full_master(
    *,
    llm: FakeLLMProvider | None = None,
    rag: Any = None,
) -> MasterAgent:
    pipeline = rag
    if pipeline is None:
        pipeline = AsyncMock()
        pipeline.query = AsyncMock(
            return_value=RagAnswer(
                document_id="d1",
                question="Q?",
                context="ctx",
                chunks=[RankedChunk(text="ctx", index=0, score=1.0)],
            )
        )
    return build_master_agent(
        ocr_provider=FakeOCRProvider(text="ocr"),
        llm=llm
        or FakeLLMProvider(
            response=json.dumps(
                {
                    "short_summary": "S",
                    "detailed_summary": "D",
                    "answer": "A",
                    "citations": [{"index": 0, "snippet": "ctx"}],
                }
            )
        ),
        rag_pipeline=pipeline,
        storage=FakeStorageProvider(),
        push=FakePushProvider(),
        notification_store=FakeNotificationStore(),
        analytics=FakeAnalyticsProvider(),
    )


def test_registry_resolves_all_specialists() -> None:
    master = _full_master()
    for name in (
        "ocr",
        "summary",
        "translation",
        "search",
        "citation",
        "export",
        "security",
        "notification",
        "analytics",
    ):
        assert master.registry.resolve(name).name == name
    with pytest.raises(UnknownAgentError):
        master.registry.resolve("missing")


@pytest.mark.asyncio
@pytest.mark.parametrize(
    ("intent", "payload", "expect_key"),
    [
        ("ocr", {"file_bytes": b"x"}, "text"),
        ("summary", {"text": "Document text"}, "short_summary"),
        (
            "translation",
            {"text": "Hello", "source_lang": "en", "target_lang": "es"},
            "translated_text",
        ),
        ("search", {"document_id": "d1", "question": "Q?"}, "context"),
        (
            "citation",
            {
                "question": "Q?",
                "context": "ctx",
                "chunks": [{"index": 0, "text": "ctx"}],
            },
            "answer",
        ),
        (
            "export",
            {"include_summary": True, "summary": "Sum"},
            "signed_url",
        ),
        (
            "security",
            {"action": "validate_payload", "payload": {"text": "ok"}},
            "allowed",
        ),
        (
            "notification",
            {
                "user_id": "u1",
                "event_type": "processing_complete",
                "body": "done",
                "push_enabled": False,
            },
            "in_app",
        ),
        (
            "analytics",
            {"name": "evt", "user_id": "u1"},
            "tracked",
        ),
    ],
)
async def test_master_routes_single_intents(
    intent: str,
    payload: dict,
    expect_key: str,
) -> None:
    llm = FakeLLMProvider(
        response=(
            "Hola"
            if intent == "translation"
            else json.dumps(
                {
                    "short_summary": "S",
                    "detailed_summary": "D",
                    "answer": "Grounded",
                    "citations": [{"index": 0, "snippet": "ctx"}],
                }
            )
        )
    )
    master = _full_master(llm=llm)
    result = await master.invoke(intent, payload, AgentContext(user_id="u1"))
    assert result.success is True
    assert result.data is not None
    assert expect_key in result.data


@pytest.mark.asyncio
async def test_master_ask_sequences_search_then_citation() -> None:
    pipeline = AsyncMock()
    pipeline.query = AsyncMock(
        return_value=RagAnswer(
            document_id="d1",
            question="What?",
            context="aurora",
            chunks=[RankedChunk(text="aurora", index=0, score=0.8)],
        )
    )
    llm = FakeLLMProvider(
        response=json.dumps(
            {
                "answer": "Aurora answer",
                "citations": [{"index": 0, "snippet": "aurora"}],
            }
        )
    )
    master = _full_master(llm=llm, rag=pipeline)
    result = await master.invoke(
        "ask",
        {"document_id": "d1", "question": "What?"},
        AgentContext(document_id="d1"),
    )
    assert result.success is True
    assert result.data["answer"] == "Aurora answer"
    assert result.data["cannot_answer"] is False
    pipeline.query.assert_awaited()
    assert len(llm.prompts) == 1


@pytest.mark.asyncio
async def test_master_ask_empty_search_still_invokes_citation_cannot_answer() -> None:
    """Choice: Master always invokes Citation after Search; Citation refuses."""
    pipeline = AsyncMock()
    pipeline.query = AsyncMock(
        return_value=RagAnswer(
            document_id="d1",
            question="Missing?",
            context="",
            chunks=[],
        )
    )
    llm = FakeLLMProvider(response="should-not-run")
    master = _full_master(llm=llm, rag=pipeline)
    result = await master.invoke(
        "rag_chat",
        {"document_id": "d1", "question": "Missing?"},
        AgentContext(),
    )
    assert result.success is True
    assert result.data["cannot_answer"] is True
    assert llm.prompts == []


@pytest.mark.asyncio
async def test_master_rejects_truly_unknown_intent() -> None:
    master = build_master_agent(ocr_provider=FakeOCRProvider())
    with pytest.raises(ValueError, match="Unsupported Master intent"):
        await master.invoke("not_a_real_intent", {}, AgentContext())


def test_registry_does_not_require_agents_to_import_each_other() -> None:
    registry = NodeRegistry()
    ocr = OCRAgent(FakeOCRProvider())
    registry.register("ocr", ocr)
    assert registry.resolve("ocr") is ocr


@pytest.mark.asyncio
async def test_run_master_ocr_backward_compatible() -> None:
    result = await run_master(
        "ocr",
        {"file_bytes": b"x"},
        AgentContext(),
        ocr_provider=FakeOCRProvider(text="ok"),
    )
    assert result.success is True
    assert result.data["text"] == "ok"
