"""User domain service — identity persistence and account settings."""

from __future__ import annotations

from typing import Any

from app.adapters.types import UserIdentity
from app.models import User
from app.repositories.user_repo import UserRepository
from app.services.base import BaseService, NotFoundError

_ALLOWED_PROFILE_FIELDS = frozenset({"display_name", "email"})


class UserService(BaseService[User]):
    def __init__(self, repository: UserRepository) -> None:
        super().__init__(repository)
        self._users = repository

    def upsert_from_identity(self, identity: UserIdentity) -> User:
        existing = self._users.get_by_external_id(identity.subject)
        if existing is None:
            return self.create(
                {
                    "external_id": identity.subject,
                    "email": identity.email,
                    "display_name": identity.display_name,
                }
            )
        return self.update(
            existing.id,
            {
                "email": identity.email,
                "display_name": identity.display_name,
            },
        )

    def get_profile(self, user_id: str) -> User:
        return self.get(user_id)

    def update_profile(self, user_id: str, **fields: Any) -> User:
        payload = {
            key: value
            for key, value in fields.items()
            if key in _ALLOWED_PROFILE_FIELDS and value is not None
        }
        if not payload:
            return self.get(user_id)
        try:
            return self.update(user_id, payload)
        except NotFoundError:
            raise
