import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/subscription/data/models/subscription_mappers.dart';
import 'package:lexivo/features/subscription/domain/entities/subscription_status.dart';

/// Remote subscription — [ApiClient] only (no Dio imports).
class SubscriptionRemoteDatasource {
  SubscriptionRemoteDatasource(this._api);

  final ApiClient _api;

  Future<Result<SubscriptionStatus>> getMe() async {
    final result = await _api.getSubscriptionMe();
    return result.map(subscriptionStatusFromDto);
  }

  Future<Result<SubscriptionStatus>> upgrade({
    SubscriptionStatus? previous,
  }) async {
    final result = await _api.upgradeSubscription();
    return result.map((dto) {
      final base = previous ??
          SubscriptionStatus(
            tier: dto.tier,
            status: dto.status,
            paywallEnabled: dto.paywallEnabled,
            documents: const UsageBucket(used: 0, limit: 0, period: 'month'),
            chatMessages: const UsageBucket(used: 0, limit: 0, period: 'day'),
            ocrPages: const UsageBucket(used: 0, limit: 0, period: 'month'),
          );
      return subscriptionStatusFromUpgrade(dto, previous: base);
    });
  }
}
