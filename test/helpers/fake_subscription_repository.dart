import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/subscription/domain/entities/subscription_status.dart';
import 'package:lexivo/features/subscription/domain/repositories/subscription_repository.dart';

class FakeSubscriptionRepository implements SubscriptionRepository {
  FakeSubscriptionRepository({SubscriptionStatus? initial})
      : status = initial ?? sampleSubscriptionStatus();

  SubscriptionStatus status;
  Failure? nextGetMeFailure;
  Failure? nextUpgradeFailure;
  var getMeCalls = 0;
  var upgradeCalls = 0;

  @override
  Future<Result<SubscriptionStatus>> getMe() async {
    getMeCalls++;
    if (nextGetMeFailure != null) {
      final f = nextGetMeFailure!;
      nextGetMeFailure = null;
      return Result.failure(f);
    }
    return Result.success(status);
  }

  @override
  Future<Result<SubscriptionStatus>> upgrade() async {
    upgradeCalls++;
    if (nextUpgradeFailure != null) {
      final f = nextUpgradeFailure!;
      nextUpgradeFailure = null;
      return Result.failure(f);
    }
    status = status.copyWith(tier: 'paid', paywallEnabled: true);
    return Result.success(status);
  }
}

SubscriptionStatus sampleSubscriptionStatus({
  String tier = 'free',
  bool paywallEnabled = false,
  int docsUsed = 5,
  int docsLimit = 20,
  int chatUsed = 10,
  int chatLimit = 100,
  int ocrUsed = 50,
  int ocrLimit = 500,
}) {
  return SubscriptionStatus(
    tier: tier,
    paywallEnabled: paywallEnabled,
    documents: UsageBucket(used: docsUsed, limit: docsLimit, period: 'month'),
    chatMessages:
        UsageBucket(used: chatUsed, limit: chatLimit, period: 'day'),
    ocrPages: UsageBucket(used: ocrUsed, limit: ocrLimit, period: 'month'),
  );
}
