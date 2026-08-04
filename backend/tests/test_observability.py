"""Observability Settings + Sentry/PostHog wiring tests."""

from __future__ import annotations

from pathlib import Path

import pytest

from app.adapters.analytics.posthog import PostHogAnalyticsProvider
from app.adapters.analytics.stub import StubAnalyticsProvider
from app.core.config import Settings, get_settings
from app.core.observability import init_sentry, set_sentry_init_for_tests
from app.core.provider_factory import build_analytics_provider


@pytest.fixture(autouse=True)
def _clear_settings_and_sentry() -> None:
    get_settings.cache_clear()
    set_sentry_init_for_tests(None)
    yield
    get_settings.cache_clear()
    set_sentry_init_for_tests(None)


def test_app_env_and_observability_defaults() -> None:
    settings = Settings()
    assert settings.app_env == "local"
    assert settings.sentry_dsn == ""
    assert settings.posthog_api_key == ""
    assert settings.posthog_host == ""


def test_observability_env_overrides(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("APP_ENV", "staging")
    monkeypatch.setenv("SENTRY_DSN", "https://example.ingest.sentry.io/1")
    monkeypatch.setenv("POSTHOG_API_KEY", "phc_test")
    monkeypatch.setenv("POSTHOG_HOST", "https://eu.i.posthog.com")

    settings = Settings()
    assert settings.app_env == "staging"
    assert settings.sentry_dsn.startswith("https://")
    assert settings.posthog_api_key == "phc_test"
    assert settings.posthog_host == "https://eu.i.posthog.com"


def test_sentry_skipped_when_dsn_empty() -> None:
    calls: list[dict] = []
    set_sentry_init_for_tests(lambda **kwargs: calls.append(kwargs))
    assert init_sentry(Settings(sentry_dsn="")) is False
    assert calls == []


def test_sentry_init_when_dsn_set() -> None:
    calls: list[dict] = []
    set_sentry_init_for_tests(lambda **kwargs: calls.append(kwargs))
    assert init_sentry(Settings(sentry_dsn="https://example.ingest.sentry.io/1", app_env="production")) is True
    assert len(calls) == 1
    assert calls[0]["dsn"].startswith("https://")
    assert calls[0]["environment"] == "production"


def test_analytics_stub_when_posthog_key_empty() -> None:
    provider = build_analytics_provider(Settings(posthog_api_key=""))
    assert isinstance(provider, StubAnalyticsProvider)


def test_analytics_posthog_when_key_set() -> None:
    class _FakeClient:
        def __init__(self) -> None:
            self.events: list[dict] = []

        def capture(self, *, distinct_id: str, event: str, properties: dict) -> None:
            self.events.append(
                {"distinct_id": distinct_id, "event": event, "properties": properties}
            )

    fake = _FakeClient()
    provider = PostHogAnalyticsProvider(api_key="phc_test", client=fake)
    assert isinstance(provider, PostHogAnalyticsProvider)


@pytest.mark.asyncio
async def test_posthog_adapter_soft_fails_emit() -> None:
    class _Boom:
        def capture(self, **_kwargs: object) -> None:
            raise RuntimeError("network")

    provider = PostHogAnalyticsProvider(api_key="phc_test", client=_Boom())
    # Must not raise
    await provider.track("evt", user_id="u1", properties={"a": 1})


@pytest.mark.asyncio
async def test_posthog_adapter_captures() -> None:
    class _FakeClient:
        def __init__(self) -> None:
            self.events: list[dict] = []

        def capture(self, *, distinct_id: str, event: str, properties: dict) -> None:
            self.events.append(
                {"distinct_id": distinct_id, "event": event, "properties": properties}
            )

    fake = _FakeClient()
    provider = PostHogAnalyticsProvider(api_key="phc_test", client=fake)
    await provider.track("opened", user_id="u1", properties={"doc": "d1"})
    assert fake.events[0]["event"] == "opened"
    assert fake.events[0]["distinct_id"] == "u1"


def test_agents_do_not_import_posthog_sdk() -> None:
    agents_dir = Path(__file__).resolve().parents[1] / "app" / "agents"
    for path in agents_dir.glob("*.py"):
        text = path.read_text(encoding="utf-8")
        assert "from posthog" not in text
        assert "import posthog" not in text
        assert "sentry_sdk" not in text
