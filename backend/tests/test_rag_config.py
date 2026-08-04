"""Unit tests for RagConfig and shared RAG types."""

import pytest
from pydantic import ValidationError

from app.rag.config import ChunkStrategy, RagConfig
from app.rag.presets import CONTRACT_CONFIG, RECEIPT_CONFIG
from app.rag.types import Chunk, RagAnswer, RankedChunk


def test_rag_config_requires_size_overlap_strategy() -> None:
    cfg = RagConfig(chunk_size=400, chunk_overlap=40, strategy=ChunkStrategy.fixed)
    assert cfg.chunk_size == 400
    assert cfg.chunk_overlap == 40
    assert cfg.strategy == ChunkStrategy.fixed
    assert cfg.top_k == 5
    assert cfg.dense_weight == 0.5
    assert cfg.keyword_weight == 0.5


def test_rag_config_rejects_invalid_sizes() -> None:
    with pytest.raises(ValidationError):
        RagConfig(chunk_size=0, chunk_overlap=0)
    with pytest.raises(ValidationError):
        RagConfig(chunk_size=100, chunk_overlap=100)
    with pytest.raises(ValidationError):
        RagConfig(chunk_size=100, chunk_overlap=150)
    with pytest.raises(ValidationError):
        RagConfig(chunk_size=-1, chunk_overlap=0)


def test_contract_vs_receipt_presets_differ_only_in_values() -> None:
    assert CONTRACT_CONFIG.chunk_size != RECEIPT_CONFIG.chunk_size
    assert CONTRACT_CONFIG.chunk_overlap != RECEIPT_CONFIG.chunk_overlap
    assert type(CONTRACT_CONFIG) is type(RECEIPT_CONFIG) is RagConfig


def test_chunk_and_rag_answer_types() -> None:
    chunk = Chunk(text="hello", index=0, metadata={"k": "v"})
    assert chunk.text == "hello"
    ranked = RankedChunk(text="hello", index=0, score=0.9)
    answer = RagAnswer(
        document_id="d1",
        question="q?",
        context="[0] hello",
        chunks=[ranked],
    )
    assert answer.answer is None
    assert answer.context.startswith("[0]")
