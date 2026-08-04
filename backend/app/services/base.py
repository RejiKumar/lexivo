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


class ValidationError(Exception):
    """Raised when request payload fails domain validation (e.g. unsupported lang)."""

    def __init__(self, message: str = "Validation failed") -> None:
        self.message = message
        super().__init__(message)


class QuotaExceededError(Exception):
    """Raised when a free-tier usage cap is exceeded.

    Mapped once by the FastAPI exception handler to HTTP 429 with a consistent
    ``quota_exceeded`` detail body (not ad-hoc per router).
    """

    def __init__(
        self,
        *,
        resource: str,
        limit: int,
        period: str,
        message: str | None = None,
    ) -> None:
        self.resource = resource
        self.limit = limit
        self.period = period
        self.message = message or (
            f"Free-tier {resource} limit of {limit} per {period} exceeded"
        )
        super().__init__(self.message)

    def to_detail(self) -> dict[str, object]:
        return {
            "code": "quota_exceeded",
            "resource": self.resource,
            "limit": self.limit,
            "period": self.period,
            "message": self.message,
        }


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
