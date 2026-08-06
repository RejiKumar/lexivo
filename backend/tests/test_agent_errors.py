"""Agent failures must keep their provider error type for HTTP status mapping."""

from __future__ import annotations

from app.adapters.llm.errors import LLMProviderError, LLMRateLimitError
from app.adapters.storage.errors import StorageNotConfiguredError
from app.agents.base_agent import AgentResult
from app.tasks.agent_errors import agent_failure_error


def test_rate_limit_metadata_maps_to_rate_limit_error() -> None:
    result = AgentResult(
        success=False,
        error="Gemini rate limit / quota exceeded",
        metadata={"error_type": "LLMRateLimitError"},
    )
    exc = agent_failure_error(result, "Summary agent failed")
    assert isinstance(exc, LLMRateLimitError)
    assert "rate limit" in str(exc)


def test_storage_metadata_maps_to_storage_error() -> None:
    result = AgentResult(
        success=False,
        error="Supabase Storage is not configured",
        metadata={"error_type": "StorageNotConfiguredError"},
    )
    assert isinstance(
        agent_failure_error(result, "Export agent failed"),
        StorageNotConfiguredError,
    )


def test_unknown_metadata_falls_back_to_runtime_error() -> None:
    result = AgentResult(success=False, error=None, metadata={"error_type": "KeyError"})
    exc = agent_failure_error(result, "Summary agent failed")
    assert type(exc) is RuntimeError
    assert not isinstance(exc, LLMProviderError)
    assert str(exc) == "Summary agent failed"
