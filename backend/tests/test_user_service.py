"""Unit tests for UserService upsert/get/update profile."""

import pytest
from sqlalchemy.orm import Session

from app.adapters.types import UserIdentity
from app.repositories.user_repo import UserRepository
from app.services.base import NotFoundError
from app.services.user_service import UserService


def test_upsert_from_identity_creates_user(db_session: Session) -> None:
    user_service = UserService(UserRepository(db_session))
    identity = UserIdentity(
        subject="ext-1",
        email="one@example.com",
        display_name="One",
    )
    user = user_service.upsert_from_identity(identity)
    assert user.external_id == "ext-1"
    assert user.email == "one@example.com"
    assert user.display_name == "One"


def test_upsert_from_identity_updates_existing(db_session: Session) -> None:
    user_service = UserService(UserRepository(db_session))
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


def test_get_and_update_profile_fields(db_session: Session) -> None:
    user_service = UserService(UserRepository(db_session))
    user = user_service.upsert_from_identity(
        UserIdentity(subject="ext-2", email="two@example.com", display_name="Two")
    )
    fetched = user_service.get_profile(user.id)
    assert fetched.display_name == "Two"

    updated = user_service.update_profile(user.id, display_name="Two Updated")
    assert updated.display_name == "Two Updated"
    assert user_service.get_profile(user.id).display_name == "Two Updated"


def test_update_profile_rejects_unknown_user(db_session: Session) -> None:
    user_service = UserService(UserRepository(db_session))
    with pytest.raises(NotFoundError):
        user_service.update_profile("missing", display_name="X")
