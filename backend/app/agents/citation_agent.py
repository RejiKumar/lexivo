"""Citation Agent — shapes citations and grounded answers via LLMProvider.

Accepts prior retrieval payload from Master state; no retrieval pipeline calls.
Invoked only via Master Agent node registry.
"""

from __future__ import annotations

import json
from typing import Any

from app.adapters.protocols import LLMProvider
from app.agents.base_agent import AgentContext, AgentResult, BaseAgent
from app.prompts import prompt_loader

CANNOT_ANSWER = "I cannot answer from the document."


class CitationAgent(BaseAgent):
    """Specialized Citation agent. Invoked only via Master Agent node registry."""

    name = "citation"

    def __init__(self, llm: LLMProvider) -> None:
        self._llm = llm

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        question = input.get("question")
        if not isinstance(question, str) or not question.strip():
            return await self.on_error(
                ValueError("Citation Agent input requires non-empty question"),
                context,
            )

        context_text = input.get("context")
        if context_text is None:
            context_text = ""
        if not isinstance(context_text, str):
            return await self.on_error(
                ValueError("Citation Agent context must be a string"),
                context,
            )

        chunks = input.get("chunks")
        if chunks is None:
            chunks = input.get("ranked_chunks")
        if chunks is None:
            chunks = []
        if not isinstance(chunks, list):
            return await self.on_error(
                ValueError("Citation Agent chunks must be a list"),
                context,
            )

        ungrounded = bool(input.get("ungrounded")) or (
            not context_text.strip() or len(chunks) == 0
        )
        if ungrounded:
            return AgentResult(
                success=True,
                data={
                    "answer": CANNOT_ANSWER,
                    "citations": [],
                    "ungrounded": True,
                    "cannot_answer": True,
                },
                metadata={
                    "agent": self.name,
                    "document_id": context.document_id,
                    "job_id": context.job_id,
                },
            )

        try:
            prompt = prompt_loader.load("citation", version="v1")
            rendered = prompt.template.format(
                question=question.strip(),
                context=context_text.strip(),
            )
            raw = await self._llm.complete(rendered)
            answer, citations = _parse_citation_response(raw, chunks)
        except Exception as exc:
            return await self.on_error(exc, context)

        return AgentResult(
            success=True,
            data={
                "answer": answer,
                "citations": citations,
                "ungrounded": False,
                "cannot_answer": False,
                "prompt_name": prompt.name,
                "prompt_version": prompt.version,
            },
            metadata={
                "agent": self.name,
                "document_id": context.document_id,
                "job_id": context.job_id,
            },
        )


def _parse_citation_response(
    raw: str,
    chunks: list[Any],
) -> tuple[str, list[dict[str, Any]]]:
    text = (raw or "").strip()
    if not text:
        raise ValueError("LLM returned empty citation response")

    try:
        payload = json.loads(text)
    except json.JSONDecodeError:
        citations = _fallback_citations(chunks)
        return text, citations

    if not isinstance(payload, dict):
        raise ValueError("Citation LLM response must be a JSON object")

    answer = payload.get("answer")
    if not isinstance(answer, str) or not answer.strip():
        raise ValueError("Citation LLM response missing answer")

    citations_raw = payload.get("citations", [])
    citations: list[dict[str, Any]] = []
    if isinstance(citations_raw, list):
        for item in citations_raw:
            if not isinstance(item, dict):
                continue
            index = item.get("index", item.get("chunk_id"))
            snippet = item.get("snippet") or item.get("text") or ""
            citations.append(
                {
                    "chunk_id": index,
                    "index": index,
                    "snippet": snippet,
                }
            )
    if not citations:
        citations = _fallback_citations(chunks)
    return answer.strip(), citations


def _fallback_citations(chunks: list[Any]) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    for chunk in chunks[:3]:
        if isinstance(chunk, dict):
            index = chunk.get("index")
            snippet = chunk.get("text") or chunk.get("snippet") or ""
        else:
            index = getattr(chunk, "index", None)
            snippet = getattr(chunk, "text", "") or ""
        out.append({"chunk_id": index, "index": index, "snippet": snippet})
    return out
