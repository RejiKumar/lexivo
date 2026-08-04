import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:lexivo/features/subscription/presentation/screens/paywall_screen.dart';
import 'package:lexivo/features/subscription/presentation/screens/upgrade_screen.dart';
import 'package:lexivo/features/subscription/presentation/widgets/usage_summary.dart';
import 'package:lexivo/features/subscription/subscription.dart';

import 'fake_subscription_repository.dart';

ProviderContainer createSubscriptionContainer({
  FakeSubscriptionRepository? repository,
  bool paywallEnabled = false,
  List<Override> overrides = const [],
}) {
  final repo = repository ?? FakeSubscriptionRepository();
  return ProviderContainer(
    overrides: [
      subscriptionRepositoryProvider.overrideWithValue(repo),
      ...subscriptionCoreOverrides(paywallEnabled: paywallEnabled),
      ...overrides,
    ],
  );
}

Widget wrapSubscriptionScreen(
  Widget child, {
  FakeSubscriptionRepository? repository,
  bool paywallEnabled = false,
  List<Override> overrides = const [],
}) {
  final container = createSubscriptionContainer(
    repository: repository,
    paywallEnabled: paywallEnabled,
    overrides: overrides,
  );
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.light,
      home: child,
    ),
  );
}

Widget wrapPaywallScreen({
  FakeSubscriptionRepository? repository,
  bool paywallEnabled = true,
}) {
  final repo = repository ?? FakeSubscriptionRepository();
  final router = GoRouter(
    initialLocation: RouteGuards.subscription,
    routes: [
      GoRoute(
        path: RouteGuards.subscription,
        builder: (_, __) => const PaywallScreen(),
        routes: [
          GoRoute(
            path: 'upgrade',
            builder: (_, __) => const UpgradeScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteGuards.account,
        builder: (_, __) => const Scaffold(body: Text('Account')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      subscriptionRepositoryProvider.overrideWithValue(repo),
      ...subscriptionCoreOverrides(paywallEnabled: paywallEnabled),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

Widget wrapUpgradeScreen({
  FakeSubscriptionRepository? repository,
  bool paywallEnabled = true,
}) {
  final repo = repository ?? FakeSubscriptionRepository();
  final router = GoRouter(
    initialLocation: RouteGuards.subscriptionUpgrade,
    routes: [
      GoRoute(
        path: RouteGuards.subscription,
        builder: (_, __) => const PaywallScreen(),
        routes: [
          GoRoute(
            path: 'upgrade',
            builder: (_, __) => const UpgradeScreen(),
          ),
        ],
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      subscriptionRepositoryProvider.overrideWithValue(repo),
      ...subscriptionCoreOverrides(paywallEnabled: paywallEnabled),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

Widget wrapUsageSummary({
  FakeSubscriptionRepository? repository,
  bool paywallEnabled = false,
}) =>
    wrapSubscriptionScreen(
      const Scaffold(body: UsageSummary()),
      repository: repository,
      paywallEnabled: paywallEnabled,
    );
