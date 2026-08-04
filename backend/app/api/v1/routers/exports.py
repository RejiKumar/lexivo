"""Thin exports router — create/status/get via ExportService only."""

from fastapi import APIRouter, Depends, HTTPException, status

from app.adapters.types import UserIdentity
from app.api.deps import get_export_service, get_user_service
from app.core.security import get_current_user
from app.schemas.exports import ExportRequest, ExportResponse
from app.services.base import ConflictError, NotFoundError, ValidationError
from app.services.export_service import ExportService
from app.services.user_service import UserService

router = APIRouter(tags=["exports"])


async def _current_db_user(
    identity: UserIdentity = Depends(get_current_user),
    users: UserService = Depends(get_user_service),
):
    return users.upsert_from_identity(identity)


@router.post(
    "/documents/{document_id}/export",
    response_model=ExportResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
async def request_document_export(
    document_id: str,
    body: ExportRequest,
    user=Depends(_current_db_user),
    exports: ExportService = Depends(get_export_service),
) -> ExportResponse:
    try:
        export = exports.request_export(
            document_id=document_id,
            user_id=user.id,
            include_summary=body.include_summary,
            include_translation=body.include_translation,
            include_chat=body.include_chat,
        )
    except NotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=exc.message,
        ) from exc
    except ConflictError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=exc.message,
        ) from exc
    except ValidationError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=exc.message,
        ) from exc
    return ExportResponse.from_orm_export(export)


@router.get(
    "/documents/{document_id}/export/status",
    response_model=ExportResponse,
)
async def get_document_export_status(
    document_id: str,
    user=Depends(_current_db_user),
    exports: ExportService = Depends(get_export_service),
) -> ExportResponse:
    try:
        export = exports.get_export_status(
            document_id=document_id, user_id=user.id
        )
    except NotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=exc.message,
        ) from exc
    return ExportResponse.from_orm_export(export)


@router.get(
    "/exports/{export_id}",
    response_model=ExportResponse,
)
async def get_export(
    export_id: str,
    user=Depends(_current_db_user),
    exports: ExportService = Depends(get_export_service),
) -> ExportResponse:
    try:
        export = exports.get_export(export_id=export_id, user_id=user.id)
    except NotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=exc.message,
        ) from exc
    return ExportResponse.from_orm_export(export)
