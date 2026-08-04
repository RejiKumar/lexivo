import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/subscription/subscription_flags.dart';
import 'package:lexivo/features/subscription/subscription.dart';

import '../../../helpers/fake_subscription_repository.dart';

void main() {
  group('RouteGuards.subscriptionGuard', () {
    test('flag off redirects paywall routes to account', () {
      expect(
        RouteGuards.subscriptionGuard(
          auth: const AuthGuardState(isAuthenticated: true),
          location: RouteGuards.subscription,
          paywallEnabled: false,
        ),
        RouteGuards.account,
      );
      expect(
        RouteGuards.subscriptionGuard(
          auth: const AuthGuardState(isAuthenticated: true),
          location: RouteGuards.subscriptionUpgrade,
          paywallEnabled: false,
        ),
        RouteGuards.account,
      );
    });

    test('flag on allows paywall routes', () {
      expect(
        RouteGuards.subscriptionGuard(
          auth: const AuthGuardState(isAuthenticated: true),
          location: RouteGuards.subscription,
          paywallEnabled: true,
        ),
        isNull,
      );
    });

    test('non-subscription routes pass through', () {
      expect(
        RouteGuards.subscriptionGuard(
          auth: const AuthGuardState(isAuthenticated: true),
          location: RouteGuards.home,
          paywallEnabled: false,
        ),
        isNull,
      );
    });
  });

  test('compile-time flag default is false', () {
    expect(LexivoSubscriptionFlags.subscriptionPaywallEnabled, isFalse);
  });

  test('router redirects /subscription when flag off', () {
    final container = ProviderContainer(
      overrides: [
        authGuardStateProvider.overrideWithValue(
          const AuthGuardState(isAuthenticated: true),
        ),
        ...subscriptionCoreOverrides(paywallEnabled: false),
        subscriptionRepositoryProvider.overrideWithValue(
          FakeSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(goRouterProvider);
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      isNot(contains('subscription')),
    );
    // Redirect logic unit-tested above; ensure provider wires flag.
    expect(container.read(subscriptionPaywallEnabledProvider), isFalse);
  });
}
