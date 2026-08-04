"""Thin notifications router — list + mark-read via NotificationService only."""

from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.adapters.types import UserIdentity
from app.api.deps import get_notification_service, get_user_service
from app.core.security import get_current_user
from app.schemas.notifications import NotificationListResponse, NotificationResponse
from app.services.base import NotFoundError
from app.services.notification_service import NotificationService
from app.services.user_service import UserService

router = APIRouter(tags=["notifications"])


async def _current_db_user(
    identity: UserIdentity = Depends(get_current_user),
    users: UserService = Depends(get_user_service),
):
    return users.upsert_from_identity(identity)


@router.get(
    "/notifications",
    response_model=NotificationListResponse,
)
async def list_notifications(
    unread_only: bool = Query(False),
    user=Depends(_current_db_user),
    notifications: NotificationService = Depends(get_notification_service),
) -> NotificationListResponse:
    rows = await notifications.list_notifications(
        user.id, unread_only=unread_only
    )
    items = [NotificationResponse.from_record(r) for r in rows]
    return NotificationListResponse(items=items, total=len(items))


@router.post(
    "/notifications/{notification_id}/read",
    response_model=NotificationResponse,
)
async def mark_notification_read(
    notification_id: str,
    user=Depends(_current_db_user),
    notifications: NotificationService = Depends(get_notification_service),
) -> NotificationResponse:
    try:
        record = await notifications.mark_read(user.id, notification_id)
    except NotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=exc.message,
        ) from exc
    return NotificationResponse.from_record(record)
