"""Translation Agent — EN↔ES,FR,DE,HI,PT via LLMProvider (STEP 3.6 stub)."""

from __future__ import annotations

from typing import Any

from app.agents.base_agent import AgentContext, AgentResult, BaseAgent


class TranslationAgent(BaseAgent):
    """Specialized Translation agent. Invoked only via Master Agent node registry."""

    name = "translation"

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        raise NotImplementedError("TranslationAgent.run not implemented")
