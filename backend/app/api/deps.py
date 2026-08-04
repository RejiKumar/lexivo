"""FastAPI dependencies that construct domain services (repos via session)."""

from typing import Annotated

from fastapi import Depends
from sqlalchemy.orm import Session

from app.adapters.protocols import StorageProvider
from app.core.db import get_db
from app.core.dependencies import get_storage_provider
from app.rag.chunker import Chunker
from app.rag.context_builder import ContextBuilder
from app.rag.embedder import Embedder
from app.rag.pipeline import RagPipeline
from app.rag.retriever import HybridRetriever
from app.repositories.chat_repo import ChatMessageRepository, ChatRepository
from app.repositories.chunk_repo import DocumentChunkRepository
from app.repositories.document_repo import DocumentRepository
from app.repositories.export_repo import ExportRepository
from app.repositories.user_repo import UserRepository
from app.services.chat_service import ChatService
from app.services.document_service import DocumentService
from app.services.export_service import ExportService
from app.services.summary_service import SummaryService
from app.services.translation_service import TranslationService
from app.services.user_service import UserService
from app.tasks.document_processing import enqueue_document_processing
from app.tasks.export import enqueue_export
from app.tasks.provider_overrides import (
    get_task_embedding_provider,
    get_task_llm_provider,
)
from app.tasks.summary import enqueue_summary
from app.tasks.translation import enqueue_translation


def get_user_service(db: Annotated[Session, Depends(get_db)]) -> UserService:
    return UserService(UserRepository(db))


def get_document_service(
    db: Annotated[Session, Depends(get_db)],
    storage: Annotated[StorageProvider, Depends(get_storage_provider)],
) -> DocumentService:
    return DocumentService(
        DocumentRepository(db),
        storage=storage,
        enqueue_processing=enqueue_document_processing,
    )


def get_summary_service(
    db: Annotated[Session, Depends(get_db)],
) -> SummaryService:
    return SummaryService(
        DocumentRepository(db),
        enqueue_summary=enqueue_summary,
    )


def get_translation_service(
    db: Annotated[Session, Depends(get_db)],
) -> TranslationService:
    return TranslationService(
        DocumentRepository(db),
        enqueue_translation=enqueue_translation,
    )


def get_export_service(
    db: Annotated[Session, Depends(get_db)],
) -> ExportService:
    return ExportService(
        ExportRepository(db),
        DocumentRepository(db),
        ChatRepository(db),
        ChatMessageRepository(db),
        enqueue_export=enqueue_export,
    )


def get_chat_service(
    db: Annotated[Session, Depends(get_db)],
) -> ChatService:
    """Wire ChatService with LLM + RagPipeline (Search uses pipeline inside Master)."""
    pipeline = RagPipeline(
        chunker=Chunker(),
        embedder=Embedder(get_task_embedding_provider()),
        retriever=HybridRetriever(db),
        context_builder=ContextBuilder(),
        chunk_store=DocumentChunkRepository(db),
    )
    return ChatService(
        ChatRepository(db),
        ChatMessageRepository(db),
        DocumentRepository(db),
        DocumentChunkRepository(db),
        llm=get_task_llm_provider(),
        rag_pipeline=pipeline,
    )
