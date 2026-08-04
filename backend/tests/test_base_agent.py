"""Unit tests for AgentResult, AgentContext, and BaseAgent."""

from __future__ import annotations

import pytest
from pydantic import ValidationError

from app.agents.base_agent import AgentContext, AgentResult, BaseAgent


def test_agent_result_defaults() -> None:
    result = AgentResult(success=True)
    assert result.success is True
    assert result.data is None
    assert result.error is None
    assert result.metadata == {}


def test_agent_result_rejects_invalid_success_type() -> None:
    with pytest.raises(ValidationError):
        AgentResult(success=None)  # type: ignore[arg-type]


def test_agent_result_rejects_extra_fields() -> None:
    with pytest.raises(ValidationError):
        AgentResult(success=True, unexpected=1)  # type: ignore[call-arg]


def test_agent_context_fields_and_serialization() -> None:
    ctx = AgentContext(
        document_id="doc-1",
        job_id="job-1",
        user_id="user-1",
        correlation_id="corr-1",
        extra={"trace": "t1"},
    )
    payload = ctx.model_dump()
    restored = AgentContext.model_validate(payload)
    assert restored.document_id == "doc-1"
    assert restored.job_id == "job-1"
    assert restored.user_id == "user-1"
    assert restored.correlation_id == "corr-1"
    assert restored.extra == {"trace": "t1"}


def test_agent_context_defaults() -> None:
    ctx = AgentContext()
    assert ctx.document_id is None
    assert ctx.extra == {}


def test_base_agent_cannot_instantiate() -> None:
    with pytest.raises(TypeError):
        BaseAgent()  # type: ignore[abstract]


class _StubAgent(BaseAgent):
    name = "stub"

    async def run(self, input: dict, context: AgentContext) -> AgentResult:
        if input.get("fail"):
            return await self.on_error(RuntimeError("boom"), context)
        return AgentResult(success=True, data={"echo": input.get("value")})


@pytest.mark.asyncio
async def test_stub_agent_success_path() -> None:
    agent = _StubAgent()
    result = await agent.run({"value": 42}, AgentContext(document_id="d1"))
    assert result.success is True
    assert result.data == {"echo": 42}
    assert result.error is None


@pytest.mark.asyncio
async def test_default_on_error_shape() -> None:
    agent = _StubAgent()
    ctx = AgentContext(document_id="d1", job_id="j1", correlation_id="c1")
    result = await agent.on_error(ValueError("bad input"), ctx)
    assert result.success is False
    assert result.error == "bad input"
    assert result.data is None
    assert result.metadata["agent"] == "stub"
    assert result.metadata["error_type"] == "ValueError"
    assert result.metadata["document_id"] == "d1"
    assert result.metadata["job_id"] == "j1"
    assert result.metadata["correlation_id"] == "c1"


@pytest.mark.asyncio
async def test_on_error_overridable_by_subclass() -> None:
    class Custom(BaseAgent):
        name = "custom"

        async def run(self, input: dict, context: AgentContext) -> AgentResult:
            return AgentResult(success=True)

        async def on_error(self, error: Exception, context: AgentContext) -> AgentResult:
            return AgentResult(
                success=False,
                error=f"custom:{error}",
                metadata={"agent": self.name, "custom": True},
            )

    result = await Custom().on_error(RuntimeError("x"), AgentContext())
    assert result.error == "custom:x"
    assert result.metadata["custom"] is True


def test_concrete_subclass_must_implement_run() -> None:
    class Incomplete(BaseAgent):
        name = "incomplete"

    with pytest.raises(TypeError):
        Incomplete()  # type: ignore[abstract]
