"""Master Agent — LangGraph orchestration via node registry only.

Specialized agents never import each other; only this module wires them into
the graph. Public entrypoint: ``run_master`` / ``MasterAgent.invoke``.

Factory style: ``build_master_agent`` registers only agents whose dependencies
are provided (OCR required for the legacy OCR path). Security needs no ports
and is registered when ``include_security=True`` (default). Search→Citation
multi-step intents (``ask`` / ``rag_chat``) require both search and citation
deps and are sequenced only through graph state — never agent→agent calls.
"""

from __future__ import annotations

from typing import Any, TypedDict

from langgraph.graph import END, START, StateGraph

from app.adapters.protocols import (
    AnalyticsProvider,
    LLMProvider,
    NotificationStore,
    OCRProvider,
    PushProvider,
    StorageProvider,
)
from app.agents.analytics_agent import AnalyticsAgent
from app.agents.base_agent import AgentContext, AgentResult, BaseAgent
from app.agents.citation_agent import CitationAgent
from app.agents.export_agent import ExportAgent
from app.agents.notification_agent import NotificationAgent
from app.agents.ocr_agent import OCRAgent
from app.agents.search_agent import SearchAgent
from app.agents.security_agent import SecurityAgent
from app.agents.summary_agent import SummaryAgent
from app.agents.translation_agent import TranslationAgent
from app.rag.pipeline import RagPipeline

SINGLE_INTENT_NODES = frozenset(
    {
        "ocr",
        "summary",
        "translation",
        "search",
        "citation",
        "export",
        "security",
        "notification",
        "analytics",
    }
)
ASK_INTENTS = frozenset({"ask", "rag_chat"})


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
    search_result: dict[str, Any] | None


class MasterAgent:
    """LangGraph Master orchestrator — sequences agents via the node registry."""

    def __init__(self, registry: NodeRegistry | None = None) -> None:
        self.registry = registry or NodeRegistry()
        self._graph = None

    def register(self, name: str, agent: BaseAgent) -> None:
        self.registry.register(name, agent)
        self._graph = None

    def _make_leaf_node(self, agent_name: str):
        registry = self.registry

        async def node(state: MasterGraphState) -> dict[str, Any]:
            agent = registry.resolve(agent_name)
            ctx = AgentContext.model_validate(state["context"])
            result = await agent.run(state["input"], ctx)
            return {"result": result.model_dump()}

        node.__name__ = f"{agent_name}_node"
        return node

    def _build_graph(self):
        registry = self.registry
        registered = registry.names()

        async def search_node(state: MasterGraphState) -> dict[str, Any]:
            agent = registry.resolve("search")
            ctx = AgentContext.model_validate(state["context"])
            result = await agent.run(state["input"], ctx)
            dumped = result.model_dump()
            return {"result": dumped, "search_result": dumped}

        async def citation_after_search_node(state: MasterGraphState) -> dict[str, Any]:
            agent = registry.resolve("citation")
            ctx = AgentContext.model_validate(state["context"])
            search = state.get("search_result") or {}
            search_data = search.get("data") if isinstance(search, dict) else None
            search_data = search_data if isinstance(search_data, dict) else {}
            citation_input = {
                "question": state["input"].get("question")
                or search_data.get("question"),
                "context": search_data.get("context", ""),
                "chunks": search_data.get("chunks")
                or search_data.get("ranked_chunks")
                or [],
                "ranked_chunks": search_data.get("ranked_chunks")
                or search_data.get("chunks")
                or [],
                "ungrounded": search_data.get("ungrounded", False),
            }
            result = await agent.run(citation_input, ctx)
            return {"result": result.model_dump()}

        def route_intent(state: MasterGraphState) -> str:
            intent = state["intent"]
            if intent in ASK_INTENTS:
                if "search" not in registered or "citation" not in registered:
                    raise ValueError(
                        f"Master intent {intent!r} requires search and citation agents"
                    )
                return "search_then_cite"
            if intent in registered and intent in SINGLE_INTENT_NODES:
                return intent
            raise ValueError(f"Unsupported Master intent: {intent!r}")

        builder = StateGraph(MasterGraphState)

        route_map: dict[str, str] = {}
        for name in SINGLE_INTENT_NODES:
            if name not in registered:
                continue
            if name == "search":
                builder.add_node("search", search_node)
            elif name == "citation":
                builder.add_node("citation", self._make_leaf_node("citation"))
            else:
                builder.add_node(name, self._make_leaf_node(name))
            route_map[name] = name
            builder.add_edge(name, END)

        if "search" in registered and "citation" in registered:
            builder.add_node("search_then_cite", search_node)
            builder.add_node("citation_after_search", citation_after_search_node)
            builder.add_edge("search_then_cite", "citation_after_search")
            builder.add_edge("citation_after_search", END)
            route_map["search_then_cite"] = "search_then_cite"

        builder.add_conditional_edges(START, route_intent, route_map)
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
                "search_result": None,
            }
        )
        raw = final.get("result")
        if raw is None:
            return AgentResult(
                success=False,
                error=f"Master graph produced no result for intent={intent!r}",
            )
        return AgentResult.model_validate(raw)


def build_master_agent(
    *,
    ocr_provider: OCRProvider | None = None,
    llm: LLMProvider | None = None,
    rag_pipeline: RagPipeline | None = None,
    storage: StorageProvider | None = None,
    push: PushProvider | None = None,
    notification_store: NotificationStore | None = None,
    analytics: AnalyticsProvider | None = None,
    include_security: bool = True,
) -> MasterAgent:
    """Construct Master graph registering agents whose deps are provided.

    ``ocr_provider`` remains the primary dep for the Celery OCR path. Other
    agents are optional and registered only when their Protocol ports are
    injected. Security has no ports and is included by default.
    """
    master = MasterAgent()
    if ocr_provider is not None:
        master.register("ocr", OCRAgent(ocr_provider))
    if llm is not None:
        master.register("summary", SummaryAgent(llm))
        master.register("translation", TranslationAgent(llm))
        master.register("citation", CitationAgent(llm))
    if rag_pipeline is not None:
        master.register("search", SearchAgent(rag_pipeline))
    if storage is not None:
        master.register("export", ExportAgent(storage))
    if include_security:
        master.register("security", SecurityAgent())
    if notification_store is not None and push is not None:
        master.register(
            "notification",
            NotificationAgent(notification_store, push),
        )
    if analytics is not None:
        master.register("analytics", AnalyticsAgent(analytics))
    return master


async def run_master(
    intent: str,
    input: dict[str, Any],
    context: AgentContext,
    *,
    ocr_provider: OCRProvider | None = None,
    llm: LLMProvider | None = None,
    rag_pipeline: RagPipeline | None = None,
    storage: StorageProvider | None = None,
    push: PushProvider | None = None,
    notification_store: NotificationStore | None = None,
    analytics: AnalyticsProvider | None = None,
    include_security: bool = True,
) -> AgentResult:
    """Convenience Master entrypoint — only public orchestrator API for tasks."""
    master = build_master_agent(
        ocr_provider=ocr_provider,
        llm=llm,
        rag_pipeline=rag_pipeline,
        storage=storage,
        push=push,
        notification_store=notification_store,
        analytics=analytics,
        include_security=include_security,
    )
    return await master.invoke(intent, input, context)
