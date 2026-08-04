"""No-op AnalyticsProvider stub (no PostHog SDK)."""

from __future__ import annotations

import logging
from typing import Any

logger = logging.getLogger(__name__)


class StubAnalyticsProvider:
    """AnalyticsProvider adapter that records track calls without network I/O."""

    def __init__(self) -> None:
        self.events: list[dict[str, Any]] = []

    async def track(
        self,
        event: str,
        *,
        user_id: str | None,
        properties: dict[str, Any],
    ) -> None:
        record = {"event": event, "user_id": user_id, "properties": dict(properties)}
        self.events.append(record)
        logger.info("StubAnalyticsProvider.track %s", record)
