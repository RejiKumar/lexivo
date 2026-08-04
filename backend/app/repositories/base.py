"""Generic SQLAlchemy repository helpers (CRUD only)."""

from typing import Any, Generic, TypeVar

from sqlalchemy.orm import Session

from app.core.db import Base

ModelT = TypeVar("ModelT", bound=Base)


class BaseRepository(Generic[ModelT]):
    """Thin SQL CRUD wrapper around a single ORM model."""

    model: type[ModelT]

    def __init__(self, session: Session) -> None:
        self.session = session

    def create(self, **fields: Any) -> ModelT:
        entity = self.model(**fields)
        self.session.add(entity)
        self.session.commit()
        self.session.refresh(entity)
        return entity

    def get(self, entity_id: str) -> ModelT | None:
        return self.session.get(self.model, entity_id)

    def list(self, filters: dict[str, Any] | None = None) -> list[ModelT]:
        query = self.session.query(self.model)
        if filters:
            for key, value in filters.items():
                if value is None:
                    continue
                column = getattr(self.model, key, None)
                if column is None:
                    raise ValueError(f"Unknown filter field: {key}")
                query = query.filter(column == value)
        return list(query.all())

    def update(self, entity_id: str, **fields: Any) -> ModelT | None:
        entity = self.get(entity_id)
        if entity is None:
            return None
        for key, value in fields.items():
            if value is None:
                continue
            if not hasattr(entity, key):
                raise ValueError(f"Unknown field: {key}")
            setattr(entity, key, value)
        self.session.commit()
        self.session.refresh(entity)
        return entity

    def delete(self, entity_id: str) -> bool:
        entity = self.get(entity_id)
        if entity is None:
            return False
        self.session.delete(entity)
        self.session.commit()
        return True
