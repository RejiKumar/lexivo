"""FastAPI application factory."""

from fastapi import FastAPI

from app.api.v1.routers import auth, chats, documents, health, users


def create_app() -> FastAPI:
    app = FastAPI(title="Lexivo API", version="0.1.0")
    app.include_router(health.router, prefix="/api/v1")
    app.include_router(auth.router, prefix="/api/v1")
    app.include_router(users.router, prefix="/api/v1")
    app.include_router(documents.router, prefix="/api/v1")
    app.include_router(chats.router, prefix="/api/v1")
    return app


app = create_app()
