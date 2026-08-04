"""Thin users router — profile via UserService only."""

from fastapi import APIRouter, Depends, HTTPException, status

from app.adapters.types import UserIdentity
from app.api.deps import get_user_service
from app.core.security import get_current_user
from app.schemas.users import UserProfileResponse, UserProfileUpdateRequest
from app.services.base import NotFoundError
from app.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserProfileResponse)
async def get_my_profile(
    identity: UserIdentity = Depends(get_current_user),
    users: UserService = Depends(get_user_service),
) -> UserProfileResponse:
    user = users.upsert_from_identity(identity)
    return UserProfileResponse.model_validate(user)


@router.patch("/me", response_model=UserProfileResponse)
async def update_my_profile(
    body: UserProfileUpdateRequest,
    identity: UserIdentity = Depends(get_current_user),
    users: UserService = Depends(get_user_service),
) -> UserProfileResponse:
    user = users.upsert_from_identity(identity)
    try:
        updated = users.update_profile(
            user.id,
            display_name=body.display_name,
            email=body.email,
        )
    except NotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=exc.message,
        ) from exc
    return UserProfileResponse.model_validate(updated)
