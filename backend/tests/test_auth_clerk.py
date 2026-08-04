"""Unit tests for Clerk Auth stub adapter."""

import pytest

from app.adapters.auth.clerk_adapter import (
    CLERK_STUB_EMAIL,
    CLERK_STUB_SUBJECT,
    CLERK_STUB_TOKEN,
    ClerkAuthAdapter,
)
from app.adapters.protocols import AuthProvider
from app.core.exceptions import AuthenticationError


def test_clerk_adapter_satisfies_auth_provider_protocol() -> None:
    assert isinstance(ClerkAuthAdapter(), AuthProvider)


@pytest.mark.asyncio
async def test_stub_token_returns_deterministic_identity() -> None:
    adapter = ClerkAuthAdapter(secret_key="")
    identity = await adapter.verify_token(CLERK_STUB_TOKEN)

    assert identity.subject == CLERK_STUB_SUBJECT
    assert identity.email == CLERK_STUB_EMAIL
    assert identity.claims.get("stub") is True


@pytest.mark.asyncio
async def test_missing_token_raises() -> None:
    adapter = ClerkAuthAdapter()
    with pytest.raises(AuthenticationError, match="Missing token"):
        await adapter.verify_token("")


@pytest.mark.asyncio
async def test_unconfigured_clerk_rejects_non_stub_token() -> None:
    adapter = ClerkAuthAdapter(secret_key="")
    with pytest.raises(AuthenticationError, match="not configured"):
        await adapter.verify_token("some-real-looking-jwt")


@pytest.mark.asyncio
async def test_configured_clerk_rejects_unknown_token() -> None:
    adapter = ClerkAuthAdapter(secret_key="sk_test_xxx")
    with pytest.raises(AuthenticationError, match="Invalid token"):
        await adapter.verify_token("unknown-token")
