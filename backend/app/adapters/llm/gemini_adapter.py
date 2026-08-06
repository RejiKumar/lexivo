"""Gemini LLM adapter — Google Generative Language API via httpx."""

from __future__ import annotations

import httpx

from app.adapters.llm.errors import LLMProviderError, LLMRateLimitError


class GeminiLLMAdapter:
    """LLMProvider implementation for Google Gemini."""

    def __init__(
        self,
        api_key: str,
        *,
        model: str = "gemini-2.0-flash",
        base_url: str = "https://generativelanguage.googleapis.com/v1beta",
        client: httpx.AsyncClient | None = None,
    ) -> None:
        self._api_key = api_key
        self._model = model
        self._base_url = base_url.rstrip("/")
        self._client = client

    async def complete(self, prompt: str, **kwargs: object) -> str:
        if not self._api_key:
            raise RuntimeError("Gemini API key is not configured")

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
