"""Unit tests for OpenAI LLM stub adapter."""

import pytest

from app.adapters.llm.openai_adapter import OpenAILLMAdapter
from app.adapters.protocols import LLMProvider


def test_openai_adapter_satisfies_llm_provider_protocol() -> None:
    assert isinstance(OpenAILLMAdapter(), LLMProvider)


@pytest.mark.asyncio
async def test_stub_complete_returns_deterministic_string() -> None:
    adapter = OpenAILLMAdapter(api_key="")
    result = await adapter.complete("Summarize this")
    assert result == "[openai-stub model=stub] Summarize this"


@pytest.mark.asyncio
async def test_stub_complete_includes_model_kwarg() -> None:
    adapter = OpenAILLMAdapter()
    result = await adapter.complete("Hi", model="gpt-4o")
    assert result == "[openai-stub model=gpt-4o] Hi"
