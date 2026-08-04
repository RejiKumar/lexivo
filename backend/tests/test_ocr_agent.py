"""Unit tests for OCRAgent (OCRProvider Protocol only)."""

from __future__ import annotations

from pathlib import Path
from unittest.mock import patch

import pytest

from app.agents.base_agent import AgentContext, BaseAgent
from app.agents.ocr_agent import OCRAgent
from app.prompts.prompt_loader import PromptTemplate
from tests.fakes import FakeOCRProvider


def test_ocr_agent_is_base_agent_with_stable_name() -> None:
    agent = OCRAgent(FakeOCRProvider())
    assert isinstance(agent, BaseAgent)
    assert agent.name == "ocr"


@pytest.mark.asyncio
async def test_ocr_agent_success_calls_provider_only() -> None:
    fake = FakeOCRProvider(text="extracted", pages=3)
    agent = OCRAgent(fake)
    result = await agent.run(
        {"file_bytes": b"pdf-bytes"},
        AgentContext(document_id="d1", job_id="j1"),
    )
    assert result.success is True
    assert result.data["text"] == "extracted"
    assert result.data["pages"] == 3
    assert result.data["ocr_metadata"]["provider"] == "fake"
    assert result.data["prompt_name"] == "ocr"
    assert result.data["prompt_version"] == "v1"
    assert fake.calls == [b"pdf-bytes"]


@pytest.mark.asyncio
async def test_ocr_agent_provider_failure_uses_on_error() -> None:
    agent = OCRAgent(FakeOCRProvider(fail=True))
    result = await agent.run(
        {"file_bytes": b"x"},
        AgentContext(document_id="d1", job_id="j1"),
    )
    assert result.success is False
    assert result.error == "OCR failed"
    assert result.metadata["agent"] == "ocr"
    assert result.metadata["error_type"] == "RuntimeError"


@pytest.mark.asyncio
async def test_ocr_agent_loads_prompt_via_loader_not_inline() -> None:
    fake = FakeOCRProvider()
    agent = OCRAgent(fake)
    stub = PromptTemplate(
        name="ocr",
        version="v1",
        template="stubbed template body",
        metadata={},
    )
    with patch(
        "app.agents.ocr_agent.prompt_loader.load",
        return_value=stub,
    ) as load_mock:
        result = await agent.run({"file_bytes": b"a"}, AgentContext())
    load_mock.assert_called_once_with("ocr", version="v1")
    assert result.success is True
    assert result.data["prompt_version"] == "v1"


def test_ocr_agent_module_has_no_vendor_sdk_imports() -> None:
    source = Path(__file__).resolve().parents[1] / "app" / "agents" / "ocr_agent.py"
    text = source.read_text(encoding="utf-8")
    forbidden = (
        "mistralai",
        "google.cloud",
        "documentai",
        "openai",
        "anthropic",
    )
    for token in forbidden:
        assert token not in text, f"Vendor SDK import marker {token!r} in ocr_agent.py"


@pytest.mark.asyncio
async def test_master_to_ocr_happy_path_with_fake_provider() -> None:
    from app.agents.master_agent import run_master

    fake = FakeOCRProvider(text="orchestrated")
    result = await run_master(
        "ocr",
        {"file_bytes": b"doc"},
        AgentContext(user_id="u1"),
        ocr_provider=fake,
    )
    assert result.success is True
    assert result.data["text"] == "orchestrated"
    assert fake.calls == [b"doc"]
