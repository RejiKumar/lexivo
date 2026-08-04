"""Unit tests for SQLAlchemy engine/session factory and FastAPI get_db."""

from collections.abc import Generator

import pytest
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.db import SessionLocal, get_db, get_engine, reset_engine


@pytest.fixture(autouse=True)
def _sqlite_engine(monkeypatch: pytest.MonkeyPatch) -> Generator[None, None, None]:
    monkeypatch.setenv("DATABASE_URL", "sqlite+pysqlite:///:memory:")
    # Clear cached settings if used by db module
    from app.core.config import get_settings

    get_settings.cache_clear()
    reset_engine()
    yield
    reset_engine()
    get_settings.cache_clear()


def test_get_engine_creates_usable_connection() -> None:
    engine = get_engine()
    with engine.connect() as conn:
        result = conn.execute(text("SELECT 1"))
        assert result.scalar() == 1


def test_session_local_yields_session() -> None:
    get_engine()
    session = SessionLocal()
    try:
        assert isinstance(session, Session)
        assert session.execute(text("SELECT 1")).scalar() == 1
    finally:
        session.close()


def test_get_db_dependency_yields_and_closes_session(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    closed = {"value": False}
    original_close = Session.close

    def tracking_close(self: Session) -> None:
        closed["value"] = True
        return original_close(self)

    monkeypatch.setattr(Session, "close", tracking_close)

    gen = get_db()
    session = next(gen)
    assert isinstance(session, Session)
    assert session.execute(text("SELECT 1")).scalar() == 1
    gen.close()
    assert closed["value"] is True
