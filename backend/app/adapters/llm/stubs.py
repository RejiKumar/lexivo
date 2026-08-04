"""Temporary LLMProvider stubs for DI until §5 SDK adapters land."""


class GeminiLLMAdapter:
    """Default LLMProvider binding (SDK integration in §5)."""

    async def complete(self, prompt: str, **kwargs: object) -> str:
        raise NotImplementedError("Gemini LLM SDK adapter not implemented yet (§5)")


class OpenAILLMAdapter:
    """Alternate LLMProvider stub (SDK integration in §5)."""

    async def complete(self, prompt: str, **kwargs: object) -> str:
        raise NotImplementedError("OpenAI LLM stub adapter not implemented yet (§5)")
