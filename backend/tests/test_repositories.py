"""Unit tests for User, Document, and Job repository CRUD (SQL only)."""

from sqlalchemy.orm import Session

from app.models import Document, DocumentStatus, Job, JobStatus, User
from app.repositories.document_repo import DocumentRepository
from app.repositories.job_repo import JobRepository
from app.repositories.user_repo import UserRepository


def test_user_repository_crud(db_session: Session) -> None:
    repo = UserRepository(db_session)

    created = repo.create(
        external_id="auth|abc",
        email="a@example.com",
        display_name="Ada",
    )
    assert created.id
    assert created.external_id == "auth|abc"
    assert created.email == "a@example.com"

    fetched = repo.get(created.id)
    assert fetched is not None
    assert fetched.email == "a@example.com"

    by_ext = repo.get_by_external_id("auth|abc")
    assert by_ext is not None
    assert by_ext.id == created.id

    updated = repo.update(created.id, display_name="Ada Lovelace", email="ada@example.com")
    assert updated is not None
    assert updated.display_name == "Ada Lovelace"
    assert updated.email == "ada@example.com"

    listed = repo.list()
    assert len(listed) == 1
    assert listed[0].id == created.id

    assert repo.delete(created.id) is True
    assert repo.get(created.id) is None
    assert repo.delete(created.id) is False


def test_document_repository_crud_and_user_filter(db_session: Session) -> None:
    users = UserRepository(db_session)
    docs = DocumentRepository(db_session)

    owner = users.create(external_id="u1", email="u1@example.com")
    other = users.create(external_id="u2", email="u2@example.com")

    doc = docs.create(
        user_id=owner.id,
        title="Contract",
        storage_key="docs/u1/contract.pdf",
        status=DocumentStatus.processing,
    )
    docs.create(
        user_id=other.id,
        title="Other",
        storage_key="docs/u2/other.pdf",
        status=DocumentStatus.ready,
    )

    assert docs.get(doc.id) is not None
    owner_docs = docs.list(filters={"user_id": owner.id})
    assert len(owner_docs) == 1
    assert owner_docs[0].title == "Contract"

    processing = docs.list(
        filters={"user_id": owner.id, "status": DocumentStatus.processing}
    )
    assert len(processing) == 1

    updated = docs.update(doc.id, status=DocumentStatus.ready, title="Contract v2")
    assert updated is not None
    assert updated.status == DocumentStatus.ready
    assert updated.title == "Contract v2"

    assert docs.delete(doc.id) is True
    assert docs.get(doc.id) is None


def test_job_repository_minimal_crud(db_session: Session) -> None:
    users = UserRepository(db_session)
    docs = DocumentRepository(db_session)
    jobs = JobRepository(db_session)

    user = users.create(external_id="job-user")
    document = docs.create(user_id=user.id, title="Scan")

    job = jobs.create(
        document_id=document.id,
        job_type="ocr",
        status=JobStatus.queued,
    )
    assert job.id
    assert jobs.get(job.id) is not None

    listed = jobs.list(filters={"document_id": document.id})
    assert len(listed) == 1

    updated = jobs.update(job.id, status=JobStatus.running)
    assert updated is not None
    assert updated.status == JobStatus.running

    assert jobs.delete(job.id) is True
    assert jobs.get(job.id) is None


def test_models_are_mapped_to_expected_tables() -> None:
    assert User.__tablename__ == "users"
    assert Document.__tablename__ == "documents"
    assert Job.__tablename__ == "jobs"
    assert {s.value for s in DocumentStatus} == {"processing", "ready", "failed"}
    assert {s.value for s in JobStatus} == {
        "queued",
        "running",
        "succeeded",
        "failed",
    }
