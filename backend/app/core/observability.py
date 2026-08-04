"""Sentry bootstrap — init only when DSN is present."""

from __future__ import annotations

import logging
from typing import Any, Callable

from app.core.config import Settings

logger = logging.getLogger(__name__)

# Injectable for unit tests (mock init without importing SDK when DSN empty).
_sentry_init: Callable[..., Any] | None = None


def set_sentry_init_for_tests(fn: Callable[..., Any] | None) -> None:
    """Override Sentry init callable (tests only)."""
    global _sentry_init
    _sentry_init = fn


def init_sentry(settings: Settings) -> bool:
    """Initialize Sentry when ``sentry_dsn`` is non-empty.

    Returns True if init ran, False if skipped (empty DSN).
    """
    dsn = (settings.sentry_dsn or "").strip()
    if not dsn:
        logger.debug("Sentry skipped — SENTRY_DSN empty")
        return False

    kwargs: dict[str, Any] = {
        "dsn": dsn,
        "environment": settings.app_env,
        "traces_sample_rate": 0.0 if settings.app_env == "local" else 0.1,
    }

    if _sentry_init is not None:
        _sentry_init(**kwargs)
    else:
        import sentry_sdk
        from sentry_sdk.integrations.fastapi import FastApiIntegration
        from sentry_sdk.integrations.starlette import StarletteIntegration

        sentry_sdk.init(
            **kwargs,
            integrations=[
                StarletteIntegration(),
                FastApiIntegration(),
            ],
        )

    logger.info("Sentry initialized for app_env=%s", settings.app_env)
    return True
