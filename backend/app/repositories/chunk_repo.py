"""DocumentChunk repository — SQL CRUD + similarity helpers for RAG."""

from __future__ import annotations

from typing import Any

from sqlalchemy import delete
from sqlalchemy.orm import Session

from app.models import DocumentChunk
from app.repositories.base import BaseRepository


class DocumentChunkRepository(BaseRepository[DocumentChunk]):
    model = DocumentChunk

    def __init__(self, session: Session) -> None:
        super().__init__(session)

    def list_by_document(self, document_id: str) -> list[DocumentChunk]:
        return (
            self.session.query(DocumentChunk)
            .filter(DocumentChunk.document_id == document_id)
            .order_by(DocumentChunk.chunk_index)
            .all()
        )

    def delete_by_document(self, document_id: str) -> int:
        result = self.session.execute(
            delete(DocumentChunk).where(DocumentChunk.document_id == document_id)
        )
        self.session.commit()
        return int(result.rowcount or 0)

    def replace_for_document(
        self,
        document_id: str,
        chunks: list[dict[str, Any]],
    ) -> list[DocumentChunk]:
        """Idempotent ingest: clear prior chunks for the document, then insert."""
        self.session.execute(
            delete(DocumentChunk).where(DocumentChunk.document_id == document_id)
        )
        created: list[DocumentChunk] = []
        for row in chunks:
            entity = DocumentChunk(
                document_id=document_id,
                chunk_index=int(row["chunk_index"]),
                content=str(row["content"]),
                embedding=row.get("embedding"),
            )
            self.session.add(entity)
            created.append(entity)
        self.session.commit()
        for entity in created:
            self.session.refresh(entity)
        return created
