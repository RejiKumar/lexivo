"""Unit tests for Master Agent node registry and LangGraph orchestration."""

from __future__ import annotations

import pytest

from app.agents.base_agent import AgentContext, AgentResult, BaseAgent
from app.agents.master_agent import (
    MasterAgent,
    NodeRegistry,
    UnknownAgentError,
    build_master_agent,
    run_master,
)
from app.agents.ocr_agent import OCRAgent
from tests.fakes import FakeOCRProvider


def test_node_registry_register_and_resolve() -> None:
    registry = NodeRegistry()

    class Leaf(BaseAgent):
        name = "leaf"

        async def run(self, input: dict, context: AgentContext) -> AgentResult:
            return AgentResult(success=True)

    agent = Leaf()
    registry.register("leaf", agent)
    assert registry.resolve("leaf") is agent
    assert "leaf" in registry.names()


def test_node_registry_unknown_name() -> None:
    with pytest.raises(UnknownAgentError, match="Unknown agent"):
        NodeRegistry().resolve("missing")


def test_registry_does_not_require_agents_to_import_each_other() -> None:
    """Specialized agents stay leaf nodes; registry holds references only."""
    registry = NodeRegistry()
    ocr = OCRAgent(FakeOCRProvider())
    registry.register("ocr", ocr)
    assert registry.resolve("ocr") is ocr


@pytest.mark.asyncio
async def test_master_graph_invokes_ocr_node() -> None:
    fake = FakeOCRProvider(text="hello", pages=2)
    master = build_master_agent(ocr_provider=fake)
    ctx = AgentContext(document_id="d1", job_id="j1")
    result = await master.invoke(
        "ocr",
        {"file_bytes": b"%PDF"},
        ctx,
    )
    assert result.success is True
    assert result.data is not None
    assert result.data["text"] == "hello"
    assert result.data["pages"] == 2
    assert fake.calls == [b"%PDF"]


@pytest.mark.asyncio
async def test_run_master_is_public_orchestrator_api() -> None:
    fake = FakeOCRProvider(text="via-run-master")
    result = await run_master(
        "ocr",
        {"file_bytes": b"bytes"},
        AgentContext(document_id="d2"),
        ocr_provider=fake,
    )
    assert result.success is True
    assert result.data["text"] == "via-run-master"


@pytest.mark.asyncio
async def test_master_rejects_unknown_intent() -> None:
    master = build_master_agent(ocr_provider=FakeOCRProvider())
    with pytest.raises(ValueError, match="Unsupported Master intent"):
        await master.invoke("summary", {}, AgentContext())
