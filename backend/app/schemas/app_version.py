"""App version-check API schemas (docs/app-versioning.md)."""

from pydantic import BaseModel, Field


class PlatformVersionInfo(BaseModel):
    latest_version: str
    min_supported_version: str
    store_url: str = Field(
        default="",
        description="Play / App Store listing URL (empty until configured)",
    )


class WebVersionInfo(BaseModel):
    latest_version: str
    min_supported_version: str


class AppVersionResponse(BaseModel):
    latest_version: str
    min_supported_version: str
    soft_update_message: str
    force_update_message: str
    android: PlatformVersionInfo
    ios: PlatformVersionInfo
    web: WebVersionInfo
