"""No-op / log-only PushProvider stub (no FCM/APNs SDK)."""

from __future__ import annotations

import logging

logger = logging.getLogger(__name__)


class StubPushProvider:
    """PushProvider adapter that records calls without network I/O."""

    def __init__(self) -> None:
        self.sent: list[dict[str, object]] = []

    async def send(
        self,
        user_id: str,
        title: str,
        body: str,
        **kwargs: object,
    ) -> None:
        record = {"user_id": user_id, "title": title, "body": body, **kwargs}
        self.sent.append(record)
        logger.info("StubPushProvider.send %s", record)
