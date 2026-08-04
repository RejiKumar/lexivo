"""Unit tests for Gemini LLM adapter (mocked HTTP — no live Gemini)."""

import json

import httpx
import pytest

from app.adapters.llm.gemini_adapter import GeminiLLMAdapter
from app.adapters.protocols import LLMProvider


def _gemini_response(text: str) -> httpx.Response:
    body = {
        "candidates": [
            {"content": {"parts": [{"text": text}], "role": "model"}},
        ]
    }
    return httpx.Response(200, json=body)


@pytest.mark.asyncio
async def test_gemini_adapter_satisfies_llm_provider_protocol() -> None:
    transport = httpx.MockTransport(lambda request: _gemini_response("ok"))
    async with httpx.AsyncClient(transport=transport) as client:
        adapter = GeminiLLMAdapter(api_key="test-key", client=client)
        assert isinstance(adapter, LLMProvider)


@pytest.mark.asyncio
async def test_complete_returns_string_from_mocked_response() -> None:
    def handler(request: httpx.Request) -> httpx.Response:
        assert request.url.params.get("key") == "test-key"
        assert "gemini-2.0-flash:generateContent" in str(request.url)
        payload = json.loads(request.content)
        assert payload["contents"][0]["parts"][0]["text"] == "Hello"
        return _gemini_response("Hi there")

    transport = httpx.MockTransport(handler)
    async with httpx.AsyncClient(transport=transport) as client:
        adapter = GeminiLLMAdapter(api_key="test-key", client=client)
        result = await adapter.complete("Hello")

    assert result == "Hi there"
    assert isinstance(result, str)


@pytest.mark.asyncio
async def test_complete_without_api_key_raises() -> None:
    adapter = GeminiLLMAdapter(api_key="")
    with pytest.raises(RuntimeError, match="not configured"):
        await adapter.complete("Hello")
