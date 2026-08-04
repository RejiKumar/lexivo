"""Unit tests for ExportAgent (PDF section toggles + StorageProvider)."""

from __future__ import annotations

from pathlib import Path

import pytest

from app.agents.base_agent import AgentContext, BaseAgent
from app.agents.export_agent import ExportAgent
from tests.fakes import FakeStorageProvider


def test_export_agent_is_base_agent_with_stable_name() -> None:
    agent = ExportAgent(FakeStorageProvider())
    assert isinstance(agent, BaseAgent)
    assert agent.name == "export"


@pytest.mark.asyncio
async def test_export_agent_all_sections() -> None:
    storage = FakeStorageProvider()
    agent = ExportAgent(storage)
    result = await agent.run(
        {
            "document_id": "d1",
            "include_summary": True,
            "include_translation": True,
            "include_chat": True,
            "summary": "Short summary body",
            "translation": "Texto traducido",
            "chat": "User: hi\nAssistant: hello",
        },
        AgentContext(document_id="d1"),
    )
    assert result.success is True
    assert result.data["signed_url"].startswith("https://signed.test/")
    key = result.data["storage_key"]
    pdf = storage.objects[key]
    assert b"=== SECTION: Summary ===" in pdf
    assert b"=== SECTION: Translation ===" in pdf
    assert b"=== SECTION: Chat ===" in pdf
    assert b"Short summary body" in pdf


@pytest.mark.asyncio
async def test_export_agent_summary_only_omits_other_sections() -> None:
    storage = FakeStorageProvider()
    agent = ExportAgent(storage)
    result = await agent.run(
        {
            "include_summary": True,
            "include_translation": False,
            "include_chat": False,
            "summary": "Only summary",
            "translation": "should-not-appear",
            "chat": "also-not",
        },
        AgentContext(),
    )
    assert result.success is True
    pdf = storage.objects[result.data["storage_key"]]
    assert b"=== SECTION: Summary ===" in pdf
    assert b"=== SECTION: Translation ===" not in pdf
    assert b"=== SECTION: Chat ===" not in pdf
    assert b"should-not-appear" not in pdf


@pytest.mark.asyncio
async def test_export_agent_storage_failure_shapes_result() -> None:
    class BoomStorage:
        async def upload(self, key: str, file: bytes) -> str:
            raise RuntimeError("upload failed")

        async def signed_url(self, key: str) -> str:
            return "x"

    agent = ExportAgent(BoomStorage())  # type: ignore[arg-type]
    result = await agent.run(
        {"include_summary": True, "summary": "S"},
        AgentContext(),
    )
    assert result.success is False
    assert result.error == "upload failed"


def test_export_agent_no_r2_or_agent_imports() -> None:
    source = (
        Path(__file__).resolve().parents[1] / "app" / "agents" / "export_agent.py"
    ).read_text(encoding="utf-8")
    for token in ("boto3", "botocore", "summary_agent"):
        assert token not in source
