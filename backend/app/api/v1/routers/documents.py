"""Thin documents router — create/list/get/status via DocumentService only."""

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status

from app.adapters.types import UserIdentity
from app.api.deps import get_document_service, get_user_service
from app.core.security import get_current_user
from app.models import DocumentStatus
from app.schemas.documents import (
    DocumentListResponse,
    DocumentResponse,
    DocumentStatusResponse,
)
from app.services.base import NotFoundError
from app.services.document_service import DocumentService
from app.services.user_service import UserService

router = APIRouter(prefix="/documents", tags=["documents"])


async def _current_db_user(
    identity: UserIdentity = Depends(get_current_user),
    users: UserService = Depends(get_user_service),
):
    return users.upsert_from_identity(identity)


@router.post("", response_model=DocumentResponse, status_code=status.HTTP_201_CREATED)
async def create_document(
    file: UploadFile = File(...),
    title: str | None = Form(default=None),
    user=Depends(_current_db_user),
    documents: DocumentService = Depends(get_document_service),
) -> DocumentResponse:
    content = await file.read()
    filename = file.filename or "upload.bin"
    doc = await documents.create_with_upload(
        user_id=user.id,
        title=title or filename,
        file_bytes=content,
        filename=filename,
    )
    return DocumentResponse.model_validate(doc)


@router.get("", response_model=DocumentListResponse)
async def list_documents(
    status_filter: DocumentStatus | None = None,
    user=Depends(_current_db_user),
    documents: DocumentService = Depends(get_document_service),
) -> DocumentListResponse:
    items = documents.list_for_user(user.id, status=status_filter)
    return DocumentListResponse(
        items=[DocumentResponse.model_validate(d) for d in items]
    )


@router.get("/{document_id}", response_model=DocumentResponse)
async def get_document(
    document_id: str,
    user=Depends(_current_db_user),
    documents: DocumentService = Depends(get_document_service),
) -> DocumentResponse:
    try:
        doc = documents.get(document_id)
    except NotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=exc.message,
        ) from exc
    if doc.user_id != user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Document not found",
        )
    return DocumentResponse.model_validate(doc)


@router.get("/{document_id}/status", response_model=DocumentStatusResponse)
async def get_document_status(
    document_id: str,
    user=Depends(_current_db_user),
    documents: DocumentService = Depends(get_document_service),
) -> DocumentStatusResponse:
    try:
        doc = documents.get(document_id)
    except NotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=exc.message,
        ) from exc
    if doc.user_id != user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Document not found",
        )
    return DocumentStatusResponse(id=doc.id, status=doc.status.value)
