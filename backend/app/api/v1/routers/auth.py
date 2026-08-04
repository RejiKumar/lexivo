"""Thin auth router — session/me via AuthProvider only."""

from fastapi import APIRouter, Depends

from app.adapters.types import UserIdentity
from app.core.security import get_current_user
from app.schemas.auth import AuthSessionResponse

router = APIRouter(prefix="/auth", tags=["auth"])


@router.get("/me", response_model=AuthSessionResponse)
async def auth_me(
    identity: UserIdentity = Depends(get_current_user),
) -> AuthSessionResponse:
    return AuthSessionResponse(
        subject=identity.subject,
        email=identity.email,
        display_name=identity.display_name,
    )
