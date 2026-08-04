"""Temporary StorageProvider stubs for DI until §4 SDK adapter lands."""


class R2StorageAdapter:
    """Default StorageProvider binding (SDK integration in §4)."""

    async def upload(self, key: str, file: bytes) -> str:
        raise NotImplementedError("R2 storage SDK adapter not implemented yet (§4)")

    async def signed_url(self, key: str) -> str:
        raise NotImplementedError("R2 storage SDK adapter not implemented yet (§4)")
