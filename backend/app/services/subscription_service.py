"""Subscription domain service — usage status + stub upgrade."""

from __future__ import annotations

from sqlalchemy.orm import Session

from app.core.config import Settings
from app.models import Subscription, SubscriptionTier
from app.repositories.subscription_repo import SubscriptionRepository
from app.services.base import ConflictError
from app.services.quota_service import QuotaService


class SubscriptionService:
    def __init__(self, session: Session, settings: Settings) -> None:
        self._session = session
        self._settings = settings
        self._subscriptions = SubscriptionRepository(session)
        self._quota = QuotaService(session, settings)

    def get_me(self, user_id: str) -> dict[str, object]:
        sub = self._subscriptions.get_or_create_free(user_id)
        return {
            "tier": sub.tier.value,
            "status": sub.status.value,
            "paywall_enabled": self._settings.subscription_paywall_enabled,
            "usage": self._quota.usage_snapshot(user_id),
        }

    def upgrade(self, user_id: str) -> Subscription:
        """Stub upgrade — only when paywall flag is on; no payment provider."""
        if not self._settings.subscription_paywall_enabled:
            raise ConflictError(
                "Subscription upgrade is disabled (paywall feature flag off)"
            )
        sub = self._subscriptions.get_or_create_free(user_id)
        if sub.tier == SubscriptionTier.paid:
            return sub
        updated = self._subscriptions.update(
            sub.id, tier=SubscriptionTier.paid
        )
        assert updated is not None
        return updated
