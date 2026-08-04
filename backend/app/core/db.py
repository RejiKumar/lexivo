"""SQLAlchemy engine, session factory, and FastAPI DB dependency."""

from collections.abc import Generator

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from app.core.config import get_settings

_engine: Engine | None = None
SessionLocal: sessionmaker[Session] = sessionmaker(
    autocommit=False,
    autoflush=False,
    expire_on_commit=False,
)


class Base(DeclarativeBase):
    """ORM declarative base for models and Alembic metadata."""


def get_engine() -> Engine:
    """Return a process-wide engine, creating it on first use from Settings."""
    global _engine
    if _engine is None:
        settings = get_settings()
        connect_args: dict = {}
        if settings.database_url.startswith("sqlite"):
            connect_args["check_same_thread"] = False
        _engine = create_engine(
            settings.database_url,
            pool_pre_ping=True,
            connect_args=connect_args,
        )
        SessionLocal.configure(bind=_engine)
    return _engine


def reset_engine() -> None:
    """Dispose and clear the cached engine (tests only)."""
    global _engine
    if _engine is not None:
        _engine.dispose()
        _engine = None
    SessionLocal.configure(bind=None)


def get_db() -> Generator[Session, None, None]:
    """FastAPI dependency that yields a DB session and closes it afterward."""
    get_engine()
    session = SessionLocal()
    try:
        yield session
    finally:
        session.close()
