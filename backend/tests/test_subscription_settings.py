"""Settings defaults + env overrides for subscription / free-tier caps."""

import pytest

from app.core.config import Settings, get_settings


@pytest.fixture(autouse=True)
def _clear_settings_cache() -> None:
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


def test_subscription_settings_defaults(monkeypatch: pytest.MonkeyPatch) -> None:
    for key in (
        "SUBSCRIPTION_PAYWALL_ENABLED",
        "FREE_TIER_DOCS_PER_MONTH",
        "FREE_TIER_CHAT_MESSAGES_PER_DAY",
        "FREE_TIER_OCR_PAGES_PER_MONTH",
    ):
        monkeypatch.delenv(key, raising=False)

    settings = Settings()

    assert settings.subscription_paywall_enabled is False
    assert settings.free_tier_docs_per_month == 20
    assert settings.free_tier_chat_messages_per_day == 100
    assert settings.free_tier_ocr_pages_per_month == 500


def test_subscription_settings_env_overrides(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("SUBSCRIPTION_PAYWALL_ENABLED", "true")
    monkeypatch.setenv("FREE_TIER_DOCS_PER_MONTH", "5")
    monkeypatch.setenv("FREE_TIER_CHAT_MESSAGES_PER_DAY", "10")
    monkeypatch.setenv("FREE_TIER_OCR_PAGES_PER_MONTH", "50")

    settings = Settings()

    assert settings.subscription_paywall_enabled is True
    assert settings.free_tier_docs_per_month == 5
    assert settings.free_tier_chat_messages_per_day == 10
    assert settings.free_tier_ocr_pages_per_month == 50
