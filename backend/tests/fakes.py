"""Shared Protocol fakes for unit/API/task tests — no vendor SDKs."""

from __future__ import annotations

import hashlib
import math

from app.adapters.types import OCRResult, UserIdentity

# Deterministic fake embedding dimensionality for RAG unit/integration tests.
FAKE_EMBEDDING_DIM = 32


class FakeAuthProvider:
    """AuthProvider fake — returns a fixed identity for any non-empty token."""

    def __init__(
        self,
        *,
        subject: str = "test-user",
        email: str = "test@example.com",
        display_name: str | None = "Test User",
    ) -> None:
        self.subject = subject
        self.email = email
        self.display_name = display_name
        self.calls: list[str] = []

    async def verify_token(self, token: str) -> UserIdentity:
        self.calls.append(token)
        if not token:
            from app.core.exceptions import AuthenticationError

            raise AuthenticationError("Missing token")
        return UserIdentity(
            subject=self.subject,
            email=self.email,
            display_name=self.display_name,
        )


class FakeStorageProvider:
    """StorageProvider fake with in-memory objects (supports get_object for OCR tasks)."""

    def __init__(self) -> None:
        self.objects: dict[str, bytes] = {}
        self.uploads: list[tuple[str, bytes]] = []

    async def upload(self, key: str, file: bytes) -> str:
        self.objects[key] = file
        self.uploads.append((key, file))
        return key

    async def signed_url(self, key: str) -> str:
        return f"https://signed.test/{key}"

    async def get_object(self, key: str) -> bytes:
        if key not in self.objects:
            raise KeyError(key)
        return self.objects[key]


class FakeLLMProvider:
    def __init__(self, response: str = "fake-llm-response") -> None:
        self.response = response
        self.prompts: list[str] = []

    async def complete(self, prompt: str, **kwargs: object) -> str:
        self.prompts.append(prompt)
        return self.response


class FakeOCRProvider:
    def __init__(
        self,
        *,
        text: str = "extracted text",
        pages: int = 1,
        fail: bool = False,
    ) -> None:
        self.text = text
        self.pages = pages
        self.fail = fail
        self.calls: list[bytes] = []

    async def extract_text(self, file: bytes) -> OCRResult:
        self.calls.append(file)
        if self.fail:
            raise RuntimeError("OCR failed")
        return OCRResult(
            text=self.text,
            pages=self.pages,
            metadata={"provider": "fake"},
        )


class FakeEmbedder:
    """Deterministic hash→vector EmbeddingProvider — no network."""

    def __init__(self, *, dim: int = FAKE_EMBEDDING_DIM) -> None:
        self.dim = dim
        self.calls: list[list[str]] = []

    async def embed(self, texts: list[str]) -> list[list[float]]:
        self.calls.append(list(texts))
        return [self._vector_for(t) for t in texts]

    def _vector_for(self, text: str) -> list[float]:
        digest = hashlib.sha256(text.encode("utf-8")).digest()
        # Expand digest into dim floats in [-1, 1], then L2-normalize.
        raw: list[float] = []
        i = 0
        while len(raw) < self.dim:
            byte = digest[i % len(digest)]
            raw.append((byte / 127.5) - 1.0)
            i += 1
        norm = math.sqrt(sum(x * x for x in raw)) or 1.0
        return [x / norm for x in raw]


class FakePushProvider:
    """PushProvider fake — records send calls; optional failure."""

    def __init__(self, *, fail: bool = False) -> None:
        self.fail = fail
        self.sent: list[dict[str, object]] = []

    async def send(
        self,
        user_id: str,
        title: str,
        body: str,
        **kwargs: object,
    ) -> None:
        if self.fail:
            raise RuntimeError("push failed")
        self.sent.append(
            {"user_id": user_id, "title": title, "body": body, **kwargs}
        )


class FakeNotificationStore:
    """In-app NotificationStore fake — in-memory records."""

    def __init__(self) -> None:
        self.records: list[dict] = []

    async def create_notification(
        self,
        user_id: str,
        type: str,
        payload: dict,
    ) -> dict:
        from datetime import UTC, datetime

        payload_copy = dict(payload)
        record = {
            "id": f"notif-{len(self.records) + 1}",
            "user_id": user_id,
            "type": type,
            "title": str(payload_copy.get("title") or "Lexivo"),
            "body": str(payload_copy.get("body") or ""),
            "payload": payload_copy,
            "read_at": None,
            "created_at": datetime.now(UTC),
        }
        self.records.append(record)
        return record

    async def list_for_user(
        self,
        user_id: str,
        *,
        unread_only: bool = False,
    ) -> list[dict]:
        rows = [r for r in self.records if r["user_id"] == user_id]
        if unread_only:
            rows = [r for r in rows if r.get("read_at") is None]
        return sorted(
            rows,
            key=lambda r: (r.get("created_at") is not None, r.get("created_at"), r["id"]),
            reverse=True,
        )

    async def mark_read(
        self,
        user_id: str,
        notification_id: str,
    ) -> dict | None:
        from datetime import UTC, datetime

        for record in self.records:
            if record["id"] == notification_id and record["user_id"] == user_id:
                if record.get("read_at") is None:
                    record["read_at"] = datetime.now(UTC)
                return dict(record)
        return None


class FakeAnalyticsProvider:
    """AnalyticsProvider fake — records track calls; optional failure."""

    def __init__(self, *, fail: bool = False) -> None:
        self.fail = fail
        self.events: list[dict] = []

    async def track(
        self,
        event: str,
        *,
        user_id: str | None,
        properties: dict,
    ) -> None:
        if self.fail:
            raise RuntimeError("analytics failed")
        self.events.append(
            {"event": event, "user_id": user_id, "properties": dict(properties)}
        )
