"""Public app version-check for soft / force upgrades."""

from fastapi import APIRouter, Depends

from app.core.config import Settings, get_settings
from app.schemas.app_version import (
    AppVersionResponse,
    PlatformVersionInfo,
    WebVersionInfo,
)

router = APIRouter(prefix="/app", tags=["app"])


def _or_global(override: str, fallback: str) -> str:
    return override.strip() or fallback


@router.get("/version", response_model=AppVersionResponse)
async def get_app_version(
    settings: Settings = Depends(get_settings),
) -> AppVersionResponse:
    latest = settings.latest_app_version
    minimum = settings.min_supported_app_version
    return AppVersionResponse(
        latest_version=latest,
        min_supported_version=minimum,
        soft_update_message=settings.soft_update_message,
        force_update_message=settings.force_update_message,
        android=PlatformVersionInfo(
            latest_version=_or_global(settings.android_latest_app_version, latest),
            min_supported_version=_or_global(
                settings.android_min_supported_app_version, minimum
            ),
            store_url=settings.android_store_url.strip(),
        ),
        ios=PlatformVersionInfo(
            latest_version=_or_global(settings.ios_latest_app_version, latest),
            min_supported_version=_or_global(
                settings.ios_min_supported_app_version, minimum
            ),
            store_url=settings.ios_store_url.strip(),
        ),
        web=WebVersionInfo(
            latest_version=_or_global(settings.web_latest_app_version, latest),
            min_supported_version=_or_global(
                settings.web_min_supported_app_version, minimum
            ),
        ),
    )
