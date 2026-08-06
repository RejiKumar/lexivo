"""Create the Supabase Storage bucket from backend/.env if it does not exist.

Usage (repo root or backend):
  python tool/ensure_supabase_storage_bucket.py
"""

from __future__ import annotations

import sys
from pathlib import Path

import httpx

BACKEND_ROOT = Path(__file__).resolve().parents[1] / "backend"
sys.path.insert(0, str(BACKEND_ROOT))

from app.core.config import Settings  # noqa: E402


def main() -> int:
    settings = Settings()
    url = (settings.supabase_url or "").rstrip("/")
    key = (settings.supabase_service_role_key or "").strip()
    bucket = (settings.supabase_storage_bucket or "").strip()

    if not url or not key or not bucket:
        print(
            "Missing SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, or "
            "SUPABASE_STORAGE_BUCKET in backend/.env"
        )
        return 1

    headers = {
        "Authorization": f"Bearer {key}",
        "apikey": key,
        "Content-Type": "application/json",
    }

    with httpx.Client(timeout=30.0) as client:
        listed = client.get(f"{url}/storage/v1/bucket", headers=headers)
        listed.raise_for_status()
        names = {item.get("name") or item.get("id") for item in listed.json()}
        if bucket in names:
            print(f"Bucket already exists: {bucket}")
            return 0

        created = client.post(
            f"{url}/storage/v1/bucket",
            headers=headers,
            json={
                "id": bucket,
                "name": bucket,
                "public": False,
                "file_size_limit": 52428800,
            },
        )
        if created.status_code in {200, 201}:
            print(f"Created private bucket: {bucket}")
            return 0
        print(f"Failed to create bucket ({created.status_code}): {created.text}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
