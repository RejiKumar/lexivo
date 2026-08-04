"""Unit tests for BaseService CRUD shape (architecture.md §3.2)."""

from collections.abc import Generator
from dataclasses import dataclass
from typing import Any

import pytest

from app.services.base import BaseService, NotFoundError


@dataclass
class FakeEntity:
    id: str
    name: str


class FakeRepo:
    def __init__(self) -> None:
        self._items: dict[str, FakeEntity] = {}
        self._seq = 0

    def create(self, **fields: Any) -> FakeEntity:
        self._seq += 1
        entity = FakeEntity(id=str(self._seq), name=fields["name"])
        self._items[entity.id] = entity
        return entity

    def get(self, entity_id: str) -> FakeEntity | None:
        return self._items.get(entity_id)

    def list(self, filters: dict[str, Any] | None = None) -> list[FakeEntity]:
        items = list(self._items.values())
        if filters and "name" in filters:
            items = [i for i in items if i.name == filters["name"]]
        return items

    def update(self, entity_id: str, **fields: Any) -> FakeEntity | None:
        entity = self._items.get(entity_id)
        if entity is None:
            return None
        if "name" in fields and fields["name"] is not None:
            entity.name = fields["name"]
        return entity

    def delete(self, entity_id: str) -> bool:
        return self._items.pop(entity_id, None) is not None


@pytest.fixture
def service() -> Generator[BaseService[FakeEntity], None, None]:
    yield BaseService(FakeRepo())


def test_base_service_create_get_list_update_delete(
    service: BaseService[FakeEntity],
) -> None:
    created = service.create({"name": "alpha"})
    assert created.id == "1"
    assert created.name == "alpha"

    assert service.get("1").name == "alpha"
    assert [e.name for e in service.list()] == ["alpha"]

    updated = service.update("1", {"name": "beta"})
    assert updated.name == "beta"

    service.delete("1")
    with pytest.raises(NotFoundError):
        service.get("1")


def test_base_service_get_missing_raises(service: BaseService[FakeEntity]) -> None:
    with pytest.raises(NotFoundError):
        service.get("missing")


def test_base_service_update_missing_raises(service: BaseService[FakeEntity]) -> None:
    with pytest.raises(NotFoundError):
        service.update("missing", {"name": "x"})


def test_base_service_list_filters(service: BaseService[FakeEntity]) -> None:
    service.create({"name": "a"})
    service.create({"name": "b"})
    assert [e.name for e in service.list({"name": "b"})] == ["b"]
