"""Format ranked chunks into a single context string for downstream LLM/chat."""

from __future__ import annotations

from app.rag.config import RagConfig
from app.rag.types import RankedChunk


class ContextBuilder:
    def build(
        self,
        chunks: list[RankedChunk],
        *,
        config: RagConfig | None = None,
    ) -> str:
        if not chunks:
            return ""

        budget = config.max_context_chars if config is not None else None
        parts: list[str] = []
        current = ""

        for chunk in chunks:
            block = f"[{chunk.index}] {chunk.text}"
            candidate = block if not parts else current + "\n\n" + block
            if budget is not None and len(candidate) > budget:
                if not parts:
                    # Single block still truncated to budget
                    return block[:budget]
                break
            parts.append(block)
            current = candidate

        return current
