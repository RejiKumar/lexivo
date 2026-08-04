"""Temporary AuthProvider stubs for DI until §3 SDK adapters land."""

from app.adapters.types import UserIdentity


class SupabaseAuthAdapter:
    """Default AuthProvider binding (SDK integration in §3)."""

    async def verify_token(self, token: str) -> UserIdentity:
        raise NotImplementedError("Supabase Auth SDK adapter not implemented yet (§3)")


class ClerkAuthAdapter:
    """Alternate AuthProvider stub (SDK integration in §3)."""

    async def verify_token(self, token: str) -> UserIdentity:
        raise NotImplementedError("Clerk Auth stub adapter not implemented yet (§3)")
