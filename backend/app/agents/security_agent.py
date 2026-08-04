"""Security Agent — payload validation / sanitization (STEP 3.6 stub)."""

from __future__ import annotations

from typing import Any

from app.agents.base_agent import AgentContext, AgentResult, BaseAgent


class SecurityAgent(BaseAgent):
    """Specialized Security agent. Invoked only via Master Agent node registry."""

    name = "security"

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        raise NotImplementedError("SecurityAgent.run not implemented")
