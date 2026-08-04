"""Smoke tests for agents/prompts package scaffold and LangGraph dependency."""

from __future__ import annotations


def test_agents_package_importable() -> None:
    import app.agents  # noqa: F401


def test_prompts_package_importable() -> None:
    import app.prompts  # noqa: F401
    import app.prompts.prompt_loader  # noqa: F401


def test_langgraph_importable() -> None:
    from langgraph.graph import END, START, StateGraph

    assert StateGraph is not None
    assert START is not None
    assert END is not None
