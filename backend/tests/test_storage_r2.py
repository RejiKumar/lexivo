"""Unit tests for R2 storage adapter (mocked boto3 — no live R2)."""

from unittest.mock import MagicMock

import pytest

from app.adapters.protocols import StorageProvider
from app.adapters.storage.r2_adapter import R2StorageAdapter


@pytest.fixture
def mock_s3_client() -> MagicMock:
    client = MagicMock()
    client.generate_presigned_url.return_value = (
        "https://r2.example.test/bucket/docs/a.pdf?X-Amz-Expires=3600&sig=abc"
    )
    return client


@pytest.fixture
def adapter(mock_s3_client: MagicMock) -> R2StorageAdapter:
    return R2StorageAdapter(
        endpoint_url="https://account.r2.cloudflarestorage.com",
        access_key_id="akid",
        secret_access_key="secret",
        bucket_name="lexivo",
        client=mock_s3_client,
    )


def test_r2_adapter_satisfies_storage_provider_protocol(
    adapter: R2StorageAdapter,
) -> None:
    assert isinstance(adapter, StorageProvider)


@pytest.mark.asyncio
async def test_upload_returns_object_key(
    adapter: R2StorageAdapter,
    mock_s3_client: MagicMock,
) -> None:
    key = await adapter.upload("docs/a.pdf", b"%PDF-1.4")

    assert key == "docs/a.pdf"
    mock_s3_client.put_object.assert_called_once_with(
        Bucket="lexivo",
        Key="docs/a.pdf",
        Body=b"%PDF-1.4",
    )


@pytest.mark.asyncio
async def test_signed_url_returns_time_limited_url(
    adapter: R2StorageAdapter,
    mock_s3_client: MagicMock,
) -> None:
    url = await adapter.signed_url("docs/a.pdf")

    assert url.startswith("https://")
    assert "X-Amz-Expires" in url or "sig=" in url
    mock_s3_client.generate_presigned_url.assert_called_once_with(
        "get_object",
        Params={"Bucket": "lexivo", "Key": "docs/a.pdf"},
        ExpiresIn=3600,
    )
