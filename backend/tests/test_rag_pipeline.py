"""RagPipeline ingest + query unit/integration tests with FakeEmbedder."""

from __future__ import annotations

from pathlib import Path
from unittest.mock import MagicMock

import pytest
from sqlalchemy.orm import Session

from app.models import DocumentStatus
from app.rag.chunker import Chunker
from app.rag.config import RagConfig
from app.rag.context_builder import ContextBuilder
from app.rag.embedder import Embedder
from app.rag.pipeline import RagPipeline
from app.rag.presets import CONTRACT_CONFIG, RECEIPT_CONFIG
from app.rag.retriever import HybridRetriever
from app.repositories.chunk_repo import DocumentChunkRepository
from app.repositories.document_repo import DocumentRepository
from app.repositories.user_repo import UserRepository
from tests.fakes import FakeEmbedder


def _make_pipeline(session: Session, fake: FakeEmbedder | None = None) -> RagPipeline:
    provider = fake or FakeEmbedder()
    return RagPipeline(
        chunker=Chunker(),
        embedder=Embedder(provider),
        retriever=HybridRetriever(session),
        context_builder=ContextBuilder(),
        chunk_store=DocumentChunkRepository(session),
    )


def _doc_with_text(session: Session, text: str, *, external_id: str = "pipe-u"):
    users = UserRepository(session)
    docs = DocumentRepository(session)
    try:
        owner = users.create(external_id=external_id, email=f"{external_id}@ex.com")
    except Exception:
        owner = users.get_by_external_id(external_id)
        assert owner is not None
    return docs.create(
        user_id=owner.id,
        title="Pipe",
        status=DocumentStatus.ready,
        extracted_text=text,
    )


def test_pipeline_wires_dependencies(db_session: Session) -> None:
    pipe = _make_pipeline(db_session)
    assert pipe._chunker is not None
    assert pipe._embedder is not None
    assert pipe._retriever is not None
    assert pipe._context_builder is not None
    assert pipe._chunk_store is not None


@pytest.mark.asyncio
async def test_ingest_persists_chunks_and_is_idempotent(db_session: Session) -> None:
    doc = _doc_with_text(
        db_session,
        "The distinctive phrase golden pineapple appears once. " * 5,
        external_id="ingest-1",
    )
    pipe = _make_pipeline(db_session)
    config = RagConfig(chunk_size=40, chunk_overlap=5)
    await pipe.ingest(doc, config)
    store = DocumentChunkRepository(db_session)
    first = store.list_by_document(doc.id)
    assert first
    assert all(c.embedding for c in first)

    await pipe.ingest(doc, config)
    second = store.list_by_document(doc.id)
    assert len(second) == len(first)


@pytest.mark.asyncio
async def test_ingest_uses_config_not_type_branch(db_session: Session) -> None:
    text = "token " * 300
    contract_doc = _doc_with_text(db_session, text, external_id="cfg-c")
    receipt_doc = _doc_with_text(db_session, text, external_id="cfg-r")
    fake = FakeEmbedder()
    pipe = _make_pipeline(db_session, fake)

    chunker = MagicMock(wraps=Chunker())
    pipe._chunker = chunker

    await pipe.ingest(contract_doc, CONTRACT_CONFIG)
    await pipe.ingest(receipt_doc, RECEIPT_CONFIG)

    assert chunker.chunk.call_count == 2
    assert chunker.chunk.call_args_list[0].args[1] is CONTRACT_CONFIG
    assert chunker.chunk.call_args_list[1].args[1] is RECEIPT_CONFIG

    c_count = len(DocumentChunkRepository(db_session).list_by_document(contract_doc.id))
    r_count = len(DocumentChunkRepository(db_session).list_by_document(receipt_doc.id))
    assert r_count > c_count


@pytest.mark.asyncio
async def test_query_returns_context_with_known_phrase(db_session: Session) -> None:
    phrase = "nebula_orion_unique"
    doc = _doc_with_text(
        db_session,
        f"Preface fluff. The secret code is {phrase}. More fluff follows.",
        external_id="query-1",
    )
    pipe = _make_pipeline(db_session)
    await pipe.ingest(doc, RagConfig(chunk_size=60, chunk_overlap=10, top_k=3))
    answer = await pipe.query(doc.id, "What is the secret code nebula?")
    assert phrase in answer.context or any(phrase in c.text for c in answer.chunks)
    assert answer.answer is None
    assert answer.document_id == doc.id


@pytest.mark.asyncio
async def test_query_unknown_document_returns_empty(db_session: Session) -> None:
    pipe = _make_pipeline(db_session)
    answer = await pipe.query("no-such-doc", "anything?")
    assert answer.context == ""
    assert answer.chunks == []


def test_pipeline_source_has_no_type_branches() -> None:
    source = (
        Path(__file__).resolve().parents[1] / "app" / "rag" / "pipeline.py"
    ).read_text(encoding="utf-8")
    assert "document_type" not in source
    assert '== "contract"' not in source
    assert '== "receipt"' not in source
