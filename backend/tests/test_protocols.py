"""Unit tests for adapter Protocol shapes (architecture.md §3.3)."""

import inspect

from app.adapters.protocols import (
    AuthProvider,
    LLMProvider,
    OCRProvider,
    StorageProvider,
)
from app.adapters.types import OCRResult, UserIdentity


class _FakeAuth:
    async def verify_token(self, token: str) -> UserIdentity:
        return UserIdentity(subject="user-1", email="a@b.co")


class _FakeStorage:
    async def upload(self, key: str, file: bytes) -> str:
        return key

    async def signed_url(self, key: str) -> str:
        return f"https://example.test/{key}"


class _FakeLLM:
    async def complete(self, prompt: str, **kwargs: object) -> str:
        return f"echo:{prompt}"


class _FakeOCR:
    async def extract_text(self, file: bytes) -> OCRResult:
        return OCRResult(text=file.decode("utf-8", errors="ignore"))


def test_auth_provider_protocol_is_structural() -> None:
    assert isinstance(_FakeAuth(), AuthProvider)
    assert "verify_token" in AuthProvider.__protocol_attrs__  # type: ignore[attr-defined]


def test_storage_provider_protocol_is_structural() -> None:
    provider = _FakeStorage()
    assert isinstance(provider, StorageProvider)
    assert inspect.iscoroutinefunction(provider.upload)
    assert inspect.iscoroutinefunction(provider.signed_url)


def test_llm_provider_protocol_is_structural() -> None:
    assert isinstance(_FakeLLM(), LLMProvider)


def test_ocr_provider_protocol_is_structural() -> None:
    assert isinstance(_FakeOCR(), OCRProvider)


def test_shared_types_user_identity_and_ocr_result() -> None:
    identity = UserIdentity(subject="sub", email="x@y.z", claims={"role": "user"})
    assert identity.subject == "sub"
    assert identity.claims["role"] == "user"

    result = OCRResult(text="hello", pages=2, metadata={"engine": "test"})
    assert result.text == "hello"
    assert result.pages == 2
