"""HybridRetriever unit tests (SQLite in-process path) + optional Postgres marker."""

from __future__ import annotations

import os

import pytest
from sqlalchemy.orm import Session

from app.models import DocumentStatus
from app.rag.config import RagConfig
from app.rag.retriever import HybridRetriever
from app.repositories.chunk_repo import DocumentChunkRepository
from app.repositories.document_repo import DocumentRepository
from app.repositories.user_repo import UserRepository
from tests.fakes import FakeEmbedder


async def _seed_chunks(db_session: Session, texts: list[str]) -> str:
    users = UserRepository(db_session)
    docs = DocumentRepository(db_session)
    chunks = DocumentChunkRepository(db_session)
    owner = users.create(
        external_id=f"ret-u-{len(texts)}-{hash(tuple(texts)) & 0xffff}",
        email="ret@example.com",
    )
    doc = docs.create(
        user_id=owner.id,
        title="Ret",
        status=DocumentStatus.ready,
        extracted_text="\n".join(texts),
    )
    embedder = FakeEmbedder()
    vectors = await embedder.embed(texts)
    chunks.replace_for_document(
        doc.id,
        [
            {"chunk_index": i, "content": t, "embedding": v}
            for i, (t, v) in enumerate(zip(texts, vectors))
        ],
    )
    return doc.id


@pytest.mark.asyncio
async def test_dense_path_ranks_by_similarity(db_session: Session) -> None:
    users = UserRepository(db_session)
    docs = DocumentRepository(db_session)
    chunks = DocumentChunkRepository(db_session)
    owner = users.create(external_id="dense-u", email="dense@example.com")
    doc = docs.create(
        user_id=owner.id,
        title="Dense",
        status=DocumentStatus.ready,
        extracted_text="a\nb\nc",
    )
    target = [1.0, 0.0, 0.0] + [0.0] * 29
    other = [0.0, 1.0, 0.0] + [0.0] * 29
    far = [0.0, 0.0, 1.0] + [0.0] * 29
    chunks.replace_for_document(
        doc.id,
        [
            {"chunk_index": 0, "content": "alpha beta gamma", "embedding": target},
            {"chunk_index": 1, "content": "completely unrelated zebra", "embedding": far},
            {"chunk_index": 2, "content": "noise filler", "embedding": other},
        ],
    )
    query_vec = list(target)  # exact match to chunk 0
    retriever = HybridRetriever(db_session)
    config = RagConfig(
        chunk_size=50,
        chunk_overlap=5,
        top_k=2,
        dense_weight=1.0,
        keyword_weight=0.0,
    )
    ranked = retriever.retrieve(
        doc.id, "zzzz", query_embedding=query_vec, config=config
    )
    assert ranked
    assert "alpha" in ranked[0].text


@pytest.mark.asyncio
async def test_keyword_path_ranks_by_tokens(db_session: Session) -> None:
    texts = [
        "payment invoice total amount",
        "weather forecast sunny",
        "invoice number 42",
    ]
    doc_id = await _seed_chunks(db_session, texts)
    fake = FakeEmbedder()
    query_vec = (await fake.embed(["invoice"]))[0]
    retriever = HybridRetriever(db_session)
    config = RagConfig(
        chunk_size=50,
        chunk_overlap=5,
        top_k=2,
        dense_weight=0.0,
        keyword_weight=1.0,
    )
    ranked = retriever.retrieve(
        doc_id, "invoice", query_embedding=query_vec, config=config
    )
    assert ranked
    assert all("invoice" in r.text.lower() for r in ranked)


@pytest.mark.asyncio
async def test_hybrid_merge_collapses_duplicates_and_empty(db_session: Session) -> None:
    texts = ["unique keyword xylophone appears here"]
    doc_id = await _seed_chunks(db_session, texts)
    fake = FakeEmbedder()
    query_vec = (await fake.embed(["xylophone"]))[0]
    retriever = HybridRetriever(db_session)
    config = RagConfig(chunk_size=80, chunk_overlap=5, top_k=5)
    ranked = retriever.retrieve(
        doc_id, "xylophone", query_embedding=query_vec, config=config
    )
    indexes = [r.index for r in ranked]
    assert len(indexes) == len(set(indexes))

    empty = retriever.retrieve(
        "missing-doc",
        "anything",
        query_embedding=query_vec,
        config=config,
    )
    assert empty == []


@pytest.mark.postgres
@pytest.mark.asyncio
async def test_hybrid_postgres_pgvector_integration() -> None:
    """Requires DATABASE_URL pointing at Postgres+pgvector; skipped otherwise."""
    url = os.environ.get("LEXIVO_POSTGRES_URL") or os.environ.get("DATABASE_URL", "")
    if not url.startswith("postgresql"):
        pytest.skip("Postgres+pgvector not configured (set LEXIVO_POSTGRES_URL)")

    from sqlalchemy import create_engine, text
    from sqlalchemy.orm import sessionmaker

    from app.core.db import Base
    import app.models  # noqa: F401

    engine = create_engine(url)
    with engine.begin() as conn:
        conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    session = Session()
    try:
        texts = [
            "distinctive keyword quokka in this chunk",
            "unrelated filler about weather",
        ]
        doc_id = await _seed_chunks(session, texts)
        fake = FakeEmbedder()
        query_vec = (await fake.embed(["quokka"]))[0]
        ranked = HybridRetriever(session).retrieve(
            doc_id,
            "quokka",
            query_embedding=query_vec,
            config=RagConfig(chunk_size=100, chunk_overlap=10, top_k=3),
        )
        assert ranked
        assert "quokka" in ranked[0].text.lower()
    finally:
        session.close()
        engine.dispose()
