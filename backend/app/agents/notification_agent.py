"""Notification Agent — in-app + push Protocol stub (STEP 3.6 stub)."""

from __future__ import annotations

from typing import Any

from app.agents.base_agent import AgentContext, AgentResult, BaseAgent


class NotificationAgent(BaseAgent):
    """Specialized Notification agent. Invoked only via Master Agent node registry."""

    name = "notification"

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        raise NotImplementedError("NotificationAgent.run not implemented")
