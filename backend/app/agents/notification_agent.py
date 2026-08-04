"""Notification Agent — in-app + push via Protocol stubs (no email in v1).

Invoked only via Master Agent node registry.
"""

from __future__ import annotations

from typing import Any

from app.adapters.protocols import NotificationStore, PushProvider
from app.agents.base_agent import AgentContext, AgentResult, BaseAgent


class NotificationAgent(BaseAgent):
    """Specialized Notification agent. Invoked only via Master Agent node registry."""

    name = "notification"

    def __init__(
        self,
        store: NotificationStore,
        push: PushProvider,
    ) -> None:
        self._store = store
        self._push = push

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        user_id = input.get("user_id") or context.user_id
        if not isinstance(user_id, str) or not user_id.strip():
            return await self.on_error(
                ValueError("Notification Agent requires user_id"),
                context,
            )

        event_type = input.get("event_type") or input.get("job_type")
        if not isinstance(event_type, str) or not event_type.strip():
            return await self.on_error(
                ValueError("Notification Agent requires event_type or job_type"),
                context,
            )

        title = input.get("title") or "Lexivo"
        body = input.get("body") or input.get("message") or ""
        if not isinstance(title, str) or not isinstance(body, str):
            return await self.on_error(
                ValueError("Notification title/body must be strings"),
                context,
            )

        push_enabled = bool(input.get("push_enabled", True))
        notif_type = str(input.get("type") or event_type)

        payload = {
            "event_type": event_type,
            "title": title,
            "body": body,
            "document_id": input.get("document_id") or context.document_id,
            "job_id": input.get("job_id") or context.job_id,
            **(
                dict(input["payload"])
                if isinstance(input.get("payload"), dict)
                else {}
            ),
        }

        # Explicit: never send email in v1.
        if input.get("email") or input.get("send_email"):
            return await self.on_error(
                ValueError("Email delivery is not supported in v1 notifications"),
                context,
            )

        try:
            record = await self._store.create_notification(
                user_id.strip(),
                notif_type,
                payload,
            )
        except Exception as exc:
            return await self.on_error(exc, context)

        push_sent = False
        push_error: str | None = None
        if push_enabled:
            try:
                await self._push.send(
                    user_id.strip(),
                    title,
                    body,
                    event_type=event_type,
                )
                push_sent = True
            except Exception as exc:
                # Soft-fail push: in-app succeeded; surface partial success.
                push_error = str(exc)

        return AgentResult(
            success=True,
            data={
                "notification": record,
                "in_app": True,
                "push_sent": push_sent,
                "push_enabled": push_enabled,
                "push_error": push_error,
                "email_sent": False,
            },
            metadata={
                "agent": self.name,
                "document_id": context.document_id,
                "job_id": context.job_id,
                "user_id": user_id,
            },
        )
