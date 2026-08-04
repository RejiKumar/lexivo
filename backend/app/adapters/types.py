"""Shared adapter result/identity types — no vendor SDK imports."""

from dataclasses import dataclass, field


@dataclass(frozen=True, slots=True)
class UserIdentity:
    """Verified identity returned by AuthProvider.verify_token."""

    subject: str
    email: str | None = None
    display_name: str | None = None
    claims: dict = field(default_factory=dict)


@dataclass(frozen=True, slots=True)
class OCRResult:
    """Structured OCR extraction result from OCRProvider.extract_text."""

    text: str
    pages: int = 1
    metadata: dict = field(default_factory=dict)
