"""Shared FastAPI exception handlers (quota, provider outages, cross-cutting)."""

from __future__ import annotations

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse

from app.adapters.llm.errors import LLMProviderError, LLMRateLimitError
from app.adapters.storage.errors import StorageNotConfiguredError
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

    @app.exception_handler(LLMProviderError)
    async def llm_provider_error_handler(
        _request: Request, exc: LLMProviderError
    ) -> JSONResponse:
        if isinstance(exc, LLMRateLimitError):
            code = status.HTTP_429_TOO_MANY_REQUESTS
        else:
            code = status.HTTP_502_BAD_GATEWAY
        return JSONResponse(status_code=code, content={"detail": exc.message})

    @app.exception_handler(StorageNotConfiguredError)
    async def storage_not_configured_handler(
        _request: Request, exc: StorageNotConfiguredError
    ) -> JSONResponse:
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={"detail": exc.message},
        )
