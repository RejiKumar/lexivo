import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/subscription/subscription_flags.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/subscription/domain/usecases/subscription_usecases.dart';
import 'package:lexivo/features/subscription/subscription.dart';

import '../../helpers/fake_subscription_repository.dart';

void main() {
  test('barrel exports subscription screens and providers', () {
    expect(PaywallScreen, isNotNull);
    expect(UpgradeScreen, isNotNull);
    expect(UsageSummary, isNotNull);
    expect(subscriptionMeProvider, isNotNull);
    expect(subscriptionCoreOverrides, isNotNull);
  });

  test('subscription paywall flag defaults to false', () {
    expect(LexivoSubscriptionFlags.subscriptionPaywallEnabled, isFalse);
  });

  group('usecases', () {
    test('GetSubscriptionMe success', () async {
      final repo = FakeSubscriptionRepository();
      final result = await GetSubscriptionMe(repo)();
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.tier, 'free');
    });

    test('GetSubscriptionMe failure', () async {
      final repo = FakeSubscriptionRepository()
        ..nextGetMeFailure = const NetworkFailure(message: 'down');
      final result = await GetSubscriptionMe(repo)();
      expect(result.isFailure, isTrue);
    });

    test('UpgradeSubscription sets paid', () async {
      final repo = FakeSubscriptionRepository();
      final result = await UpgradeSubscription(repo)();
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.isPaid, isTrue);
    });

    test('UpgradeSubscription surfaces flag-off failure', () async {
      final repo = FakeSubscriptionRepository()
        ..nextUpgradeFailure = const UnauthorizedFailure(
          message: 'Subscription upgrade is disabled',
        );
      final result = await UpgradeSubscription(repo)();
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
    });
  });
}
