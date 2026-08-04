"""Adapter Protocol contracts (architecture.md §3.3). No vendor SDK imports."""

from typing import Protocol, runtime_checkable

from app.adapters.types import OCRResult, UserIdentity


@runtime_checkable
class AuthProvider(Protocol):
    async def verify_token(self, token: str) -> UserIdentity: ...


@runtime_checkable
class StorageProvider(Protocol):
    async def upload(self, key: str, file: bytes) -> str: ...

    async def signed_url(self, key: str) -> str: ...


@runtime_checkable
class LLMProvider(Protocol):
    async def complete(self, prompt: str, **kwargs: object) -> str: ...


@runtime_checkable
class OCRProvider(Protocol):
    async def extract_text(self, file: bytes) -> OCRResult: ...
