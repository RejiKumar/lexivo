"""Analytics Agent — emit structured events via AnalyticsProvider (STEP 3.6 stub)."""

from __future__ import annotations

from typing import Any

from app.agents.base_agent import AgentContext, AgentResult, BaseAgent


class AnalyticsAgent(BaseAgent):
    """Specialized Analytics agent. Invoked only via Master Agent node registry."""

    name = "analytics"

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        raise NotImplementedError("AnalyticsAgent.run not implemented")
