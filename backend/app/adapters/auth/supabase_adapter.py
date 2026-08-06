"""Supabase Auth adapter — JWT verification via JWKS or shared project secret."""

from __future__ import annotations

from functools import lru_cache

import anyio
import jwt

from app.adapters.types import UserIdentity
from app.core.exceptions import AuthenticationError

# Projects using JWT signing keys issue asymmetric access tokens; legacy
# projects sign with the shared HS256 secret.
_ASYMMETRIC_ALGORITHMS = frozenset({"ES256", "RS256"})

_JWKS_PATH = "/auth/v1/.well-known/jwks.json"


def jwks_url_for(supabase_url: str) -> str:
    """Public JWKS endpoint for a Supabase project URL ("" when unset)."""
    base = (supabase_url or "").strip().rstrip("/")
    if not base:
        return ""
    return f"{base}{_JWKS_PATH}"


@lru_cache(maxsize=8)
def _jwk_client(url: str) -> jwt.PyJWKClient:
    """Cached per URL so key material is fetched once, not once per request."""
    return jwt.PyJWKClient(url, cache_keys=True, lifespan=600)


class SupabaseAuthAdapter:
    """AuthProvider implementation for Supabase-issued JWTs (ES256/RS256/HS256)."""

    def __init__(
        self,
        jwt_secret: str = "",
        *,
        jwks_url: str = "",
        audience: str = "authenticated",
    ) -> None:
        self._jwt_secret = jwt_secret
        self._jwks_url = jwks_url
        self._audience = audience

    async def verify_token(self, token: str) -> UserIdentity:
        if not token or not token.strip():
            raise AuthenticationError("Missing token")

        try:
            algorithm = jwt.get_unverified_header(token).get("alg", "")
        except jwt.PyJWTError as exc:
            raise AuthenticationError("Invalid token") from exc

        if algorithm in _ASYMMETRIC_ALGORITHMS:
            key: object = await self._signing_key(token)
            algorithms = [algorithm]
        else:
            if not self._jwt_secret:
                raise AuthenticationError("Supabase Auth is not configured")
            key = self._jwt_secret
            algorithms = ["HS256"]

        try:
            payload = jwt.decode(
                token,
                key,
                algorithms=algorithms,
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

    async def _signing_key(self, token: str) -> object:
        if not self._jwks_url:
            raise AuthenticationError("Supabase Auth is not configured")

        client = _jwk_client(self._jwks_url)
        try:
            # PyJWKClient does blocking HTTP; keep the event loop free.
            signing_key = await anyio.to_thread.run_sync(
                client.get_signing_key_from_jwt, token
            )
        except jwt.PyJWTError as exc:
            raise AuthenticationError("Invalid token") from exc
        except Exception as exc:  # network / JWKS fetch failure
            raise AuthenticationError("Unable to verify token signing key") from exc
        return signing_key.key
