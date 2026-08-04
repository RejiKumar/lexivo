"""Translation Agent — EN↔ES,FR,DE,HI,PT via LLMProvider + prompts/.

Invoked only via Master Agent node registry. No vendor SDKs; no agent imports.
"""

from __future__ import annotations

from typing import Any

from app.adapters.protocols import LLMProvider
from app.agents.base_agent import AgentContext, AgentResult, BaseAgent
from app.prompts import prompt_loader

SUPPORTED_LANGS = frozenset({"en", "es", "fr", "de", "hi", "pt"})


class TranslationAgent(BaseAgent):
    """Specialized Translation agent. Invoked only via Master Agent node registry."""

    name = "translation"

    def __init__(self, llm: LLMProvider) -> None:
        self._llm = llm

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        text = input.get("text")
        if text is None:
            text = input.get("extracted_text")
        if not isinstance(text, str) or not text.strip():
            return await self.on_error(
                ValueError("Translation Agent input requires non-empty text"),
                context,
            )

        try:
            source_lang = _normalize_lang(input.get("source_lang"))
            target_lang = _normalize_lang(input.get("target_lang"))
        except ValueError as exc:
            return AgentResult(
                success=False,
                data=None,
                error=str(exc),
                metadata={
                    "agent": self.name,
                    "error_type": "ValidationError",
                    "document_id": context.document_id,
                    "job_id": context.job_id,
                },
            )

        if not _is_supported_pair(source_lang, target_lang):
            return AgentResult(
                success=False,
                data={
                    "source_lang": source_lang,
                    "target_lang": target_lang,
                    "supported_langs": sorted(SUPPORTED_LANGS),
                },
                error=(
                    f"Unsupported language pair {source_lang!r}->{target_lang!r}; "
                    "v1 requires EN↔ES,FR,DE,HI,PT"
                ),
                metadata={
                    "agent": self.name,
                    "error_type": "ValidationError",
                    "document_id": context.document_id,
                    "job_id": context.job_id,
                },
            )

        try:
            prompt = prompt_loader.load("translation", version="v1")
            rendered = prompt.template.format(
                text=text.strip(),
                source_lang=source_lang,
                target_lang=target_lang,
            )
            translated = await self._llm.complete(rendered)
        except Exception as exc:
            return await self.on_error(exc, context)

        if not isinstance(translated, str) or not translated.strip():
            return await self.on_error(
                ValueError("LLM returned empty translation"),
                context,
            )

        return AgentResult(
            success=True,
            data={
                "translated_text": translated.strip(),
                "source_lang": source_lang,
                "target_lang": target_lang,
                "prompt_name": prompt.name,
                "prompt_version": prompt.version,
            },
            metadata={
                "agent": self.name,
                "document_id": context.document_id,
                "job_id": context.job_id,
            },
        )


def _normalize_lang(value: Any) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ValueError("source_lang and target_lang are required")
    code = value.strip().lower()
    if code not in SUPPORTED_LANGS:
        raise ValueError(f"Unsupported language code: {value!r}")
    return code


def _is_supported_pair(source: str, target: str) -> bool:
    if source == target:
        return False
    # v1: English on one side of the pair.
    return source == "en" or target == "en"
