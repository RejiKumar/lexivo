"""Generic domain service CRUD shape (architecture.md §3.2)."""

from __future__ import annotations

from typing import Any, Generic, Protocol, TypeVar

T = TypeVar("T")


class NotFoundError(Exception):
    """Raised when a domain entity cannot be found."""

    def __init__(self, message: str = "Not found") -> None:
        self.message = message
        super().__init__(message)


class ConflictError(Exception):
    """Raised when a domain operation cannot proceed (e.g. document not ready)."""

    def __init__(self, message: str = "Conflict") -> None:
        self.message = message
        super().__init__(message)


class RepositoryProtocol(Protocol[T]):
    def create(self, **fields: Any) -> T: ...

    def get(self, entity_id: str) -> T | None: ...

    def list(self, filters: dict[str, Any] | None = None) -> list[T]: ...

    def update(self, entity_id: str, **fields: Any) -> T | None: ...

    def delete(self, entity_id: str) -> bool: ...


class BaseService(Generic[T]):
    """Consistent CRUD surface for domain services."""

    def __init__(self, repository: RepositoryProtocol[T]) -> None:
        self._repo = repository

    def create(self, data: dict[str, Any]) -> T:
        return self._repo.create(**data)

    def get(self, id: str) -> T:
        entity = self._repo.get(id)
        if entity is None:
            raise NotFoundError(f"Entity {id} not found")
        return entity

    def list(self, filters: dict[str, Any] | None = None) -> list[T]:
        return self._repo.list(filters)

    def update(self, id: str, data: dict[str, Any]) -> T:
        entity = self._repo.update(id, **data)
        if entity is None:
            raise NotFoundError(f"Entity {id} not found")
        return entity

    def delete(self, id: str) -> None:
        if not self._repo.delete(id):
            raise NotFoundError(f"Entity {id} not found")
