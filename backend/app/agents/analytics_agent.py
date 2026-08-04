"""Analytics Agent — emit structured events via AnalyticsProvider.

``run()`` responsibilities (STEP 3.6):
- Accept a structured analytics event (``name``/``event``, ``user_id``, properties).
- Emit via injected ``AnalyticsProvider`` (PostHog-oriented Protocol; stub OK).
- Return ``AgentResult`` with emit acknowledgment.
- Soft-fail on provider exceptions (success=False via on_error; does not call other agents).
- Reject invalid events (missing name) without calling the provider.
"""

from __future__ import annotations

from typing import Any

from app.adapters.protocols import AnalyticsProvider
from app.agents.base_agent import AgentContext, AgentResult, BaseAgent


class AnalyticsAgent(BaseAgent):
    """Specialized Analytics agent. Invoked only via Master Agent node registry."""

    name = "analytics"

    def __init__(self, analytics: AnalyticsProvider) -> None:
        self._analytics = analytics

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        event = input.get("name") or input.get("event")
        if not isinstance(event, str) or not event.strip():
            return AgentResult(
                success=False,
                data={"tracked": False},
                error="Analytics Agent requires non-empty event name",
                metadata={
                    "agent": self.name,
                    "error_type": "ValidationError",
                    "document_id": context.document_id,
                    "job_id": context.job_id,
                },
            )

        user_id = input.get("user_id")
        if user_id is None:
            user_id = context.user_id
        if user_id is not None and not isinstance(user_id, str):
            return await self.on_error(
                ValueError("Analytics user_id must be a string or null"),
                context,
            )

        properties = input.get("properties") or {}
        if not isinstance(properties, dict):
            return await self.on_error(
                ValueError("Analytics properties must be a dict"),
                context,
            )

        props = dict(properties)
        if context.document_id and "document_id" not in props:
            props["document_id"] = context.document_id
        if context.job_id and "job_id" not in props:
            props["job_id"] = context.job_id

        try:
            await self._analytics.track(
                event.strip(),
                user_id=user_id,
                properties=props,
            )
        except Exception as exc:
            # Soft-fail: document failure without raising to callers.
            return await self.on_error(exc, context)

        return AgentResult(
            success=True,
            data={
                "event": event.strip(),
                "tracked": True,
                "user_id": user_id,
                "properties": props,
            },
            metadata={
                "agent": self.name,
                "document_id": context.document_id,
                "job_id": context.job_id,
            },
        )
