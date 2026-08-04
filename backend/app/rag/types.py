"""Shared RAG result types (Chunk, ranked hits, RagAnswer)."""

from __future__ import annotations

from pydantic import BaseModel, Field


class Chunk(BaseModel):
    text: str
    index: int
    metadata: dict = Field(default_factory=dict)


class RankedChunk(BaseModel):
    text: str
    index: int
    score: float
    metadata: dict = Field(default_factory=dict)


class RagAnswer(BaseModel):
    """Retrieval context shaped for future ChatService; LLM answer is out of scope."""

    document_id: str
    question: str
    context: str
    chunks: list[RankedChunk] = Field(default_factory=list)
    answer: str | None = None
