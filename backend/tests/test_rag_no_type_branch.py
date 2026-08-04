"""Guards: app/rag pipeline modules must not branch on document type."""

from __future__ import annotations

import ast
import re
from pathlib import Path

import pytest
from sqlalchemy.orm import Session

from app.models import DocumentStatus
from app.rag.chunker import Chunker
from app.rag.embedder import Embedder
from app.rag.pipeline import RagPipeline
from app.rag.presets import CONTRACT_CONFIG, RECEIPT_CONFIG
from app.rag.context_builder import ContextBuilder
from app.rag.retriever import HybridRetriever
from app.repositories.chunk_repo import DocumentChunkRepository
from app.repositories.document_repo import DocumentRepository
from app.repositories.user_repo import UserRepository
from tests.fakes import FakeEmbedder

RAG_DIR = Path(__file__).resolve().parents[1] / "app" / "rag"

# Modules that implement the parameterized pipeline (presets.py may name types).
PIPELINE_MODULES = (
    "chunker.py",
    "embedder.py",
    "retriever.py",
    "context_builder.py",
    "pipeline.py",
    "config.py",
    "types.py",
)

_TYPE_COMPARE = re.compile(
    r"""document_type\s*==\s*['"](?:contract|receipt|paper)['"]"""
    r"""|['"](?:contract|receipt|paper)['"]\s*==\s*document_type"""
    r"""|if\s+document_type\b"""
)


def test_rag_modules_have_no_document_type_control_flow() -> None:
    for name in PIPELINE_MODULES:
        path = RAG_DIR / name
        source = path.read_text(encoding="utf-8")
        assert _TYPE_COMPARE.search(source) is None, f"type branch in {name}"
        # AST: no Compare involving Name document_type
        tree = ast.parse(source)
        for node in ast.walk(tree):
            if isinstance(node, ast.If):
                for child in ast.walk(node.test):
                    if isinstance(child, ast.Name) and child.id == "document_type":
                        pytest.fail(f"{name} branches on document_type")


@pytest.mark.asyncio
async def test_two_configs_same_pipeline_code_path(db_session: Session) -> None:
    users = UserRepository(db_session)
    docs = DocumentRepository(db_session)
    owner = users.create(external_id="guard-u", email="guard@example.com")
    text = "shared body " * 80
    d1 = docs.create(
        user_id=owner.id,
        title="c",
        status=DocumentStatus.ready,
        extracted_text=text,
    )
    d2 = docs.create(
        user_id=owner.id,
        title="r",
        status=DocumentStatus.ready,
        extracted_text=text,
    )
    pipe = RagPipeline(
        chunker=Chunker(),
        embedder=Embedder(FakeEmbedder()),
        retriever=HybridRetriever(db_session),
        context_builder=ContextBuilder(),
        chunk_store=DocumentChunkRepository(db_session),
    )
    # Same class methods; configs differ
    await pipe.ingest(d1, CONTRACT_CONFIG)
    await pipe.ingest(d2, RECEIPT_CONFIG)
    c1 = DocumentChunkRepository(db_session).list_by_document(d1.id)
    c2 = DocumentChunkRepository(db_session).list_by_document(d2.id)
    assert c1 and c2
    assert len(c1) != len(c2)
