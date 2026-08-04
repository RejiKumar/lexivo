"""Unit tests for shared prompt_loader."""

from __future__ import annotations

import pytest

from app.prompts import prompt_loader
from app.prompts.prompt_loader import PromptNotFoundError, PromptPathError, PromptTemplate


def test_load_ocr_v1_template() -> None:
    prompt = prompt_loader.load("ocr", version="v1")
    assert isinstance(prompt, PromptTemplate)
    assert prompt.name == "ocr"
    assert prompt.version == "v1"
    assert "Lexivo OCR" in prompt.template
    assert "invent content" in prompt.template


def test_load_missing_template_raises() -> None:
    with pytest.raises(PromptNotFoundError, match="not found"):
        prompt_loader.load("ocr", version="v999")


def test_path_traversal_rejected() -> None:
    with pytest.raises(PromptPathError):
        prompt_loader.load("../secrets", version="v1")
    with pytest.raises(PromptPathError):
        prompt_loader.load("ocr", version="../v1")


def test_agents_must_not_inline_ocr_prompt_body() -> None:
    """Guard: OCR prompt body lives in prompts/, not hardcoded in agent modules."""
    from pathlib import Path

    agents_dir = Path(__file__).resolve().parents[1] / "app" / "agents"
    body_snippet = "Normalize whitespace, preserve document structure"
    for path in agents_dir.glob("*.py"):
        text = path.read_text(encoding="utf-8")
        assert body_snippet not in text, f"Inlined OCR prompt body found in {path.name}"
