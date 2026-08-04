"""Smoke: app.rag package imports."""

from app import rag
from app.rag import RagConfig


def test_rag_package_imports() -> None:
    assert rag is not None
    assert RagConfig is not None
    assert hasattr(rag, "Chunker")
    assert hasattr(rag, "Embedder")
    assert hasattr(rag, "HybridRetriever")
    assert hasattr(rag, "ContextBuilder")
    assert hasattr(rag, "RagPipeline")
