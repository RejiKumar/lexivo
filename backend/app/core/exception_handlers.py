"""Shared FastAPI exception handlers (quota + future cross-cutting errors)."""

from __future__ import annotations

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse

from app.services.base import QuotaExceededError


def register_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(QuotaExceededError)
    async def quota_exceeded_handler(
        _request: Request, exc: QuotaExceededError
    ) -> JSONResponse:
        return JSONResponse(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            content={"detail": exc.to_detail()},
        )
