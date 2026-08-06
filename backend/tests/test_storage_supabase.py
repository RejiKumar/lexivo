"""Unit tests for Supabase Storage adapter (mocked httpx — no live Supabase)."""

from __future__ import annotations

from unittest.mock import AsyncMock, MagicMock

import pytest

from app.adapters.protocols import StorageProvider
from app.adapters.storage.errors import StorageNotConfiguredError
from app.adapters.storage.supabase_adapter import SupabaseStorageAdapter


@pytest.fixture
def mock_client() -> MagicMock:
    client = MagicMock()
    client.aclose = AsyncMock()
    return client


@pytest.fixture
def adapter(mock_client: MagicMock) -> SupabaseStorageAdapter:
    return SupabaseStorageAdapter(
        supabase_url="https://example.supabase.co",
        service_role_key="service-role-test-key",
        bucket_name="lexivo",
        client=mock_client,
    )


def test_supabase_adapter_satisfies_storage_provider_protocol(
    adapter: SupabaseStorageAdapter,
) -> None:
    assert isinstance(adapter, StorageProvider)


@pytest.mark.asyncio
async def test_upload_returns_object_key(
    adapter: SupabaseStorageAdapter,
    mock_client: MagicMock,
) -> None:
    response = MagicMock()
    response.raise_for_status = MagicMock()
    mock_client.post = AsyncMock(return_value=response)

    key = await adapter.upload("docs/a.pdf", b"%PDF-1.4")

    assert key == "docs/a.pdf"
    mock_client.post.assert_awaited_once()
    args, kwargs = mock_client.post.await_args
    assert args[0].endswith("/storage/v1/object/lexivo/docs/a.pdf")
    assert kwargs["content"] == b"%PDF-1.4"
    assert kwargs["headers"]["x-upsert"] == "true"
    assert kwargs["headers"]["Authorization"] == "Bearer service-role-test-key"


@pytest.mark.asyncio
async def test_signed_url_returns_absolute_url(
    adapter: SupabaseStorageAdapter,
    mock_client: MagicMock,
) -> None:
    response = MagicMock()
    response.raise_for_status = MagicMock()
    response.json.return_value = {
        "signedURL": "/object/sign/lexivo/docs/a.pdf?token=abc",
    }
    mock_client.post = AsyncMock(return_value=response)

    url = await adapter.signed_url("docs/a.pdf")

    assert url == (
        "https://example.supabase.co/storage/v1/object/sign/lexivo/docs/a.pdf?token=abc"
    )
    args, kwargs = mock_client.post.await_args
    assert args[0].endswith("/storage/v1/object/sign/lexivo/docs/a.pdf")
    assert kwargs["json"] == {"expiresIn": 3600}


@pytest.mark.asyncio
async def test_upload_requires_service_role_key() -> None:
    adapter = SupabaseStorageAdapter(
        supabase_url="https://example.supabase.co",
        service_role_key="",
        bucket_name="lexivo",
    )
    with pytest.raises(StorageNotConfiguredError, match="SUPABASE_SERVICE_ROLE_KEY"):
        await adapter.upload("docs/a.pdf", b"%PDF-1.4")
