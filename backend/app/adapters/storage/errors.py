"""Storage adapter errors shared by providers."""

from __future__ import annotations


class StorageNotConfiguredError(RuntimeError):
    """Raised when the selected storage provider is missing credentials/bucket."""

    def __init__(self, message: str = "Object storage is not configured") -> None:
        self.message = message
        super().__init__(message)
