"""Unit tests for UserService upsert/get/update profile."""

from collections.abc import Generator

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.adapters.types import UserIdentity
from app.core.db import Base
from app.repositories.user_repo import UserRepository
from app.services.base import NotFoundError
from app.services.user_service import UserService


@pytest.fixture
def user_service() -> Generator[UserService, None, None]:
    engine = create_engine(
        "sqlite+pysqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    SessionLocal = sessionmaker(bind=engine, expire_on_commit=False)
    session = SessionLocal()
    try:
        yield UserService(UserRepository(session))
    finally:
        session.close()
        Base.metadata.drop_all(engine)
        engine.dispose()


def test_upsert_from_identity_creates_user(user_service: UserService) -> None:
    identity = UserIdentity(
        subject="ext-1",
        email="one@example.com",
        display_name="One",
    )
    user = user_service.upsert_from_identity(identity)
    assert user.external_id == "ext-1"
    assert user.email == "one@example.com"
    assert user.display_name == "One"


def test_upsert_from_identity_updates_existing(user_service: UserService) -> None:
    first = user_service.upsert_from_identity(
        UserIdentity(subject="ext-1", email="old@example.com", display_name="Old")
    )
    second = user_service.upsert_from_identity(
        UserIdentity(subject="ext-1", email="new@example.com", display_name="New")
    )
    assert second.id == first.id
    assert second.email == "new@example.com"
    # Custom/existing display_name is preserved on re-upsert
    assert second.display_name == "Old"

    user_service.update_profile(first.id, display_name="Custom")
    third = user_service.upsert_from_identity(
        UserIdentity(subject="ext-1", email="new@example.com", display_name="Ignored")
    )
    assert third.display_name == "Custom"


def test_get_and_update_profile_fields(user_service: UserService) -> None:
    user = user_service.upsert_from_identity(
        UserIdentity(subject="ext-2", email="two@example.com", display_name="Two")
    )
    fetched = user_service.get_profile(user.id)
    assert fetched.display_name == "Two"

    updated = user_service.update_profile(user.id, display_name="Two Updated")
    assert updated.display_name == "Two Updated"
    assert user_service.get_profile(user.id).display_name == "Two Updated"


def test_update_profile_rejects_unknown_user(user_service: UserService) -> None:
    with pytest.raises(NotFoundError):
        user_service.update_profile("missing", display_name="X")
