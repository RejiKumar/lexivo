"""RagPipeline — parameterized ingest + query (architecture.md §3.5).

``ingest(document, config)`` and ``query(document_id, question)`` stay free of
per-document-type branches; callers supply RagConfig.
"""

from __future__ import annotations

from app.models import Document
from app.rag.chunker import Chunker
from app.rag.config import RagConfig
from app.rag.context_builder import ContextBuilder
from app.rag.embedder import Embedder
from app.rag.retriever import HybridRetriever
from app.rag.types import RagAnswer
from app.repositories.chunk_repo import DocumentChunkRepository


class RagPipeline:
    def __init__(
        self,
        chunker: Chunker,
        embedder: Embedder,
        retriever: HybridRetriever,
        context_builder: ContextBuilder,
        chunk_store: DocumentChunkRepository,
        *,
        default_config: RagConfig | None = None,
    ) -> None:
        self._chunker = chunker
        self._embedder = embedder
        self._retriever = retriever
        self._context_builder = context_builder
        self._chunk_store = chunk_store
        self._default_config = default_config or RagConfig(
            chunk_size=500,
            chunk_overlap=50,
        )

    async def ingest(self, document: Document, config: RagConfig) -> None:
        text = (document.extracted_text or "").strip()
        if not text:
            raise ValueError(
                f"Document {document.id} has no extracted_text to ingest"
            )

        chunks = self._chunker.chunk(text, config)
        vectors = await self._embedder.embed([c.text for c in chunks]) if chunks else []

        self._chunk_store.replace_for_document(
            document.id,
            [
                {
                    "chunk_index": chunk.index,
                    "content": chunk.text,
                    "embedding": vector,
                }
                for chunk, vector in zip(chunks, vectors)
            ],
        )

    async def query(
        self,
        document_id: str,
        question: str,
        *,
        config: RagConfig | None = None,
    ) -> RagAnswer:
        cfg = config or self._default_config
        existing = self._chunk_store.list_by_document(document_id)
        if not existing:
            return RagAnswer(
                document_id=document_id,
                question=question,
                context="",
                chunks=[],
                answer=None,
            )

        query_vectors = await self._embedder.embed([question])
        query_embedding = query_vectors[0] if query_vectors else []
        ranked = self._retriever.retrieve(
            document_id,
            question,
            query_embedding=query_embedding,
            config=cfg,
        )
        context = self._context_builder.build(ranked, config=cfg)
        return RagAnswer(
            document_id=document_id,
            question=question,
            context=context,
            chunks=ranked,
            answer=None,
        )
