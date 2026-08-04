"""Unit tests for Embedder + FakeEmbedder."""

import pytest

from app.rag.embedder import Embedder
from tests.fakes import FAKE_EMBEDDING_DIM, FakeEmbedder


@pytest.mark.asyncio
async def test_embedder_returns_stable_dimension() -> None:
    fake = FakeEmbedder()
    embedder = Embedder(fake)
    vectors = await embedder.embed(["alpha", "beta"])
    assert len(vectors) == 2
    assert all(len(v) == FAKE_EMBEDDING_DIM for v in vectors)
    # Deterministic
    again = await embedder.embed(["alpha", "beta"])
    assert again == vectors


@pytest.mark.asyncio
async def test_embedder_empty_input() -> None:
    embedder = Embedder(FakeEmbedder())
    assert await embedder.embed([]) == []


@pytest.mark.asyncio
async def test_different_texts_different_vectors() -> None:
    embedder = Embedder(FakeEmbedder())
    a, b = await embedder.embed(["one", "two"])
    assert a != b
