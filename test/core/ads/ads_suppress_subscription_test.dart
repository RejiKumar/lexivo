import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/ads/ads.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/subscription/domain/entities/subscription_status.dart';
import 'package:lexivo/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:lexivo/features/subscription/presentation/providers/subscription_providers.dart';

class _FakeSubRepo implements SubscriptionRepository {
  _FakeSubRepo(this.status);

  SubscriptionStatus status;

  @override
  Future<Result<SubscriptionStatus>> getMe() async => Success(status);

  @override
  Future<Result<SubscriptionStatus>> upgrade() async => Success(status);
}

SubscriptionStatus _status({required String tier}) => SubscriptionStatus(
      tier: tier,
      paywallEnabled: false,
      documents: const UsageBucket(used: 0, limit: 10, period: 'month'),
      chatMessages: const UsageBucket(used: 0, limit: 50, period: 'month'),
      ocrPages: const UsageBucket(used: 0, limit: 20, period: 'month'),
    );

void main() {
  test('paid tier suppresses ads; free does not', () async {
    final paid = ProviderContainer(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(
          _FakeSubRepo(_status(tier: 'paid')),
        ),
        ...subscriptionCoreOverrides(paywallEnabled: false),
      ],
    );
    addTearDown(paid.dispose);
    await paid.read(subscriptionMeProvider.future);
    expect(paid.read(adsSuppressedProvider), isTrue);

    final free = ProviderContainer(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(
          _FakeSubRepo(_status(tier: 'free')),
        ),
        ...subscriptionCoreOverrides(paywallEnabled: false),
      ],
    );
    addTearDown(free.dispose);
    await free.read(subscriptionMeProvider.future);
    expect(free.read(adsSuppressedProvider), isFalse);
  });
}
