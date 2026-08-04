"""Subscription / usage API schemas."""

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

TierLiteral = Literal["free", "paid"]
StatusLiteral = Literal["active", "canceled"]
PeriodLiteral = Literal["month", "day"]


class UsageBucketResponse(BaseModel):
    used: int
    limit: int
    period: PeriodLiteral


class UsageBreakdownResponse(BaseModel):
    documents: UsageBucketResponse
    chat_messages: UsageBucketResponse
    ocr_pages: UsageBucketResponse


class SubscriptionMeResponse(BaseModel):
    tier: TierLiteral
    status: StatusLiteral = "active"
    paywall_enabled: bool
    usage: UsageBreakdownResponse


class SubscriptionUpgradeResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    tier: TierLiteral
    status: StatusLiteral
    paywall_enabled: bool = Field(
        description="Mirrors Settings.subscription_paywall_enabled"
    )


class QuotaExceededDetail(BaseModel):
    """OpenAPI component for consistent 429 quota bodies."""

    code: Literal["quota_exceeded"] = "quota_exceeded"
    resource: Literal["documents", "chat_messages", "ocr_pages"]
    limit: int
    period: PeriodLiteral
    message: str
