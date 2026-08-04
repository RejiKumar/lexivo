"""BaseAgent contract (architecture.md §3.4).

Every specialized agent subclasses BaseAgent and implements only ``run()``.
Default ``on_error`` shapes failures as AgentResult; retry policy is no-retry
(deterministic for unit tests). Subclasses may override ``on_error``.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class AgentResult(BaseModel):
    """Uniform result envelope returned by every agent ``run`` / ``on_error``."""

    model_config = ConfigDict(extra="forbid")

    success: bool
    data: dict[str, Any] | None = None
    error: str | None = None
    metadata: dict[str, Any] = Field(default_factory=dict)


class AgentContext(BaseModel):
    """Correlation / tracing context passed through the Master graph."""

    model_config = ConfigDict(extra="forbid")

    document_id: str | None = None
    job_id: str | None = None
    user_id: str | None = None
    correlation_id: str | None = None
    extra: dict[str, Any] = Field(default_factory=dict)


class BaseAgent(ABC):
    """Abstract agent: subclasses set ``name`` and implement ``run`` only."""

    name: str

    @abstractmethod
    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        """Execute the agent. Subclasses implement domain logic here only."""

    async def on_error(self, error: Exception, context: AgentContext) -> AgentResult:
        """Default error shaping — no retry. Overridable by subclasses."""
        agent_name = getattr(self, "name", self.__class__.__name__)
        return AgentResult(
            success=False,
            data=None,
            error=str(error),
            metadata={
                "agent": agent_name,
                "error_type": type(error).__name__,
                "document_id": context.document_id,
                "job_id": context.job_id,
                "correlation_id": context.correlation_id,
            },
        )
