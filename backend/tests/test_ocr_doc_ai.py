"""Unit tests for Document AI OCR stub adapter."""

import pytest

from app.adapters.ocr.doc_ai_adapter import DocAIAdapter
from app.adapters.protocols import OCRProvider
from app.adapters.types import OCRResult


def test_doc_ai_adapter_satisfies_ocr_provider_protocol() -> None:
    assert isinstance(DocAIAdapter(), OCRProvider)


@pytest.mark.asyncio
async def test_stub_extract_text_returns_deterministic_ocr_result() -> None:
    adapter = DocAIAdapter(project_id="proj", processor_id="proc")
    result = await adapter.extract_text(b"scan-bytes")

    assert isinstance(result, OCRResult)
    assert result.text == "[document-ai-stub]"
    assert result.pages == 1
    assert result.metadata["stub"] is True
    assert result.metadata["bytes"] == len(b"scan-bytes")
    assert result.metadata["project_id"] == "proj"
