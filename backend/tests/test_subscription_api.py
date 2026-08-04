"""API tests for subscriptions + quota enforcement on create/chat/OCR."""

from __future__ import annotations

from datetime import UTC, datetime

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.core.config import Settings
from app.models import (
    Document,
    DocumentStatus,
    Subscription,
    SubscriptionStatus,
    SubscriptionTier,
    User,
)
from app.repositories.document_repo import DocumentRepository
from app.repositories.user_repo import UserRepository
from app.services.base import QuotaExceededError
from app.services.quota_service import QuotaService
from tests.conftest import make_auth_header


def _assert_quota_shape(body: dict, *, resource: str, period: str) -> None:
    detail = body["detail"]
    assert detail["code"] == "quota_exceeded"
    assert detail["resource"] == resource
    assert detail["period"] == period
    assert isinstance(detail["limit"], int)
    assert isinstance(detail["message"], str)


def test_exception_handler_quota_shape(api_client: TestClient) -> None:
    from app.main import create_app

    app = create_app()

    @app.get("/_test/quota")
    def _boom() -> None:
        raise QuotaExceededError(
            resource="documents",
            limit=20,
            period="month",
            message="cap hit",
        )

    client = TestClient(app)
    res = client.get("/_test/quota")
    assert res.status_code == 429
    _assert_quota_shape(res.json(), resource="documents", period="month")


def test_get_subscription_me(
    api_client: TestClient, test_settings: Settings
) -> None:
    headers = make_auth_header(sub="sub-me", email="me@example.com")
    res = api_client.get("/api/v1/subscriptions/me", headers=headers)
    assert res.status_code == 200
    data = res.json()
    assert data["tier"] == "free"
    assert data["paywall_enabled"] is False
    assert data["usage"]["documents"]["limit"] == 20
    assert data["usage"]["chat_messages"]["limit"] == 100
    assert data["usage"]["ocr_pages"]["limit"] == 500
    assert data["usage"]["documents"]["period"] == "month"
    assert data["usage"]["chat_messages"]["period"] == "day"


def test_upgrade_disabled_when_flag_off(api_client: TestClient) -> None:
    headers = make_auth_header(sub="sub-up-off", email="upoff@example.com")
    res = api_client.post("/api/v1/subscriptions/upgrade", headers=headers)
    assert res.status_code == 403
    me = api_client.get("/api/v1/subscriptions/me", headers=headers)
    assert me.json()["tier"] == "free"


def test_upgrade_stub_when_flag_on(
    api_client: TestClient,
    test_settings: Settings,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(test_settings, "subscription_paywall_enabled", True)
    headers = make_auth_header(sub="sub-up-on", email="upon@example.com")
    res = api_client.post("/api/v1/subscriptions/upgrade", headers=headers)
    assert res.status_code == 200
    assert res.json()["tier"] == "paid"
    me = api_client.get("/api/v1/subscriptions/me", headers=headers)
    assert me.json()["tier"] == "paid"


def test_document_create_over_cap_returns_429(
    api_client: TestClient,
    test_settings: Settings,
    monkeypatch: pytest.MonkeyPatch,
    db_session: Session,
) -> None:
    monkeypatch.setattr(test_settings, "free_tier_docs_per_month", 1)
    headers = make_auth_header(sub="sub-doc-cap", email="doccap@example.com")
    # First create OK
    r1 = api_client.post(
        "/api/v1/documents",
        headers=headers,
        files={"file": ("a.png", b"\x89PNG\r\n", "image/png")},
        data={"title": "one"},
    )
    assert r1.status_code == 201
    r2 = api_client.post(
        "/api/v1/documents",
        headers=headers,
        files={"file": ("b.png", b"\x89PNG\r\n", "image/png")},
        data={"title": "two"},
    )
    assert r2.status_code == 429
    _assert_quota_shape(r2.json(), resource="documents", period="month")


def test_openapi_includes_subscriptions(api_client: TestClient) -> None:
    schema = api_client.get("/openapi.json").json()
    paths = schema["paths"]
    assert "/api/v1/subscriptions/me" in paths
    assert "/api/v1/subscriptions/upgrade" in paths
    components = schema.get("components", {}).get("schemas", {})
    assert "QuotaExceededDetail" in components or "SubscriptionMeResponse" in components
