"""Google Document AI stub adapter — deterministic local/test OCR only."""

from __future__ import annotations

from app.adapters.types import OCRResult


class DocAIAdapter:
    """
    Stub OCRProvider behind the same Protocol as a production Document AI adapter.

    Returns a deterministic OCRResult for tests; does not call Google APIs.
    """

    def __init__(
        self,
        *,
        project_id: str = "",
        processor_id: str = "",
        location: str = "us",
    ) -> None:
        self._project_id = project_id
        self._processor_id = processor_id
        self._location = location

    async def extract_text(self, file: bytes) -> OCRResult:
        return OCRResult(
            text="[document-ai-stub]",
            pages=1,
            metadata={
                "provider": "document_ai",
                "stub": True,
                "bytes": len(file),
                "project_id": self._project_id or None,
                "processor_id": self._processor_id or None,
                "location": self._location,
            },
        )
