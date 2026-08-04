"""Embedder wraps an injectable EmbeddingProvider Protocol.

Vendor SDKs (OpenAI, Gemini, …) must live in adapters/ and be injected —
this module never imports embedding vendor clients directly.
"""

from __future__ import annotations

from typing import Protocol, runtime_checkable


@runtime_checkable
class EmbeddingProvider(Protocol):
    """Port for dense embedding backends (real adapters or FakeEmbedder)."""

    async def embed(self, texts: list[str]) -> list[list[float]]: ...


class Embedder:
    """Thin DI wrapper — delegates to the injected EmbeddingProvider."""

    def __init__(self, provider: EmbeddingProvider) -> None:
        self._provider = provider

    async def embed(self, texts: list[str]) -> list[list[float]]:
        if not texts:
            return []
        vectors = await self._provider.embed(texts)
        if len(vectors) != len(texts):
            raise ValueError(
                f"EmbeddingProvider returned {len(vectors)} vectors for {len(texts)} texts"
            )
        return vectors
