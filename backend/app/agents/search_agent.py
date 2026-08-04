"""Search Agent — RagPipeline.query / HybridRetriever (STEP 3.6 stub)."""

from __future__ import annotations

from typing import Any

from app.agents.base_agent import AgentContext, AgentResult, BaseAgent


class SearchAgent(BaseAgent):
    """Specialized Search agent. Invoked only via Master Agent node registry."""

    name = "search"

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        raise NotImplementedError("SearchAgent.run not implemented")
