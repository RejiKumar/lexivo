"""document_chunks model, extracted_text, and chunk repository tests."""

from sqlalchemy import inspect
from sqlalchemy.orm import Session

from app.models import Document, DocumentChunk, DocumentStatus, User
from app.repositories.chunk_repo import DocumentChunkRepository
from app.repositories.document_repo import DocumentRepository
from app.repositories.user_repo import UserRepository


def test_document_chunks_table_in_metadata() -> None:
    table = DocumentChunk.__table__
    cols = {c.name for c in table.columns}
    assert "document_id" in cols
    assert "chunk_index" in cols
    assert "content" in cols
    assert "embedding" in cols
    assert "created_at" in cols


def test_extracted_text_round_trip(db_session: Session) -> None:
    users = UserRepository(db_session)
    docs = DocumentRepository(db_session)
    owner = users.create(external_id="rag-u1", email="rag@example.com")
    doc = docs.create(
        user_id=owner.id,
        title="Body",
        status=DocumentStatus.ready,
        extracted_text="OCR body text here",
    )
    fetched = docs.get(doc.id)
    assert fetched is not None
    assert fetched.extracted_text == "OCR body text here"


def test_chunk_repo_replace_and_list(db_session: Session) -> None:
    users = UserRepository(db_session)
    docs = DocumentRepository(db_session)
    chunks = DocumentChunkRepository(db_session)
    owner = users.create(external_id="rag-u2", email="rag2@example.com")
    doc = docs.create(
        user_id=owner.id,
        title="Doc",
        status=DocumentStatus.ready,
        extracted_text="hello world",
    )

    created = chunks.replace_for_document(
        doc.id,
        [
            {"chunk_index": 0, "content": "hello", "embedding": [0.1, 0.2]},
            {"chunk_index": 1, "content": "world", "embedding": [0.3, 0.4]},
        ],
    )
    assert len(created) == 2
    listed = chunks.list_by_document(doc.id)
    assert [c.content for c in listed] == ["hello", "world"]
    assert listed[0].embedding == [0.1, 0.2]

    # Idempotent replace
    chunks.replace_for_document(
        doc.id,
        [{"chunk_index": 0, "content": "only", "embedding": [1.0]}],
    )
    listed = chunks.list_by_document(doc.id)
    assert len(listed) == 1
    assert listed[0].content == "only"


def test_chunks_cascade_delete_with_document(db_session: Session) -> None:
    users = UserRepository(db_session)
    docs = DocumentRepository(db_session)
    chunks = DocumentChunkRepository(db_session)
    owner = users.create(external_id="rag-u3", email="rag3@example.com")
    doc = docs.create(user_id=owner.id, title="Gone", status=DocumentStatus.ready)
    chunks.replace_for_document(
        doc.id,
        [{"chunk_index": 0, "content": "x", "embedding": [0.0]}],
    )
    assert len(chunks.list_by_document(doc.id)) == 1
    docs.delete(doc.id)
    assert chunks.list_by_document(doc.id) == []


def test_document_model_has_extracted_text_column() -> None:
    mapper = inspect(Document)
    assert "extracted_text" in mapper.columns
