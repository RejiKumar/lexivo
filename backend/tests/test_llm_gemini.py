"""Unit tests for Gemini LLM adapter (mocked HTTP — no live Gemini)."""

import json

import httpx
import pytest

from app.adapters.llm.errors import LLMProviderError, LLMRateLimitError
from app.adapters.llm.gemini_adapter import GeminiLLMAdapter
from app.adapters.llm.openai_adapter import OpenAILLMAdapter
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
        # Key travels in a header so it never lands in URLs, logs, or errors.
        assert request.headers["x-goog-api-key"] == "test-key"
        assert "key=" not in str(request.url)
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


@pytest.mark.asyncio
async def test_rate_limited_retries_then_falls_back_to_openai(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    from tenacity import wait_none

    monkeypatch.setattr(
        "app.adapters.llm.gemini_adapter.wait_exponential",
        lambda **_kwargs: wait_none(),
    )

    calls = {"n": 0}

    def handler(_request: httpx.Request) -> httpx.Response:
        calls["n"] += 1
        return httpx.Response(429)

    transport = httpx.MockTransport(handler)
    fallback = OpenAILLMAdapter(api_key="openai-key")
    async with httpx.AsyncClient(transport=transport) as client:
        adapter = GeminiLLMAdapter(
            api_key="super-secret-key",
            client=client,
            fallback=fallback,
        )
        result = await adapter.complete("Hello world")

    assert calls["n"] == 3
    assert result.startswith("[openai-stub")
    assert "Hello world" in result


@pytest.mark.asyncio
async def test_rate_limited_without_fallback_raises_after_retries(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    from tenacity import wait_none

    monkeypatch.setattr(
        "app.adapters.llm.gemini_adapter.wait_exponential",
        lambda **_kwargs: wait_none(),
    )

    transport = httpx.MockTransport(lambda _r: httpx.Response(429))
    async with httpx.AsyncClient(transport=transport) as client:
        adapter = GeminiLLMAdapter(api_key="super-secret-key", client=client)
        with pytest.raises(LLMRateLimitError) as excinfo:
            await adapter.complete("Hello")

    assert "super-secret-key" not in str(excinfo.value)
    assert excinfo.value.status_code == 429


@pytest.mark.asyncio
async def test_rejected_key_raises_provider_error_without_key() -> None:
    transport = httpx.MockTransport(lambda request: httpx.Response(403))
    async with httpx.AsyncClient(transport=transport) as client:
        adapter = GeminiLLMAdapter(api_key="super-secret-key", client=client)
        with pytest.raises(LLMProviderError) as excinfo:
            await adapter.complete("Hello")

    assert "super-secret-key" not in str(excinfo.value)
    assert "GEMINI_API_KEY" in str(excinfo.value)
