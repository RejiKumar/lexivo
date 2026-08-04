"""API tests for thin documents router via DocumentService."""

from collections.abc import Generator
from datetime import UTC, datetime, timedelta

import jwt
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.adapters.auth.supabase_adapter import SupabaseAuthAdapter
from app.adapters.protocols import StorageProvider
from app.core.config import Settings, get_settings
from app.core.db import Base, get_db
from app.core.dependencies import get_auth_provider, get_storage_provider
from app.main import create_app
import app.models  # noqa: F401 — register ORM metadata

JWT_SECRET = "docs-router-test-jwt-secret-32chars"


class FakeStorage:
    async def upload(self, key: str, file: bytes) -> str:
        return f"s3://test/{key}"

    async def signed_url(self, key: str) -> str:
        return f"https://signed.test/{key}"


def _token(sub: str = "doc-api-user") -> str:
    now = datetime.now(UTC)
    return jwt.encode(
        {
            "sub": sub,
            "email": "docs@example.com",
            "aud": "authenticated",
            "iat": now,
            "exp": now + timedelta(hours=1),
        },
        JWT_SECRET,
        algorithm="HS256",
    )


@pytest.fixture
def client() -> Generator[TestClient, None, None]:
    engine = create_engine(
        "sqlite+pysqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    SessionLocal = sessionmaker(bind=engine, expire_on_commit=False)

    app = create_app()
    app.dependency_overrides[get_settings] = lambda: Settings(
        auth_provider="supabase",
        supabase_jwt_secret=JWT_SECRET,
        storage_provider="r2",
        r2_endpoint_url="https://example.r2.cloudflarestorage.com",
        r2_access_key_id="ak",
        r2_secret_access_key="sk",
        r2_bucket_name="bucket",
    )
    app.dependency_overrides[get_auth_provider] = lambda: SupabaseAuthAdapter(
        jwt_secret=JWT_SECRET,
    )
    app.dependency_overrides[get_storage_provider] = lambda: FakeStorage()

    def _override_db():
        session = SessionLocal()
        try:
            yield session
        finally:
            session.close()

    app.dependency_overrides[get_db] = _override_db

    with TestClient(app) as test_client:
        yield test_client

    app.dependency_overrides.clear()
    Base.metadata.drop_all(engine)
    engine.dispose()


def test_create_list_get_status_document(client: TestClient) -> None:
    headers = {"Authorization": f"Bearer {_token()}"}

    create_resp = client.post(
        "/api/v1/documents",
        headers=headers,
        files={"file": ("lease.pdf", b"%PDF-lease", "application/pdf")},
        data={"title": "Lease"},
    )
    assert create_resp.status_code == 201
    created = create_resp.json()
    assert created["title"] == "Lease"
    assert created["status"] == "processing"
    assert created["storage_key"]
    doc_id = created["id"]

    list_resp = client.get("/api/v1/documents", headers=headers)
    assert list_resp.status_code == 200
    assert len(list_resp.json()["items"]) == 1

    get_resp = client.get(f"/api/v1/documents/{doc_id}", headers=headers)
    assert get_resp.status_code == 200
    assert get_resp.json()["id"] == doc_id

    status_resp = client.get(f"/api/v1/documents/{doc_id}/status", headers=headers)
    assert status_resp.status_code == 200
    assert status_resp.json() == {"id": doc_id, "status": "processing"}


def test_documents_require_auth(client: TestClient) -> None:
    assert client.get("/api/v1/documents").status_code == 401


def test_openapi_lists_auth_users_documents_paths(client: TestClient) -> None:
    spec = client.get("/openapi.json").json()
    paths = set(spec["paths"].keys())
    assert "/api/v1/auth/me" in paths
    assert "/api/v1/users/me" in paths
    assert "/api/v1/documents" in paths
    assert "/api/v1/documents/{document_id}" in paths
    assert "/api/v1/documents/{document_id}/status" in paths

    # FakeStorage satisfies StorageProvider structurally
    assert isinstance(FakeStorage(), StorageProvider)
