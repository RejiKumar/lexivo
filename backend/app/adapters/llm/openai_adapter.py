"""OpenAI LLM stub adapter — deterministic local/test completions only."""

from __future__ import annotations


class OpenAILLMAdapter:
    """
    Stub LLMProvider behind the same Protocol as a production OpenAI adapter.

    Returns a deterministic completion string for tests; does not call OpenAI.
    """

    def __init__(self, api_key: str = "") -> None:
        self._api_key = api_key

    async def complete(self, prompt: str, **kwargs: object) -> str:
        model = kwargs.get("model", "stub")
        return f"[openai-stub model={model}] {prompt}"
