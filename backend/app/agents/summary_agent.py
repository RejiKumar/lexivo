"""Summary Agent — short + detailed summaries via LLMProvider (STEP 3.6 stub)."""

from __future__ import annotations

from typing import Any

from app.agents.base_agent import AgentContext, AgentResult, BaseAgent


class SummaryAgent(BaseAgent):
    """Specialized Summary agent. Invoked only via Master Agent node registry."""

    name = "summary"

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        raise NotImplementedError("SummaryAgent.run not implemented")
