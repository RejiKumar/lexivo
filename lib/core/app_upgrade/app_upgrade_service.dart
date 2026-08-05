import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/app_upgrade/upgrade_policy.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Fetches remote version policy, resolves platform slice, evaluates SemVer.
///
/// **Fail-open:** network / parse failures return [UpgradeDecision.ok] so the
/// user is not hard-blocked (docs/app-versioning.md).
class AppUpgradeService {
  AppUpgradeService({
    required this.apiClient,
    required this.packageInfoLoader,
    TargetPlatform? platform,
    bool? isWeb,
  })  : platform = platform ?? defaultTargetPlatform,
        isWeb = isWeb ?? kIsWeb;

  final ApiClient apiClient;
  final Future<PackageInfo> Function() packageInfoLoader;
  final TargetPlatform platform;
  final bool isWeb;

  Future<UpgradeDecision> check() async {
    final result = await apiClient.getAppVersion();
    final dto = result.valueOrNull;
    if (dto == null) {
      return const UpgradeDecision.ok();
    }

    final info = await packageInfoLoader();
    final policy = UpgradePolicyEvaluator.resolvePlatformPolicy(
      dto,
      platform: platform,
      isWeb: isWeb,
    );
    return UpgradePolicyEvaluator.evaluate(
      currentVersion: info.version,
      policy: policy,
      isWeb: isWeb,
    );
  }
}

final appUpgradeServiceProvider = Provider<AppUpgradeService>((ref) {
  return AppUpgradeService(
    apiClient: ref.watch(apiClientProvider),
    packageInfoLoader: PackageInfo.fromPlatform,
  );
});
