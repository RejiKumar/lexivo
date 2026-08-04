"""Summary Agent — short + detailed summaries via LLMProvider + prompts/.

Invoked only via Master Agent node registry. No vendor SDKs; no agent imports.
"""

from __future__ import annotations

import json
from typing import Any

from app.adapters.protocols import LLMProvider
from app.agents.base_agent import AgentContext, AgentResult, BaseAgent
from app.prompts import prompt_loader


class SummaryAgent(BaseAgent):
    """Specialized Summary agent. Invoked only via Master Agent node registry."""

    name = "summary"

    def __init__(self, llm: LLMProvider) -> None:
        self._llm = llm

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        text = input.get("text")
        if text is None:
            text = input.get("extracted_text")
        if not isinstance(text, str) or not text.strip():
            return await self.on_error(
                ValueError("Summary Agent input requires non-empty text or extracted_text"),
                context,
            )

        try:
            prompt = prompt_loader.load("summary", version="v1")
            rendered = prompt.template.format(text=text.strip())
            raw = await self._llm.complete(rendered)
            short_summary, detailed_summary = _parse_summary_response(raw)
        except Exception as exc:
            return await self.on_error(exc, context)

        return AgentResult(
            success=True,
            data={
                "short_summary": short_summary,
                "detailed_summary": detailed_summary,
                "prompt_name": prompt.name,
                "prompt_version": prompt.version,
            },
            metadata={
                "agent": self.name,
                "document_id": context.document_id,
                "job_id": context.job_id,
            },
        )


def _parse_summary_response(raw: str) -> tuple[str, str]:
    """Parse LLM JSON (or fall back to treating whole body as both summaries)."""
    text = (raw or "").strip()
    if not text:
        raise ValueError("LLM returned empty summary response")

    try:
        payload = json.loads(text)
    except json.JSONDecodeError:
        # Tolerate non-JSON fakes: use full body for both fields.
        return text, text

    if not isinstance(payload, dict):
        raise ValueError("Summary LLM response must be a JSON object")

    short = payload.get("short_summary")
    detailed = payload.get("detailed_summary")
    if not isinstance(short, str) or not short.strip():
        raise ValueError("Summary LLM response missing short_summary")
    if not isinstance(detailed, str) or not detailed.strip():
        raise ValueError("Summary LLM response missing detailed_summary")
    return short.strip(), detailed.strip()
