"""Security Agent — validate/sanitize agent-bound payloads for a document/job.

``run()`` responsibilities (STEP 3.6):
- Accept ``action`` / ``payload`` (or equivalent) plus AgentContext ids.
- Reject oversized text (default max 100_000 chars).
- Reject empty critical fields when required by action.
- Flag/block simple disallowed content patterns (e.g. ``<script``).
- Enforce a small allow-list of known actions.
- Attach a structured security verdict to ``AgentResult.data``.

Not a full WAF; not Flutter auth UI; deterministic — no LLM in v1.
"""

from __future__ import annotations

from typing import Any

from app.agents.base_agent import AgentContext, AgentResult, BaseAgent

DEFAULT_MAX_TEXT_CHARS = 100_000
ALLOWED_ACTIONS = frozenset(
    {
        "validate_payload",
        "sanitize_text",
        "check_intent",
    }
)
BLOCKED_PATTERNS = (
    "<script",
    "javascript:",
)


class SecurityAgent(BaseAgent):
    """Specialized Security agent. Invoked only via Master Agent node registry."""

    name = "security"

    def __init__(self, *, max_text_chars: int = DEFAULT_MAX_TEXT_CHARS) -> None:
        self._max_text_chars = max_text_chars

    async def run(self, input: dict[str, Any], context: AgentContext) -> AgentResult:
        action = input.get("action") or "validate_payload"
        if not isinstance(action, str) or action not in ALLOWED_ACTIONS:
            return AgentResult(
                success=False,
                data={
                    "allowed": False,
                    "checks": [
                        {
                            "name": "action_allowlist",
                            "passed": False,
                            "reason": f"Unknown or missing action: {action!r}",
                        }
                    ],
                },
                error=f"Security Agent rejected action: {action!r}",
                metadata=_meta(self.name, context),
            )

        payload = input.get("payload")
        if payload is None:
            payload = {k: v for k, v in input.items() if k != "action"}
        if not isinstance(payload, dict):
            return AgentResult(
                success=False,
                data={
                    "allowed": False,
                    "checks": [
                        {
                            "name": "payload_type",
                            "passed": False,
                            "reason": "payload must be a mapping",
                        }
                    ],
                },
                error="Security Agent payload must be a dict",
                metadata=_meta(self.name, context),
            )

        checks: list[dict[str, Any]] = []
        allowed = True

        # Critical fields for validate_payload: non-empty text when provided key exists.
        text = payload.get("text")
        if "text" in payload:
            if not isinstance(text, str) or not text.strip():
                allowed = False
                checks.append(
                    {
                        "name": "non_empty_text",
                        "passed": False,
                        "reason": "text is empty",
                    }
                )
            else:
                checks.append({"name": "non_empty_text", "passed": True})
                if len(text) > self._max_text_chars:
                    allowed = False
                    checks.append(
                        {
                            "name": "max_text_size",
                            "passed": False,
                            "reason": (
                                f"text length {len(text)} exceeds "
                                f"{self._max_text_chars}"
                            ),
                        }
                    )
                else:
                    checks.append({"name": "max_text_size", "passed": True})

                lowered = text.lower()
                blocked = [p for p in BLOCKED_PATTERNS if p in lowered]
                if blocked:
                    allowed = False
                    checks.append(
                        {
                            "name": "blocked_patterns",
                            "passed": False,
                            "reason": f"matched {blocked}",
                        }
                    )
                else:
                    checks.append({"name": "blocked_patterns", "passed": True})
        else:
            checks.append(
                {
                    "name": "payload_present",
                    "passed": True,
                    "reason": "no text field to validate",
                }
            )

        checks.append(
            {
                "name": "context_ids",
                "passed": True,
                "user_id": context.user_id,
                "document_id": context.document_id,
                "job_id": context.job_id,
            }
        )

        return AgentResult(
            success=allowed,
            data={
                "allowed": allowed,
                "checks": checks,
                "action": action,
            },
            error=None if allowed else "Security Agent rejected payload",
            metadata=_meta(self.name, context),
        )


def _meta(agent: str, context: AgentContext) -> dict[str, Any]:
    return {
        "agent": agent,
        "document_id": context.document_id,
        "job_id": context.job_id,
        "user_id": context.user_id,
    }
