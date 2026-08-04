"""Temporary OCRProvider stubs for DI until §6 SDK adapters land."""

from app.adapters.types import OCRResult


class MistralOCRAdapter:
    """Default OCRProvider binding (SDK integration in §6)."""

    async def extract_text(self, file: bytes) -> OCRResult:
        raise NotImplementedError("Mistral OCR SDK adapter not implemented yet (§6)")


class DocAIAdapter:
    """Alternate OCRProvider stub (SDK integration in §6)."""

    async def extract_text(self, file: bytes) -> OCRResult:
        raise NotImplementedError("Document AI stub adapter not implemented yet (§6)")
