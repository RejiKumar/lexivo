"""Unit tests for Mistral OCR adapter (mocked HTTP — no live Mistral)."""

import json

import httpx
import pytest

from app.adapters.ocr.mistral_ocr_adapter import MistralOCRAdapter
from app.adapters.protocols import OCRProvider
from app.adapters.types import OCRResult


def _ocr_response() -> httpx.Response:
    body = {
        "pages": [
            {"index": 0, "markdown": "Page one text"},
            {"index": 1, "markdown": "Page two text"},
        ]
    }
    return httpx.Response(200, json=body)


@pytest.mark.asyncio
async def test_mistral_adapter_satisfies_ocr_provider_protocol() -> None:
    transport = httpx.MockTransport(lambda request: _ocr_response())
    async with httpx.AsyncClient(transport=transport) as client:
        adapter = MistralOCRAdapter(api_key="mistral-key", client=client)
        assert isinstance(adapter, OCRProvider)


@pytest.mark.asyncio
async def test_extract_text_returns_ocr_result() -> None:
    def handler(request: httpx.Request) -> httpx.Response:
        assert request.headers["Authorization"] == "Bearer mistral-key"
        assert str(request.url).endswith("/ocr")
        payload = json.loads(request.content)
        assert payload["model"] == "mistral-ocr-latest"
        assert "document_url" in payload["document"]
        return _ocr_response()

    transport = httpx.MockTransport(handler)
    async with httpx.AsyncClient(transport=transport) as client:
        adapter = MistralOCRAdapter(api_key="mistral-key", client=client)
        result = await adapter.extract_text(b"%PDF-fake")

    assert isinstance(result, OCRResult)
    assert result.text == "Page one text\n\nPage two text"
    assert result.pages == 2
    assert result.metadata["provider"] == "mistral"


@pytest.mark.asyncio
async def test_extract_text_without_api_key_raises() -> None:
    adapter = MistralOCRAdapter(api_key="")
    with pytest.raises(RuntimeError, match="not configured"):
        await adapter.extract_text(b"data")
