"""Cloudflare R2 storage adapter (S3-compatible via boto3)."""

from __future__ import annotations

import asyncio

import boto3
from botocore.client import BaseClient

from app.adapters.storage.errors import StorageNotConfiguredError


class R2StorageAdapter:
    """StorageProvider implementation for Cloudflare R2."""

    def __init__(
        self,
        *,
        endpoint_url: str,
        access_key_id: str,
        secret_access_key: str,
        bucket_name: str,
        region_name: str = "auto",
        signed_url_expires_seconds: int = 3600,
        client: BaseClient | None = None,
    ) -> None:
        self._bucket = bucket_name
        self._expires = signed_url_expires_seconds
        self._missing = [
            name
            for name, value in (
                ("R2_ENDPOINT_URL", endpoint_url),
                ("R2_ACCESS_KEY_ID", access_key_id),
                ("R2_SECRET_ACCESS_KEY", secret_access_key),
                ("R2_BUCKET_NAME", bucket_name),
            )
            if not value
        ]
        if client is not None:
            self._client = client
            self._missing = []
        else:
            self._client = boto3.client(
                "s3",
                endpoint_url=endpoint_url or None,
                aws_access_key_id=access_key_id or None,
                aws_secret_access_key=secret_access_key or None,
                region_name=region_name,
            )

    def _require_config(self) -> None:
        if self._missing:
            raise StorageNotConfiguredError(
                "Cloudflare R2 is not configured - set "
                f"{', '.join(self._missing)} in backend/.env and restart the API."
            )

    async def upload(self, key: str, file: bytes) -> str:
        self._require_config()
        await asyncio.to_thread(
            self._client.put_object,
            Bucket=self._bucket,
            Key=key,
            Body=file,
        )
        return key

    async def signed_url(self, key: str) -> str:
        self._require_config()
        url: str = await asyncio.to_thread(
            self._client.generate_presigned_url,
            "get_object",
            Params={"Bucket": self._bucket, "Key": key},
            ExpiresIn=self._expires,
        )
        return url
