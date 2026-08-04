"""Config-driven text chunking — dispatches on RagConfig.strategy only."""

from __future__ import annotations

from collections.abc import Callable

from app.rag.config import ChunkStrategy, RagConfig
from app.rag.types import Chunk


class Chunker:
    """Split plain text into ordered Chunks using RagConfig size/overlap/strategy."""

    def chunk(self, text: str, config: RagConfig) -> list[Chunk]:
        if not text or not text.strip():
            return []
        handler = _STRATEGY_HANDLERS[config.strategy]
        return handler(text, config)


def _chunk_fixed(text: str, config: RagConfig) -> list[Chunk]:
    size = config.chunk_size
    overlap = config.chunk_overlap
    step = max(size - overlap, 1)
    chunks: list[Chunk] = []
    start = 0
    index = 0
    length = len(text)
    while start < length:
        end = min(start + size, length)
        piece = text[start:end]
        if piece.strip():
            chunks.append(Chunk(text=piece, index=index, metadata={"strategy": "fixed"}))
            index += 1
        if end >= length:
            break
        start += step
    return chunks


def _chunk_paragraph(text: str, config: RagConfig) -> list[Chunk]:
    """Split on blank lines, then apply fixed-size windows within oversized paragraphs."""
    paragraphs = [p.strip() for p in text.split("\n\n") if p.strip()]
    if not paragraphs:
        return _chunk_fixed(text, config)

    chunks: list[Chunk] = []
    index = 0
    for para in paragraphs:
        if len(para) <= config.chunk_size:
            chunks.append(
                Chunk(text=para, index=index, metadata={"strategy": "paragraph"})
            )
            index += 1
        else:
            for sub in _chunk_fixed(para, config):
                chunks.append(
                    Chunk(
                        text=sub.text,
                        index=index,
                        metadata={"strategy": "paragraph"},
                    )
                )
                index += 1
    return chunks


_STRATEGY_HANDLERS: dict[ChunkStrategy, Callable[[str, RagConfig], list[Chunk]]] = {
    ChunkStrategy.fixed: _chunk_fixed,
    ChunkStrategy.paragraph: _chunk_paragraph,
}
