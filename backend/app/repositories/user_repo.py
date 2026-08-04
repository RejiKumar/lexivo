"""User table repository (SQL only)."""

from typing import Any

from app.models import User
from app.repositories.base import BaseRepository


class UserRepository(BaseRepository[User]):
    model = User

    def create(
        self,
        *,
        external_id: str,
        email: str | None = None,
        display_name: str | None = None,
        **fields: Any,
    ) -> User:
        return super().create(
            external_id=external_id,
            email=email,
            display_name=display_name,
            **fields,
        )

    def get_by_external_id(self, external_id: str) -> User | None:
        return (
            self.session.query(User)
            .filter(User.external_id == external_id)
            .one_or_none()
        )
