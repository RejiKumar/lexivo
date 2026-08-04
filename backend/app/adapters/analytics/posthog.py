"""PostHog AnalyticsProvider adapter — SDK confined to this module."""

from __future__ import annotations

import logging
from typing import Any

logger = logging.getLogger(__name__)


class PostHogAnalyticsProvider:
    """Thin PostHog adapter. Soft-fails emit on SDK/network errors."""

    def __init__(
        self,
        *,
        api_key: str,
        host: str = "",
        client: Any | None = None,
    ) -> None:
        self._api_key = api_key
        self._host = host.strip() or "https://us.i.posthog.com"
        if client is not None:
            self._client = client
        else:
            from posthog import Posthog

            self._client = Posthog(api_key, host=self._host)

    async def track(
        self,
        event: str,
        *,
        user_id: str | None,
        properties: dict[str, Any],
    ) -> None:
        distinct_id = user_id or "anonymous"
        try:
            self._client.capture(
                distinct_id=distinct_id,
                event=event,
                properties=dict(properties),
            )
        except Exception:
            logger.exception("PostHogAnalyticsProvider.track failed for %s", event)
