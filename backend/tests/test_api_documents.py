"""API tests for thin documents router via DocumentService."""

from fastapi.testclient import TestClient

from app.adapters.protocols import StorageProvider
from tests.conftest import make_auth_header
from tests.fakes import FakeStorageProvider


def test_create_list_get_status_document(api_client: TestClient) -> None:
    headers = make_auth_header(sub="doc-api-user", email="docs@example.com")

    create_resp = api_client.post(
        "/api/v1/documents",
        headers=headers,
        files={"file": ("lease.pdf", b"%PDF-lease", "application/pdf")},
        data={"title": "Lease"},
    )
    assert create_resp.status_code == 201
    created = create_resp.json()
    assert created["title"] == "Lease"
    # Create response may still say processing; eager OCR updates DB before return
    # of the handler's follow-up status query.
    assert created["storage_key"]
    doc_id = created["id"]

    list_resp = api_client.get("/api/v1/documents", headers=headers)
    assert list_resp.status_code == 200
    assert len(list_resp.json()["items"]) == 1

    get_resp = api_client.get(f"/api/v1/documents/{doc_id}", headers=headers)
    assert get_resp.status_code == 200
    assert get_resp.json()["id"] == doc_id

    status_resp = api_client.get(f"/api/v1/documents/{doc_id}/status", headers=headers)
    assert status_resp.status_code == 200
    assert status_resp.json() == {"id": doc_id, "status": "ready"}


def test_documents_require_auth(api_client: TestClient) -> None:
    assert api_client.get("/api/v1/documents").status_code == 401


def test_openapi_lists_auth_users_documents_paths(api_client: TestClient) -> None:
    spec = api_client.get("/openapi.json").json()
    paths = set(spec["paths"].keys())
    assert "/api/v1/auth/me" in paths
    assert "/api/v1/users/me" in paths
    assert "/api/v1/documents" in paths
    assert "/api/v1/documents/{document_id}" in paths
    assert "/api/v1/documents/{document_id}/status" in paths

    assert isinstance(FakeStorageProvider(), StorageProvider)
