"""Supabase Storage adapter (Storage REST API via httpx)."""

from __future__ import annotations

import mimetypes
from typing import Any
from urllib.parse import quote

import httpx

from app.adapters.storage.errors import StorageNotConfiguredError


class SupabaseStorageAdapter:
    """StorageProvider implementation for Supabase Storage."""

    def __init__(
        self,
        *,
        supabase_url: str,
        service_role_key: str,
        bucket_name: str,
        signed_url_expires_seconds: int = 3600,
        client: httpx.AsyncClient | None = None,
    ) -> None:
        self._base_url = (supabase_url or "").rstrip("/")
        self._service_role_key = service_role_key or ""
        self._bucket = bucket_name
        self._expires = signed_url_expires_seconds
        self._client = client

    def _headers(self, *, content_type: str | None = None) -> dict[str, str]:
        headers = {
            "Authorization": f"Bearer {self._service_role_key}",
            "apikey": self._service_role_key,
        }
        if content_type:
            headers["Content-Type"] = content_type
        return headers

    def _object_path(self, key: str) -> str:
        # Encode each segment so nested keys stay valid URL paths.
        parts = [quote(part, safe="") for part in key.split("/") if part]
        return "/".join(parts)

    def _require_config(self) -> None:
        missing = [
            name
            for name, value in (
                ("SUPABASE_URL", self._base_url),
                ("SUPABASE_SERVICE_ROLE_KEY", self._service_role_key),
                ("SUPABASE_STORAGE_BUCKET", self._bucket),
            )
            if not value
        ]
        if missing:
            raise StorageNotConfiguredError(
                "Supabase Storage is not configured - set "
                f"{', '.join(missing)} in backend/.env and restart the API."
            )

    async def upload(self, key: str, file: bytes) -> str:
        self._require_config()

        content_type = mimetypes.guess_type(key)[0] or "application/octet-stream"
        url = (
            f"{self._base_url}/storage/v1/object/"
            f"{quote(self._bucket, safe='')}/{self._object_path(key)}"
        )

        owns_client = self._client is None
        client = self._client or httpx.AsyncClient()
        try:
            response = await client.post(
                url,
                headers={
                    **self._headers(content_type=content_type),
                    "x-upsert": "true",
                },
                content=file,
                timeout=120.0,
            )
            response.raise_for_status()
        finally:
            if owns_client:
                await client.aclose()
        return key

    async def signed_url(self, key: str) -> str:
        self._require_config()

        url = (
            f"{self._base_url}/storage/v1/object/sign/"
            f"{quote(self._bucket, safe='')}/{self._object_path(key)}"
        )

        owns_client = self._client is None
        client = self._client or httpx.AsyncClient()
        try:
            response = await client.post(
                url,
                headers=self._headers(content_type="application/json"),
                json={"expiresIn": self._expires},
                timeout=30.0,
            )
            response.raise_for_status()
            data: dict[str, Any] = response.json()
        finally:
            if owns_client:
                await client.aclose()

        signed = data.get("signedURL") or data.get("signedUrl") or ""
        if not isinstance(signed, str) or not signed:
            raise RuntimeError("Supabase Storage did not return a signed URL")
        if signed.startswith("http://") or signed.startswith("https://"):
            return signed
        if not signed.startswith("/"):
            signed = f"/{signed}"
        if signed.startswith("/storage/v1/"):
            return f"{self._base_url}{signed}"
        return f"{self._base_url}/storage/v1{signed}"
