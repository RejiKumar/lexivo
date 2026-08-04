import 'package:lexivo/core/network/api_models.dart';
import 'package:lexivo/features/subscription/domain/entities/subscription_status.dart';

UsageBucket usageBucketFromDto(UsageBucketDto dto) => UsageBucket(
      used: dto.used,
      limit: dto.limit,
      period: dto.period,
    );

SubscriptionStatus subscriptionStatusFromDto(SubscriptionMeDto dto) =>
    SubscriptionStatus(
      tier: dto.tier,
      status: dto.status,
      paywallEnabled: dto.paywallEnabled,
      documents: usageBucketFromDto(dto.usage.documents),
      chatMessages: usageBucketFromDto(dto.usage.chatMessages),
      ocrPages: usageBucketFromDto(dto.usage.ocrPages),
    );

SubscriptionStatus subscriptionStatusFromUpgrade(
  SubscriptionUpgradeDto dto, {
  required SubscriptionStatus previous,
}) =>
    previous.copyWith(
      tier: dto.tier,
      status: dto.status,
      paywallEnabled: dto.paywallEnabled,
    );
