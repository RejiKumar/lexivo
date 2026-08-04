"""Clerk Auth stub adapter — deterministic local/test behavior only."""

from __future__ import annotations

from app.adapters.types import UserIdentity
from app.core.exceptions import AuthenticationError

# Well-known token accepted by the stub when Clerk is not fully configured.
CLERK_STUB_TOKEN = "clerk-stub-token"
CLERK_STUB_SUBJECT = "clerk-stub-user"
CLERK_STUB_EMAIL = "stub@clerk.local"


class ClerkAuthAdapter:
    """
    Stub AuthProvider behind the same Protocol as production Clerk.

    Accepts ``CLERK_STUB_TOKEN`` for deterministic local tests. Any other
    token raises AuthenticationError (including a clear message when the
    Clerk secret is unset).
    """

    def __init__(self, secret_key: str = "") -> None:
        self._secret_key = secret_key

    async def verify_token(self, token: str) -> UserIdentity:
        if not token or not token.strip():
            raise AuthenticationError("Missing token")

        if token == CLERK_STUB_TOKEN:
            return UserIdentity(
                subject=CLERK_STUB_SUBJECT,
                email=CLERK_STUB_EMAIL,
                display_name="Clerk Stub",
                claims={"provider": "clerk", "stub": True},
            )

        if not self._secret_key:
            raise AuthenticationError("Clerk auth is not configured")

        raise AuthenticationError("Invalid token")
