"""Smoke tests for STEP 3.6 specialized agent module scaffold."""

from __future__ import annotations

import importlib

import pytest

from app.agents.base_agent import BaseAgent

EXPECTED_AGENTS = (
    ("summary_agent", "SummaryAgent", "summary"),
    ("translation_agent", "TranslationAgent", "translation"),
    ("search_agent", "SearchAgent", "search"),
    ("citation_agent", "CitationAgent", "citation"),
    ("export_agent", "ExportAgent", "export"),
    ("security_agent", "SecurityAgent", "security"),
    ("notification_agent", "NotificationAgent", "notification"),
    ("analytics_agent", "AnalyticsAgent", "analytics"),
)


@pytest.mark.parametrize(
    ("module_name", "class_name", "registry_name"),
    EXPECTED_AGENTS,
)
def test_specialized_agent_module_imports_with_stable_name(
    module_name: str,
    class_name: str,
    registry_name: str,
) -> None:
    mod = importlib.import_module(f"app.agents.{module_name}")
    cls = getattr(mod, class_name)
    assert issubclass(cls, BaseAgent)
    assert getattr(cls, "name") == registry_name


@pytest.mark.parametrize(
    "prompt_name",
    ("summary", "translation", "citation"),
)
def test_llm_prompt_namespaces_have_v1(prompt_name: str) -> None:
    from app.prompts import prompt_loader

    prompt = prompt_loader.load(prompt_name, version="v1")
    assert prompt.name == prompt_name
    assert prompt.version == "v1"
    assert prompt.template.strip()
