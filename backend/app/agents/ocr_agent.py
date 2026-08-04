"""OCR Agent — extracts text via OCRProvider Protocol only (no vendor SDKs)."""

from __future__ import annotations

from typing import Any

from app.adapters.protocols import OCRProvider
from app.agents.base_agent import AgentContext, AgentResult, BaseAgent
from app.prompts import prompt_loader


class OCRAgent(BaseAgent):
    """Specialized OCR agent. Invoked only via Master Agent node registry."""

    name = "ocr"

    def __init__(self, ocr: OCRProvider) -> None:
        self._ocr = ocr

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        # Prove shared prompts pattern even when extraction is Protocol-only.
        prompt = prompt_loader.load("ocr", version="v1")

        file_bytes = input.get("file_bytes")
        if not isinstance(file_bytes, (bytes, bytearray)):
            return await self.on_error(
                ValueError("OCR Agent input requires file_bytes: bytes"),
                context,
            )

        try:
            ocr_result = await self._ocr.extract_text(bytes(file_bytes))
        except Exception as exc:
            return await self.on_error(exc, context)

        return AgentResult(
            success=True,
            data={
                "text": ocr_result.text,
                "pages": ocr_result.pages,
                "ocr_metadata": dict(ocr_result.metadata),
                "prompt_name": prompt.name,
                "prompt_version": prompt.version,
            },
            metadata={
                "agent": self.name,
                "document_id": context.document_id,
                "job_id": context.job_id,
            },
        )
