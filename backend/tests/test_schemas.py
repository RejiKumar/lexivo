"""Schema contract tests for auth/users/documents Pydantic models."""

from app.schemas import (
    AuthSessionResponse,
    DocumentListResponse,
    DocumentResponse,
    DocumentStatusResponse,
    UserProfileResponse,
    UserProfileUpdateRequest,
)


def test_auth_session_schema_fields() -> None:
    payload = AuthSessionResponse(
        subject="sub-1",
        email="a@example.com",
        display_name="Ada",
    )
    assert payload.model_dump() == {
        "subject": "sub-1",
        "email": "a@example.com",
        "display_name": "Ada",
    }


def test_user_profile_request_response_fields() -> None:
    update = UserProfileUpdateRequest(display_name="New Name", email=None)
    assert update.model_dump(exclude_none=True) == {"display_name": "New Name"}

    profile = UserProfileResponse(
        id="u1",
        external_id="ext-1",
        email="u@example.com",
        display_name="User",
        created_at=None,
        updated_at=None,
    )
    data = profile.model_dump()
    assert data["id"] == "u1"
    assert data["external_id"] == "ext-1"


def test_document_create_list_status_schemas() -> None:
    doc = DocumentResponse(
        id="d1",
        user_id="u1",
        title="Lease",
        storage_key="documents/u1/lease.pdf",
        status="processing",
        created_at=None,
        updated_at=None,
    )
    assert doc.status == "processing"

    listing = DocumentListResponse(items=[doc])
    assert len(listing.items) == 1

    status = DocumentStatusResponse(id="d1", status="ready")
    assert status.model_dump() == {"id": "d1", "status": "ready"}
