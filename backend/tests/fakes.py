"""Shared Protocol fakes for unit/API/task tests — no vendor SDKs."""

from __future__ import annotations

from app.adapters.types import OCRResult, UserIdentity


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
