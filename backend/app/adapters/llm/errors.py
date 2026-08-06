"""LLM adapter errors shared by providers.

Upstream messages are rebuilt here so API keys never reach logs, job rows, or
client responses (vendors echo the key in the request URL).
"""

from __future__ import annotations


class LLMProviderError(RuntimeError):
    """Raised when an LLM provider call fails upstream."""

    def __init__(self, message: str, *, status_code: int | None = None) -> None:
        self.message = message
        self.status_code = status_code
        super().__init__(message)


class LLMRateLimitError(LLMProviderError):
    """Raised when the LLM provider rejects the call with 429 / quota exhausted."""

    def __init__(self, message: str) -> None:
        super().__init__(message, status_code=429)
