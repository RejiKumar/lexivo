"""Unit tests for TranslationAgent (EN↔ES,FR,DE,HI,PT)."""

from __future__ import annotations

from pathlib import Path
from unittest.mock import patch

import pytest

from app.agents.base_agent import AgentContext, BaseAgent
from app.agents.translation_agent import TranslationAgent
from app.prompts.prompt_loader import PromptTemplate
from tests.fakes import FakeLLMProvider


def test_translation_agent_is_base_agent_with_stable_name() -> None:
    agent = TranslationAgent(FakeLLMProvider())
    assert isinstance(agent, BaseAgent)
    assert agent.name == "translation"


@pytest.mark.asyncio
@pytest.mark.parametrize(
    ("source", "target"),
    [
        ("en", "es"),
        ("EN", "FR"),
        ("de", "en"),
        ("hi", "en"),
        ("pt", "en"),
    ],
)
async def test_translation_agent_supported_pairs(source: str, target: str) -> None:
    fake = FakeLLMProvider(response="traducido")
    agent = TranslationAgent(fake)
    result = await agent.run(
        {"text": "Hello", "source_lang": source, "target_lang": target},
        AgentContext(),
    )
    assert result.success is True
    assert result.data["translated_text"] == "traducido"
    assert result.data["source_lang"] == source.lower()
    assert result.data["target_lang"] == target.lower()


@pytest.mark.asyncio
async def test_translation_agent_unsupported_language_no_llm() -> None:
    fake = FakeLLMProvider(response="should-not-run")
    agent = TranslationAgent(fake)
    result = await agent.run(
        {"text": "Hello", "source_lang": "en", "target_lang": "ja"},
        AgentContext(),
    )
    assert result.success is False
    assert "unsupported" in (result.error or "").lower()
    assert fake.prompts == []


@pytest.mark.asyncio
async def test_translation_agent_non_en_pair_rejected() -> None:
    fake = FakeLLMProvider(response="nope")
    agent = TranslationAgent(fake)
    result = await agent.run(
        {"text": "Hola", "source_lang": "es", "target_lang": "fr"},
        AgentContext(),
    )
    assert result.success is False
    assert fake.prompts == []


@pytest.mark.asyncio
async def test_translation_agent_success_loads_prompt() -> None:
    fake = FakeLLMProvider(response="Bonjour")
    agent = TranslationAgent(fake)
    stub = PromptTemplate(
        name="translation",
        version="v1",
        template="Translate {source_lang}->{target_lang}: {text}",
        metadata={},
    )
    with patch(
        "app.agents.translation_agent.prompt_loader.load",
        return_value=stub,
    ) as load_mock:
        result = await agent.run(
            {"text": "Hello", "source_lang": "en", "target_lang": "fr"},
            AgentContext(document_id="d1"),
        )
    load_mock.assert_called_once_with("translation", version="v1")
    assert result.success is True
    assert fake.prompts[0] == "Translate en->fr: Hello"


def test_translation_agent_no_vendor_or_agent_imports() -> None:
    source = (
        Path(__file__).resolve().parents[1]
        / "app"
        / "agents"
        / "translation_agent.py"
    ).read_text(encoding="utf-8")
    for token in ("openai", "anthropic", "google.generativeai", "summary_agent"):
        assert token not in source
    assert "You are Lexivo's translation assistant" not in source
