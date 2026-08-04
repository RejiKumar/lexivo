"""Citation Agent — grounded answer + citation shaping via LLM (STEP 3.6 stub)."""

from __future__ import annotations

from typing import Any

from app.agents.base_agent import AgentContext, AgentResult, BaseAgent


class CitationAgent(BaseAgent):
    """Specialized Citation agent. Invoked only via Master Agent node registry."""

    name = "citation"

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        raise NotImplementedError("CitationAgent.run not implemented")
