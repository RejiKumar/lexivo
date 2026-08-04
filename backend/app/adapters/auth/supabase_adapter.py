"""Supabase Auth adapter — JWT verification via shared project secret."""

from __future__ import annotations

import jwt

from app.adapters.types import UserIdentity
from app.core.exceptions import AuthenticationError


class SupabaseAuthAdapter:
    """AuthProvider implementation for Supabase-issued JWTs (HS256)."""

    def __init__(
        self,
        jwt_secret: str,
        *,
        audience: str = "authenticated",
    ) -> None:
        self._jwt_secret = jwt_secret
        self._audience = audience

    async def verify_token(self, token: str) -> UserIdentity:
        if not token or not token.strip():
            raise AuthenticationError("Missing token")
        if not self._jwt_secret:
            raise AuthenticationError("Supabase Auth is not configured")

        try:
            payload = jwt.decode(
                token,
                self._jwt_secret,
                algorithms=["HS256"],
                audience=self._audience,
            )
        except jwt.PyJWTError as exc:
            raise AuthenticationError("Invalid token") from exc

        subject = payload.get("sub")
        if not subject or not isinstance(subject, str):
            raise AuthenticationError("Invalid token: missing subject")

        email = payload.get("email")
        display_name = payload.get("user_metadata", {}).get("full_name")
        if display_name is None:
            display_name = payload.get("name")

        return UserIdentity(
            subject=subject,
            email=email if isinstance(email, str) else None,
            display_name=display_name if isinstance(display_name, str) else None,
            claims=dict(payload),
        )
