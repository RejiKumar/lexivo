"""Unit tests for config-driven Chunker (no document-type branches)."""

from pathlib import Path

from app.rag.chunker import Chunker
from app.rag.config import ChunkStrategy, RagConfig
from app.rag.presets import CONTRACT_CONFIG, RECEIPT_CONFIG


def test_chunker_respects_size_and_overlap() -> None:
    text = "abcdefghijklmnopqrstuvwxyz" * 4  # 104 chars
    config = RagConfig(chunk_size=20, chunk_overlap=5, strategy=ChunkStrategy.fixed)
    chunks = Chunker().chunk(text, config)
    assert chunks
    assert chunks[0].index == 0
    assert all(len(c.text) <= 20 for c in chunks)
    # Overlap: successive windows share the configured overlap region
    if len(chunks) >= 2:
        assert chunks[0].text[-5:] == chunks[1].text[:5]


def test_chunker_empty_text() -> None:
    config = RagConfig(chunk_size=50, chunk_overlap=5)
    assert Chunker().chunk("", config) == []
    assert Chunker().chunk("   ", config) == []


def test_different_configs_yield_different_boundaries() -> None:
    text = "word " * 200
    contract_chunks = Chunker().chunk(text, CONTRACT_CONFIG)
    receipt_chunks = Chunker().chunk(text, RECEIPT_CONFIG)
    assert len(receipt_chunks) > len(contract_chunks)


def test_strategy_dispatch_changes_behavior() -> None:
    text = "Para one has some words.\n\nPara two is separate.\n\nPara three ends."
    fixed = Chunker().chunk(
        text, RagConfig(chunk_size=80, chunk_overlap=0, strategy=ChunkStrategy.fixed)
    )
    para = Chunker().chunk(
        text,
        RagConfig(chunk_size=80, chunk_overlap=0, strategy=ChunkStrategy.paragraph),
    )
    assert len(para) == 3
    assert len(fixed) >= 1
    assert para[0].metadata["strategy"] == "paragraph"


def test_chunker_source_has_no_document_type_branches() -> None:
    source = (
        Path(__file__).resolve().parents[1] / "app" / "rag" / "chunker.py"
    ).read_text(encoding="utf-8")
    for banned in (
        'document_type == "contract"',
        "document_type == 'contract'",
        'if document_type',
        '== "receipt"',
        "== 'paper'",
    ):
        assert banned not in source
