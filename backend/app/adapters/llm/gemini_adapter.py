"""Gemini LLM adapter — Google Generative Language API via httpx.

Retries 429s with exponential backoff (tenacity), then optionally falls back
to another ``LLMProvider`` (typically OpenAI) without changing the Protocol.
"""

from __future__ import annotations

import logging

import httpx
from tenacity import (
    AsyncRetrying,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential,
)

from app.adapters.llm.errors import LLMProviderError, LLMRateLimitError
from app.adapters.protocols import LLMProvider

logger = logging.getLogger(__name__)

_PROVIDER_NAME = "gemini"
_MAX_ATTEMPTS = 3


class GeminiLLMAdapter:
    """LLMProvider implementation for Google Gemini."""

    def __init__(
        self,
        api_key: str,
        *,
        model: str = "gemini-2.0-flash",
        base_url: str = "https://generativelanguage.googleapis.com/v1beta",
        client: httpx.AsyncClient | None = None,
        fallback: LLMProvider | None = None,
    ) -> None:
        self._api_key = api_key
        self._model = model
        self._base_url = base_url.rstrip("/")
        self._client = client
        self._fallback = fallback

    async def complete(self, prompt: str, **kwargs: object) -> str:
        if not self._api_key:
            raise RuntimeError("Gemini API key is not configured")

        try:
            async for attempt in AsyncRetrying(
                stop=stop_after_attempt(_MAX_ATTEMPTS),
                wait=wait_exponential(multiplier=1, min=1, max=8),
                retry=retry_if_exception_type(LLMRateLimitError),
                reraise=True,
            ):
                with attempt:
                    text = await self._complete_once(prompt, **kwargs)
                    logger.info(
                        "LLM request served by provider=%s (attempt=%s)",
                        _PROVIDER_NAME,
                        attempt.retry_state.attempt_number,
                    )
                    return text
        except LLMRateLimitError:
            if self._fallback is None:
                raise
            logger.warning(
                "Gemini rate-limited after %s attempts; falling back to openai",
                _MAX_ATTEMPTS,
            )
            text = await self._fallback.complete(prompt, **kwargs)
            logger.info("LLM request served by provider=openai (fallback)")
            return text

        raise LLMProviderError("Gemini complete() exited without a result")

    async def _complete_once(self, prompt: str, **kwargs: object) -> str:
        model = str(kwargs.get("model") or self._model)
        url = f"{self._base_url}/models/{model}:generateContent"
        payload = {
            "contents": [{"parts": [{"text": prompt}]}],
        }

        owns_client = self._client is None
        client = self._client or httpx.AsyncClient()
        try:
            response = await client.post(
                url,
                headers={"x-goog-api-key": self._api_key},
                json=payload,
                timeout=60.0,
            )
            if response.status_code >= 400:
                raise _upstream_error(model, response.status_code)
            data = response.json()
        finally:
            if owns_client:
                await client.aclose()

        try:
            return data["candidates"][0]["content"]["parts"][0]["text"]
        except (KeyError, IndexError, TypeError) as exc:
            raise LLMProviderError("Unexpected Gemini response shape") from exc


def _upstream_error(model: str, status_code: int) -> LLMProviderError:
    if status_code == 429:
        return LLMRateLimitError(
            f"Gemini rate limit / quota exceeded for {model}. Check the "
            "GEMINI_API_KEY quota in Google AI Studio, or retry later."
        )
    if status_code in {401, 403}:
        return LLMProviderError(
            "Gemini rejected the API key (HTTP "
            f"{status_code}). Verify GEMINI_API_KEY in backend/.env.",
            status_code=status_code,
        )
    return LLMProviderError(
        f"Gemini request for {model} failed with HTTP {status_code}.",
        status_code=status_code,
    )
