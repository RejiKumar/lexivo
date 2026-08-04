"""Master Agent — LangGraph orchestration via node registry only.

Specialized agents never import each other; only this module wires them into
the graph. Public entrypoint: ``run_master`` / ``MasterAgent.invoke``.
"""

from __future__ import annotations

from typing import Any, TypedDict

from langgraph.graph import END, START, StateGraph

from app.adapters.protocols import OCRProvider
from app.agents.base_agent import AgentContext, AgentResult, BaseAgent
from app.agents.ocr_agent import OCRAgent


class UnknownAgentError(KeyError):
    """Raised when the node registry cannot resolve an agent name."""


class NodeRegistry:
    """Maps agent names to BaseAgent instances for Master graph nodes."""

    def __init__(self) -> None:
        self._agents: dict[str, BaseAgent] = {}

    def register(self, name: str, agent: BaseAgent) -> None:
        if not name:
            raise ValueError("Agent name is required")
        self._agents[name] = agent

    def resolve(self, name: str) -> BaseAgent:
        try:
            return self._agents[name]
        except KeyError as exc:
            raise UnknownAgentError(f"Unknown agent: {name!r}") from exc

    def names(self) -> frozenset[str]:
        return frozenset(self._agents)


class MasterGraphState(TypedDict):
    intent: str
    input: dict[str, Any]
    context: dict[str, Any]
    result: dict[str, Any] | None


class MasterAgent:
    """LangGraph Master orchestrator — sequences agents via the node registry."""

    def __init__(self, registry: NodeRegistry | None = None) -> None:
        self.registry = registry or NodeRegistry()
        self._graph = None

    def register(self, name: str, agent: BaseAgent) -> None:
        self.registry.register(name, agent)
        self._graph = None

    def _build_graph(self):
        registry = self.registry

        async def ocr_node(state: MasterGraphState) -> dict[str, Any]:
            agent = registry.resolve("ocr")
            ctx = AgentContext.model_validate(state["context"])
            result = await agent.run(state["input"], ctx)
            return {"result": result.model_dump()}

        def route_intent(state: MasterGraphState) -> str:
            intent = state["intent"]
            if intent == "ocr":
                return "ocr"
            raise ValueError(f"Unsupported Master intent: {intent!r}")

        builder = StateGraph(MasterGraphState)
        builder.add_node("ocr", ocr_node)
        builder.add_conditional_edges(START, route_intent, {"ocr": "ocr"})
        builder.add_edge("ocr", END)
        return builder.compile()

    def _compiled(self):
        if self._graph is None:
            self._graph = self._build_graph()
        return self._graph

    async def invoke(
        self,
        intent: str,
        input: dict[str, Any],
        context: AgentContext,
    ) -> AgentResult:
        """Public Master entrypoint used by Celery tasks and services."""
        graph = self._compiled()
        final = await graph.ainvoke(
            {
                "intent": intent,
                "input": input,
                "context": context.model_dump(),
                "result": None,
            }
        )
        raw = final.get("result")
        if raw is None:
            return AgentResult(
                success=False,
                error=f"Master graph produced no result for intent={intent!r}",
            )
        return AgentResult.model_validate(raw)


def build_master_agent(*, ocr_provider: OCRProvider) -> MasterAgent:
    """Construct a Master graph with OCR node wired (STEP 3.4 scope only)."""
    master = MasterAgent()
    master.register("ocr", OCRAgent(ocr_provider))
    return master


async def run_master(
    intent: str,
    input: dict[str, Any],
    context: AgentContext,
    *,
    ocr_provider: OCRProvider,
) -> AgentResult:
    """Convenience Master entrypoint — only public orchestrator API for tasks."""
    master = build_master_agent(ocr_provider=ocr_provider)
    return await master.invoke(intent, input, context)
