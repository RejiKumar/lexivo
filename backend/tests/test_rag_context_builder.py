"""ContextBuilder unit tests."""

from app.rag.config import RagConfig
from app.rag.context_builder import ContextBuilder
from app.rag.types import RankedChunk


def test_context_builder_concatenates_ranked_chunks() -> None:
    chunks = [
        RankedChunk(text="first", index=0, score=1.0),
        RankedChunk(text="second", index=1, score=0.5),
    ]
    context = ContextBuilder().build(chunks)
    assert "[0] first" in context
    assert "[1] second" in context


def test_context_builder_respects_max_chars() -> None:
    chunks = [
        RankedChunk(text="AAAA", index=0, score=1.0),
        RankedChunk(text="BBBB", index=1, score=0.5),
    ]
    config = RagConfig(chunk_size=50, chunk_overlap=5, max_context_chars=10)
    context = ContextBuilder().build(chunks, config=config)
    assert len(context) <= 10


def test_context_builder_empty() -> None:
    assert ContextBuilder().build([]) == ""
