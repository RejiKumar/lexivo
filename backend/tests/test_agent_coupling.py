"""Guard tests: specialized agents never import/call each other."""

from __future__ import annotations

import ast
from pathlib import Path

import pytest

AGENTS_DIR = Path(__file__).resolve().parents[1] / "app" / "agents"

SPECIALIZED_AGENT_MODULES = frozenset(
    {
        "ocr_agent",
        "summary_agent",
        "translation_agent",
        "search_agent",
        "citation_agent",
        "export_agent",
        "security_agent",
        "notification_agent",
        "analytics_agent",
    }
)
ALLOWED_SHARED = frozenset({"base_agent"})

SPECIALIST_CLASS_NAMES = (
    "OCRAgent",
    "SummaryAgent",
    "TranslationAgent",
    "SearchAgent",
    "CitationAgent",
    "ExportAgent",
    "SecurityAgent",
    "NotificationAgent",
    "AnalyticsAgent",
)


def _agent_module_imports(path: Path) -> set[str]:
    tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    imported: set[str] = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module:
            parts = node.module.split(".")
            if "agents" in parts:
                idx = parts.index("agents")
                if idx + 1 < len(parts):
                    imported.add(parts[idx + 1])
            for alias in node.names:
                if alias.name.endswith("_agent"):
                    imported.add(alias.name)
        elif isinstance(node, ast.Import):
            for alias in node.names:
                if "agents" in alias.name:
                    parts = alias.name.split(".")
                    if "agents" in parts:
                        idx = parts.index("agents")
                        if idx + 1 < len(parts):
                            imported.add(parts[idx + 1])
    return imported


def test_specialized_agents_do_not_import_other_specialized_agents() -> None:
    for module_stem in SPECIALIZED_AGENT_MODULES:
        path = AGENTS_DIR / f"{module_stem}.py"
        assert path.is_file(), f"missing {path}"
        imported = _agent_module_imports(path)
        specialized_hits = (imported & SPECIALIZED_AGENT_MODULES) - {module_stem}
        assert not specialized_hits, (
            f"{module_stem} imports specialized agents {specialized_hits}; "
            "only Master may wire agents via the node registry"
        )
        assert "master_agent" not in imported, (
            f"{module_stem} must not import master_agent"
        )
        for name in imported:
            assert name in ALLOWED_SHARED or name == module_stem, (
                f"{module_stem} unexpectedly imports agents.{name}"
            )


def test_only_master_may_import_specialized_agents() -> None:
    master_imports = _agent_module_imports(AGENTS_DIR / "master_agent.py")
    for module_stem in SPECIALIZED_AGENT_MODULES:
        assert module_stem in master_imports, (
            f"master_agent.py should import {module_stem} for registry wiring"
        )
    assert "base_agent" in master_imports

    for path in AGENTS_DIR.glob("*_agent.py"):
        if path.stem in {"base_agent", "master_agent"}:
            continue
        imported = _agent_module_imports(path)
        other_specialists = {
            p.stem
            for p in AGENTS_DIR.glob("*_agent.py")
            if p.stem not in {"base_agent", "master_agent", path.stem}
        }
        assert not (imported & other_specialists)


@pytest.mark.parametrize("module_stem", sorted(SPECIALIZED_AGENT_MODULES))
def test_specialist_source_has_no_other_specialist_class_or_master_refs(
    module_stem: str,
) -> None:
    source = (AGENTS_DIR / f"{module_stem}.py").read_text(encoding="utf-8")
    class_map = {
        "ocr_agent": "OCRAgent",
        "summary_agent": "SummaryAgent",
        "translation_agent": "TranslationAgent",
        "search_agent": "SearchAgent",
        "citation_agent": "CitationAgent",
        "export_agent": "ExportAgent",
        "security_agent": "SecurityAgent",
        "notification_agent": "NotificationAgent",
        "analytics_agent": "AnalyticsAgent",
    }
    own = class_map[module_stem]
    for name in SPECIALIST_CLASS_NAMES:
        if name == own:
            continue
        assert name not in source, f"{module_stem} references {name}"
    for forbidden in ("MasterAgent", "run_master", "master_agent"):
        assert forbidden not in source, f"{module_stem} references {forbidden}"


@pytest.mark.asyncio
async def test_master_invokes_ocr_without_ocr_importing_master() -> None:
    ocr_source = (AGENTS_DIR / "ocr_agent.py").read_text(encoding="utf-8")
    assert "master_agent" not in ocr_source
    assert "MasterAgent" not in ocr_source
    assert "run_master" not in ocr_source

    from app.agents.base_agent import AgentContext
    from app.agents.master_agent import run_master
    from tests.fakes import FakeOCRProvider

    result = await run_master(
        "ocr",
        {"file_bytes": b"x"},
        AgentContext(),
        ocr_provider=FakeOCRProvider(text="ok"),
    )
    assert result.success is True


def test_document_processing_task_enters_via_master_only() -> None:
    """Thin Celery hook may call run_master; must not import specialist agents."""
    tasks_dir = Path(__file__).resolve().parents[1] / "app" / "tasks"
    source = (tasks_dir / "document_processing.py").read_text(encoding="utf-8")
    assert "run_master" in source
    assert "from app.agents.master_agent import run_master" in source
    for module_stem in SPECIALIZED_AGENT_MODULES:
        assert f"app.agents.{module_stem}" not in source
    for name in SPECIALIST_CLASS_NAMES:
        assert name not in source
