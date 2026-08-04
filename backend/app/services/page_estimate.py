"""Estimate OCR page counts before enqueue (lightweight, no heavy PDF libs)."""

from __future__ import annotations

import re


_IMAGE_SUFFIXES = (".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp", ".tif", ".tiff")
_PDF_PAGE_RE = re.compile(rb"/Type\s*/Page(?![sA-Za-z])")


def estimate_page_count(file_bytes: bytes, filename: str | None = None) -> int:
    """Estimate pages for quota checks.

    - Single-image uploads → 1
    - PDFs → count ``/Type /Page`` markers (fallback 1)
    - Unknown → 1
    """
    name = (filename or "").lower()
    if any(name.endswith(suffix) for suffix in _IMAGE_SUFFIXES):
        return 1

    if name.endswith(".pdf") or file_bytes[:5] == b"%PDF-":
        matches = _PDF_PAGE_RE.findall(file_bytes)
        return max(1, len(matches)) if matches else 1

    return 1
