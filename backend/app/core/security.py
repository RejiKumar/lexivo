"""Security helpers: bearer extraction and AuthProvider-backed identity."""

from __future__ import annotations

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.adapters.protocols import AuthProvider
from app.adapters.types import UserIdentity
from app.core.dependencies import get_auth_provider
from app.core.exceptions import AuthenticationError

_bearer_scheme = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer_scheme),
    auth: AuthProvider = Depends(get_auth_provider),
) -> UserIdentity:
    """Resolve the current user via AuthProvider; raise 401 on failure."""
    if credentials is None or not credentials.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing bearer token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    try:
        return await auth.verify_token(credentials.credentials)
    except AuthenticationError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=exc.message,
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc
