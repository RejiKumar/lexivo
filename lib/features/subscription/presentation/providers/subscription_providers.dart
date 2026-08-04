import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/subscription/subscription_flags.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:lexivo/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:lexivo/features/subscription/domain/entities/subscription_status.dart';
import 'package:lexivo/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:lexivo/features/subscription/domain/usecases/subscription_usecases.dart';
import 'package:lexivo/features/subscription/presentation/screens/paywall_screen.dart';
import 'package:lexivo/features/subscription/presentation/screens/upgrade_screen.dart';
import 'package:lexivo/features/subscription/presentation/widgets/usage_summary.dart';

export 'package:lexivo/core/routing/app_router.dart'
    show subscriptionPaywallEnabledProvider;

final subscriptionRemoteDatasourceProvider =
    Provider<SubscriptionRemoteDatasource>((ref) {
  return SubscriptionRemoteDatasource(ref.watch(apiClientProvider));
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(
    ref.watch(subscriptionRemoteDatasourceProvider),
  );
});

final getSubscriptionMeUseCaseProvider = Provider((ref) {
  return GetSubscriptionMe(ref.watch(subscriptionRepositoryProvider));
});

final upgradeSubscriptionUseCaseProvider = Provider((ref) {
  return UpgradeSubscription(ref.watch(subscriptionRepositoryProvider));
});

final subscriptionMeProvider =
    AsyncNotifierProvider<SubscriptionMeNotifier, SubscriptionStatus>(
  SubscriptionMeNotifier.new,
);

class SubscriptionMeNotifier extends AsyncNotifier<SubscriptionStatus> {
  Failure? _upgradeFailure;

  Failure? get upgradeFailure => _upgradeFailure;

  @override
  Future<SubscriptionStatus> build() => _load();

  Future<SubscriptionStatus> _load() async {
    final result = await ref.read(getSubscriptionMeUseCaseProvider)();
    return result.when(
      success: (value) => value,
      onFailure: (f) => throw f,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<bool> upgrade() async {
    _upgradeFailure = null;
    final result = await ref.read(upgradeSubscriptionUseCaseProvider)();
    return result.when(
      success: (value) {
        state = AsyncData(value);
        return true;
      },
      onFailure: (f) {
        _upgradeFailure = f;
        return false;
      },
    );
  }
}

final subscriptionScreenBuildersBridgeProvider =
    Provider<SubscriptionScreenBuilders>((ref) {
  return (
    paywall: (context) => const PaywallScreen(),
    upgrade: (context) => const UpgradeScreen(),
    usageSummary: (context) => const UsageSummary(),
  );
});

/// Wire subscription routes + paywall flag into core GoRouter.
List<Override> subscriptionCoreOverrides({bool? paywallEnabled}) => [
      subscriptionPaywallEnabledProvider.overrideWithValue(
        paywallEnabled ??
            LexivoSubscriptionFlags.subscriptionPaywallEnabled,
      ),
      subscriptionScreenBuildersProvider.overrideWith(
        (ref) => ref.watch(subscriptionScreenBuildersBridgeProvider),
      ),
    ];
