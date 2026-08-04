"""Thin subscriptions router — me + stub upgrade via SubscriptionService."""

from fastapi import APIRouter, Depends, HTTPException, status

from app.adapters.types import UserIdentity
from app.api.deps import get_subscription_service, get_user_service
from app.core.security import get_current_user
from app.schemas.subscriptions import (
    QuotaExceededDetail,
    SubscriptionMeResponse,
    SubscriptionUpgradeResponse,
)
from app.services.base import ConflictError
from app.services.subscription_service import SubscriptionService
from app.services.user_service import UserService

router = APIRouter(prefix="/subscriptions", tags=["subscriptions"])

_QUOTA_RESPONSES = {
    429: {
        "description": "Free-tier quota exceeded",
        "model": QuotaExceededDetail,
    }
}


async def _current_db_user(
    identity: UserIdentity = Depends(get_current_user),
    users: UserService = Depends(get_user_service),
):
    return users.upsert_from_identity(identity)


@router.get(
    "/me",
    response_model=SubscriptionMeResponse,
    responses=_QUOTA_RESPONSES,
)
async def get_subscription_me(
    user=Depends(_current_db_user),
    subscriptions: SubscriptionService = Depends(get_subscription_service),
) -> SubscriptionMeResponse:
    payload = subscriptions.get_me(user.id)
    return SubscriptionMeResponse.model_validate(payload)


@router.post("/upgrade", response_model=SubscriptionUpgradeResponse)
async def upgrade_subscription(
    user=Depends(_current_db_user),
    subscriptions: SubscriptionService = Depends(get_subscription_service),
) -> SubscriptionUpgradeResponse:
    try:
        sub = subscriptions.upgrade(user.id)
    except ConflictError as exc:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=exc.message,
        ) from exc
    return SubscriptionUpgradeResponse(
        tier=sub.tier.value,
        status=sub.status.value,
        paywall_enabled=True,
    )
