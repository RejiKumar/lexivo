"""Mistral OCR adapter — Mistral OCR HTTP API via httpx."""

from __future__ import annotations

import base64

import httpx

from app.adapters.types import OCRResult


class MistralOCRAdapter:
    """OCRProvider implementation for Mistral OCR."""

    def __init__(
        self,
        api_key: str,
        *,
        model: str = "mistral-ocr-latest",
        base_url: str = "https://api.mistral.ai/v1",
        client: httpx.AsyncClient | None = None,
    ) -> None:
        self._api_key = api_key
        self._model = model
        self._base_url = base_url.rstrip("/")
        self._client = client

    async def extract_text(self, file: bytes) -> OCRResult:
        if not self._api_key:
            raise RuntimeError("Mistral API key is not configured")

        encoded = base64.b64encode(file).decode("ascii")
        payload = {
            "model": self._model,
            "document": {
                "type": "document_url",
                "document_url": f"data:application/pdf;base64,{encoded}",
            },
        }

        owns_client = self._client is None
        client = self._client or httpx.AsyncClient()
        try:
            response = await client.post(
                f"{self._base_url}/ocr",
                headers={"Authorization": f"Bearer {self._api_key}"},
                json=payload,
                timeout=120.0,
            )
            response.raise_for_status()
            data = response.json()
        finally:
            if owns_client:
                await client.aclose()

        pages_data = data.get("pages") or []
        texts: list[str] = []
        for page in pages_data:
            if isinstance(page, dict) and page.get("markdown"):
                texts.append(str(page["markdown"]))
            elif isinstance(page, dict) and page.get("text"):
                texts.append(str(page["text"]))

        if not texts and data.get("text"):
            texts.append(str(data["text"]))

        text = "\n\n".join(texts)
        pages = len(pages_data) if pages_data else (1 if text else 0)
        return OCRResult(
            text=text,
            pages=pages,
            metadata={"provider": "mistral", "model": self._model},
        )
