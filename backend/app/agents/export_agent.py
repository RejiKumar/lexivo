"""Export Agent — multi-section PDF + StorageProvider (STEP 3.6 stub)."""

from __future__ import annotations

from typing import Any

from app.agents.base_agent import AgentContext, AgentResult, BaseAgent


class ExportAgent(BaseAgent):
    """Specialized Export agent. Invoked only via Master Agent node registry."""

    name = "export"

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        raise NotImplementedError("ExportAgent.run not implemented")
