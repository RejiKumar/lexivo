"""FastAPI dependencies that construct domain services (repos via session)."""

from typing import Annotated

from fastapi import Depends
from sqlalchemy.orm import Session

from app.adapters.protocols import StorageProvider
from app.core.db import get_db
from app.core.dependencies import get_storage_provider
from app.repositories.document_repo import DocumentRepository
from app.repositories.user_repo import UserRepository
from app.services.document_service import DocumentService
from app.services.user_service import UserService
from app.tasks.document_processing import enqueue_document_processing


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
