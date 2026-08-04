"""Unit tests for Supabase Auth adapter (mocked JWT — no live Supabase)."""

from datetime import UTC, datetime, timedelta

import jwt
import pytest

from app.adapters.auth.supabase_adapter import SupabaseAuthAdapter
from app.adapters.protocols import AuthProvider
from app.core.exceptions import AuthenticationError

JWT_SECRET = "test-supabase-jwt-secret-32chars!!"


def _make_token(
    *,
    sub: str = "user-123",
    email: str = "user@example.com",
    secret: str = JWT_SECRET,
    expired: bool = False,
    audience: str = "authenticated",
    extra: dict | None = None,
) -> str:
    now = datetime.now(UTC)
    payload: dict = {
        "sub": sub,
        "email": email,
        "aud": audience,
        "role": "authenticated",
        "iat": now,
        "exp": now + timedelta(hours=-1 if expired else 1),
        "user_metadata": {"full_name": "Test User"},
    }
    if extra:
        payload.update(extra)
    return jwt.encode(payload, secret, algorithm="HS256")


@pytest.fixture
def adapter() -> SupabaseAuthAdapter:
    return SupabaseAuthAdapter(jwt_secret=JWT_SECRET)


def test_supabase_adapter_satisfies_auth_provider_protocol(
    adapter: SupabaseAuthAdapter,
) -> None:
    assert isinstance(adapter, AuthProvider)


@pytest.mark.asyncio
async def test_valid_token_returns_user_identity(
    adapter: SupabaseAuthAdapter,
) -> None:
    token = _make_token()
    identity = await adapter.verify_token(token)

    assert identity.subject == "user-123"
    assert identity.email == "user@example.com"
    assert identity.display_name == "Test User"
    assert identity.claims["sub"] == "user-123"


@pytest.mark.asyncio
async def test_invalid_token_raises_authentication_error(
    adapter: SupabaseAuthAdapter,
) -> None:
    with pytest.raises(AuthenticationError, match="Invalid token"):
        await adapter.verify_token("not-a-jwt")


@pytest.mark.asyncio
async def test_missing_token_raises_authentication_error(
    adapter: SupabaseAuthAdapter,
) -> None:
    with pytest.raises(AuthenticationError, match="Missing token"):
        await adapter.verify_token("")


@pytest.mark.asyncio
async def test_wrong_secret_raises_authentication_error(
    adapter: SupabaseAuthAdapter,
) -> None:
    token = _make_token(secret="other-supabase-jwt-secret-32chars!")
    with pytest.raises(AuthenticationError, match="Invalid token"):
        await adapter.verify_token(token)


@pytest.mark.asyncio
async def test_expired_token_raises_authentication_error(
    adapter: SupabaseAuthAdapter,
) -> None:
    token = _make_token(expired=True)
    with pytest.raises(AuthenticationError, match="Invalid token"):
        await adapter.verify_token(token)


@pytest.mark.asyncio
async def test_unconfigured_secret_raises_authentication_error() -> None:
    adapter = SupabaseAuthAdapter(jwt_secret="")
    with pytest.raises(AuthenticationError, match="not configured"):
        await adapter.verify_token(_make_token())
