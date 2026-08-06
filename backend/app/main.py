"""FastAPI application factory."""

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.routers import (
    app as app_router,
    auth,
    chats,
    documents,
    exports,
    health,
    notifications,
    subscriptions,
    users,
)
from app.core.config import Settings, get_settings
from app.core.env_validation import log_startup_config, validate_settings_or_raise
from app.core.exception_handlers import register_exception_handlers
from app.core.observability import init_sentry

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(_app: FastAPI):
    settings = get_settings()
    log_startup_config(settings)
    validate_settings_or_raise(settings)
    init_sentry(settings)
    logger.info("Lexivo API ready (providers validated).")
    yield


def _cors_origins(settings: Settings) -> list[str]:
    raw = settings.cors_origins.strip()
    if not raw or raw == "*":
        return ["*"]
    return [origin.strip() for origin in raw.split(",") if origin.strip()]


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(title="Lexivo API", version="0.1.0", lifespan=lifespan)
    origins = _cors_origins(settings)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=origins != ["*"],
        allow_methods=["*"],
        allow_headers=["*"],
    )
    register_exception_handlers(app)
    app.include_router(health.router, prefix="/api/v1")
    app.include_router(app_router.router, prefix="/api/v1")
    app.include_router(auth.router, prefix="/api/v1")
    app.include_router(users.router, prefix="/api/v1")
    app.include_router(documents.router, prefix="/api/v1")
    app.include_router(chats.router, prefix="/api/v1")
    app.include_router(exports.router, prefix="/api/v1")
    app.include_router(notifications.router, prefix="/api/v1")
    app.include_router(subscriptions.router, prefix="/api/v1")
    return app


app = create_app()
