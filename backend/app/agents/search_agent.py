"""Search Agent — retrieves context via RagPipeline.query only.

Does not invent final answer prose; citation shaping is Master-orchestrated.
Invoked only via Master Agent node registry.
"""

from __future__ import annotations

from typing import Any

from app.agents.base_agent import AgentContext, AgentResult, BaseAgent
from app.rag.config import RagConfig
from app.rag.pipeline import RagPipeline


class SearchAgent(BaseAgent):
    """Specialized Search agent. Invoked only via Master Agent node registry."""

    name = "search"

    def __init__(self, rag_pipeline: RagPipeline) -> None:
        self._rag = rag_pipeline

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        document_id = input.get("document_id") or context.document_id
        question = input.get("question")
        if not isinstance(document_id, str) or not document_id.strip():
            return await self.on_error(
                ValueError("Search Agent input requires document_id"),
                context,
            )
        if not isinstance(question, str) or not question.strip():
            return await self.on_error(
                ValueError("Search Agent input requires non-empty question"),
                context,
            )

        config = _optional_config(input.get("config"))
        try:
            answer = await self._rag.query(
                document_id.strip(),
                question.strip(),
                config=config,
            )
        except Exception as exc:
            return await self.on_error(exc, context)

        chunks = [
            {
                "text": c.text,
                "index": c.index,
                "score": c.score,
                "metadata": dict(c.metadata),
            }
            for c in answer.chunks
        ]
        context_text = answer.context or ""
        ungrounded = not context_text.strip() or not chunks

        return AgentResult(
            success=True,
            data={
                "document_id": answer.document_id,
                "question": answer.question,
                "context": context_text,
                "chunks": chunks,
                "ranked_chunks": chunks,
                "ungrounded": ungrounded,
                # Search never invents a final prose answer.
                "answer": None,
            },
            metadata={
                "agent": self.name,
                "document_id": context.document_id or document_id,
                "job_id": context.job_id,
            },
        )


def _optional_config(raw: Any) -> RagConfig | None:
    if raw is None:
        return None
    if isinstance(raw, RagConfig):
        return raw
    if isinstance(raw, dict):
        return RagConfig(**raw)
    raise ValueError("Search Agent config must be RagConfig or dict")
