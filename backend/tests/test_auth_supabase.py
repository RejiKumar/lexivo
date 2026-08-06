"""Unit tests for Supabase Auth adapter (mocked JWT — no live Supabase)."""

from datetime import UTC, datetime, timedelta

import jwt
import pytest
from cryptography.hazmat.primitives.asymmetric import ec

from app.adapters.auth import supabase_adapter as supabase_auth
from app.adapters.auth.supabase_adapter import SupabaseAuthAdapter, jwks_url_for
from app.adapters.protocols import AuthProvider
from app.core.exceptions import AuthenticationError

JWT_SECRET = "test-supabase-jwt-secret-32chars!!"
JWKS_URL = "https://project.supabase.co/auth/v1/.well-known/jwks.json"


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


def test_jwks_url_derived_from_project_url() -> None:
    assert (
        jwks_url_for("https://project.supabase.co/")
        == "https://project.supabase.co/auth/v1/.well-known/jwks.json"
    )
    assert jwks_url_for("") == ""


def _make_es256_token(
    private_key: ec.EllipticCurvePrivateKey,
    *,
    sub: str = "user-es256",
    audience: str = "authenticated",
) -> str:
    now = datetime.now(UTC)
    return jwt.encode(
        {
            "sub": sub,
            "email": "ec@example.com",
            "aud": audience,
            "iat": now,
            "exp": now + timedelta(hours=1),
            "user_metadata": {"full_name": "EC User"},
        },
        private_key,
        algorithm="ES256",
    )


class _StubJwkClient:
    """Stands in for PyJWKClient so tests never hit the network."""

    def __init__(self, key: object) -> None:
        self._key = key

    def get_signing_key_from_jwt(self, _token: str) -> object:
        return type("_Key", (), {"key": self._key})()


@pytest.fixture
def es256_keys() -> tuple[ec.EllipticCurvePrivateKey, object]:
    private_key = ec.generate_private_key(ec.SECP256R1())
    return private_key, private_key.public_key()


@pytest.mark.asyncio
async def test_asymmetric_token_verified_through_jwks(
    monkeypatch: pytest.MonkeyPatch,
    es256_keys: tuple[ec.EllipticCurvePrivateKey, object],
) -> None:
    private_key, public_key = es256_keys
    monkeypatch.setattr(
        supabase_auth, "_jwk_client", lambda _url: _StubJwkClient(public_key)
    )

    adapter = SupabaseAuthAdapter(jwt_secret="", jwks_url=JWKS_URL)
    identity = await adapter.verify_token(_make_es256_token(private_key))

    assert identity.subject == "user-es256"
    assert identity.display_name == "EC User"


@pytest.mark.asyncio
async def test_asymmetric_token_rejected_when_signed_by_other_key(
    monkeypatch: pytest.MonkeyPatch,
    es256_keys: tuple[ec.EllipticCurvePrivateKey, object],
) -> None:
    _, public_key = es256_keys
    monkeypatch.setattr(
        supabase_auth, "_jwk_client", lambda _url: _StubJwkClient(public_key)
    )

    other_key = ec.generate_private_key(ec.SECP256R1())
    adapter = SupabaseAuthAdapter(jwt_secret="", jwks_url=JWKS_URL)

    with pytest.raises(AuthenticationError, match="Invalid token"):
        await adapter.verify_token(_make_es256_token(other_key))


@pytest.mark.asyncio
async def test_asymmetric_token_without_jwks_url_raises_not_configured(
    es256_keys: tuple[ec.EllipticCurvePrivateKey, object],
) -> None:
    private_key, _ = es256_keys
    adapter = SupabaseAuthAdapter(jwt_secret=JWT_SECRET)

    with pytest.raises(AuthenticationError, match="not configured"):
        await adapter.verify_token(_make_es256_token(private_key))


@pytest.mark.asyncio
async def test_jwks_fetch_failure_maps_to_authentication_error(
    monkeypatch: pytest.MonkeyPatch,
    es256_keys: tuple[ec.EllipticCurvePrivateKey, object],
) -> None:
    private_key, _ = es256_keys

    class _FailingClient:
        def get_signing_key_from_jwt(self, _token: str) -> object:
            raise ConnectionError("jwks unreachable")

    monkeypatch.setattr(supabase_auth, "_jwk_client", lambda _url: _FailingClient())
    adapter = SupabaseAuthAdapter(jwt_secret="", jwks_url=JWKS_URL)

    with pytest.raises(AuthenticationError, match="signing key"):
        await adapter.verify_token(_make_es256_token(private_key))
