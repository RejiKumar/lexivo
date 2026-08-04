"""External provider adapters."""

from app.adapters.protocols import (
    AuthProvider,
    LLMProvider,
    OCRProvider,
    StorageProvider,
)
from app.adapters.types import OCRResult, UserIdentity

__all__ = [
    "AuthProvider",
    "LLMProvider",
    "OCRProvider",
    "StorageProvider",
    "OCRResult",
    "UserIdentity",
]
