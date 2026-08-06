"""Re-raise agent failures as typed errors so routers map them to real statuses.

``AgentResult`` flattens exceptions to strings; ``metadata.error_type`` is the
only surviving hint about the original provider failure.
"""

from __future__ import annotations

from app.adapters.llm.errors import LLMProviderError, LLMRateLimitError
from app.adapters.storage.errors import StorageNotConfiguredError
from app.agents.base_agent import AgentResult

_ERROR_TYPES: dict[str, type[Exception]] = {
    "LLMProviderError": LLMProviderError,
    "LLMRateLimitError": LLMRateLimitError,
    "StorageNotConfiguredError": StorageNotConfiguredError,
}


def agent_failure_error(result: AgentResult, default: str) -> Exception:
    """Build the exception to raise for a failed ``AgentResult``."""
    message = result.error or default
    error_type = str(result.metadata.get("error_type") or "")
    factory = _ERROR_TYPES.get(error_type)
    if factory is not None:
        return factory(message)
    return RuntimeError(message)
