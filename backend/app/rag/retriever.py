"""HybridRetriever — pgvector dense similarity + BM25/FTS keyword merge.

PostgreSQL path uses ``ts_rank_cd`` (BM25-style) and pgvector cosine distance.
SQLite/unit path uses in-process cosine + token overlap scoring so default
pytest stays green without Postgres (see module docstring and postgres marker).

No Pinecone / Chroma / Weaviate clients.
"""

from __future__ import annotations

import math
import re
from collections.abc import Sequence

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.models import DocumentChunk
from app.rag.config import RagConfig
from app.rag.types import RankedChunk


_TOKEN_RE = re.compile(r"[a-z0-9]+", re.IGNORECASE)


def _tokenize(text_value: str) -> list[str]:
    return _TOKEN_RE.findall(text_value.lower())


def _cosine(a: Sequence[float], b: Sequence[float]) -> float:
    if not a or not b or len(a) != len(b):
        return 0.0
    dot = sum(x * y for x, y in zip(a, b))
    na = math.sqrt(sum(x * x for x in a))
    nb = math.sqrt(sum(y * y for y in b))
    if na == 0.0 or nb == 0.0:
        return 0.0
    return dot / (na * nb)


def _rrf_merge(
    dense: list[tuple[int, float, str]],
    keyword: list[tuple[int, float, str]],
    *,
    dense_weight: float,
    keyword_weight: float,
    k: int = 60,
) -> list[RankedChunk]:
    """Reciprocal Rank Fusion with optional path weights; collapse duplicate indexes."""
    scores: dict[int, float] = {}
    texts: dict[int, str] = {}

    for rank, (idx, _score, chunk_text) in enumerate(dense):
        texts[idx] = chunk_text
        scores[idx] = scores.get(idx, 0.0) + dense_weight * (1.0 / (k + rank + 1))

    for rank, (idx, _score, chunk_text) in enumerate(keyword):
        texts[idx] = chunk_text
        scores[idx] = scores.get(idx, 0.0) + keyword_weight * (1.0 / (k + rank + 1))

    ordered = sorted(scores.items(), key=lambda item: item[1], reverse=True)
    return [
        RankedChunk(text=texts[idx], index=idx, score=score, metadata={"source": "hybrid"})
        for idx, score in ordered
    ]


class HybridRetriever:
    """Merge dense (pgvector / in-process) + keyword (FTS / token) into one ranked list."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def retrieve(
        self,
        document_id: str,
        question: str,
        *,
        query_embedding: list[float],
        config: RagConfig,
    ) -> list[RankedChunk]:
        chunks = (
            self._session.query(DocumentChunk)
            .filter(DocumentChunk.document_id == document_id)
            .order_by(DocumentChunk.chunk_index)
            .all()
        )
        if not chunks:
            return []

        dialect = self._session.bind.dialect.name if self._session.bind else "sqlite"
        if dialect == "postgresql":
            dense = self._dense_postgres(document_id, query_embedding, config.top_k)
            keyword = self._keyword_postgres(document_id, question, config.top_k)
        else:
            dense = self._dense_inprocess(chunks, query_embedding, config.top_k)
            keyword = self._keyword_inprocess(chunks, question, config.top_k)

        merged = _rrf_merge(
            dense,
            keyword,
            dense_weight=config.dense_weight,
            keyword_weight=config.keyword_weight,
        )
        return merged[: config.top_k]

    def _dense_inprocess(
        self,
        chunks: list[DocumentChunk],
        query_embedding: list[float],
        top_k: int,
    ) -> list[tuple[int, float, str]]:
        scored: list[tuple[int, float, str]] = []
        for chunk in chunks:
            emb = chunk.embedding or []
            if isinstance(emb, str):
                continue
            score = _cosine(query_embedding, list(emb))
            scored.append((chunk.chunk_index, score, chunk.content))
        scored.sort(key=lambda item: item[1], reverse=True)
        return scored[:top_k]

    def _keyword_inprocess(
        self,
        chunks: list[DocumentChunk],
        question: str,
        top_k: int,
    ) -> list[tuple[int, float, str]]:
        q_tokens = set(_tokenize(question))
        if not q_tokens:
            return []
        scored: list[tuple[int, float, str]] = []
        for chunk in chunks:
            c_tokens = _tokenize(chunk.content)
            if not c_tokens:
                continue
            overlap = sum(1 for t in c_tokens if t in q_tokens)
            score = overlap / math.sqrt(len(c_tokens))
            if score > 0:
                scored.append((chunk.chunk_index, score, chunk.content))
        scored.sort(key=lambda item: item[1], reverse=True)
        return scored[:top_k]

    def _dense_postgres(
        self,
        document_id: str,
        query_embedding: list[float],
        top_k: int,
    ) -> list[tuple[int, float, str]]:
        # cosine distance operator <=> ; similarity = 1 - distance
        vector_literal = "[" + ",".join(str(float(x)) for x in query_embedding) + "]"
        sql = text(
            """
            SELECT chunk_index, content,
                   1 - (embedding <=> CAST(:qvec AS vector)) AS score
            FROM document_chunks
            WHERE document_id = :doc_id AND embedding IS NOT NULL
            ORDER BY embedding <=> CAST(:qvec AS vector)
            LIMIT :lim
            """
        )
        rows = self._session.execute(
            sql,
            {"doc_id": document_id, "qvec": vector_literal, "lim": top_k},
        ).all()
        return [(int(r.chunk_index), float(r.score), str(r.content)) for r in rows]

    def _keyword_postgres(
        self,
        document_id: str,
        question: str,
        top_k: int,
    ) -> list[tuple[int, float, str]]:
        # BM25-style ranking via ts_rank_cd on plainto_tsquery
        sql = text(
            """
            SELECT chunk_index, content,
                   ts_rank_cd(
                     to_tsvector('english', content),
                     plainto_tsquery('english', :q)
                   ) AS score
            FROM document_chunks
            WHERE document_id = :doc_id
              AND to_tsvector('english', content)
                  @@ plainto_tsquery('english', :q)
            ORDER BY score DESC
            LIMIT :lim
            """
        )
        rows = self._session.execute(
            sql,
            {"doc_id": document_id, "q": question, "lim": top_k},
        ).all()
        return [(int(r.chunk_index), float(r.score), str(r.content)) for r in rows]
