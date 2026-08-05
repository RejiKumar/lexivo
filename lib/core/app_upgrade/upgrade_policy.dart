import 'package:flutter/foundation.dart';
import 'package:lexivo/core/app_upgrade/semver.dart';
import 'package:lexivo/core/network/api_models.dart';

/// Result of comparing the installed app version to remote policy.
enum UpgradeKind { ok, soft, force }

/// Platform-resolved policy slice used for SemVer comparison + store action.
@immutable
class PlatformUpgradePolicy {
  const PlatformUpgradePolicy({
    required this.latestVersion,
    required this.minSupportedVersion,
    this.storeUrl = '',
    this.softUpdateMessage = '',
    this.forceUpdateMessage = '',
  });

  final String latestVersion;
  final String minSupportedVersion;
  final String storeUrl;
  final String softUpdateMessage;
  final String forceUpdateMessage;
}

/// Outcome of a version check (UI + store/reload action).
@immutable
class UpgradeDecision {
  const UpgradeDecision({
    required this.kind,
    this.message = '',
    this.storeUrl = '',
    this.isWeb = false,
  });

  const UpgradeDecision.ok()
      : kind = UpgradeKind.ok,
        message = '',
        storeUrl = '',
        isWeb = false;

  final UpgradeKind kind;
  final String message;
  final String storeUrl;

  /// When true, Update should reload the page instead of opening a store URL.
  final bool isWeb;

  bool get needsPrompt => kind == UpgradeKind.soft || kind == UpgradeKind.force;
}

/// Evaluates SemVer policy per docs/app-versioning.md:
/// `current < min` → FORCE; else `current < latest` → SOFT; else OK.
abstract final class UpgradePolicyEvaluator {
  static UpgradeDecision evaluate({
    required String currentVersion,
    required PlatformUpgradePolicy policy,
    bool isWeb = false,
  }) {
    final current = SemVer.tryParse(currentVersion);
    final min = SemVer.tryParse(policy.minSupportedVersion);
    final latest = SemVer.tryParse(policy.latestVersion);

    // Unparseable versions → fail open (do not block the user).
    if (current == null || min == null || latest == null) {
      return const UpgradeDecision.ok();
    }

    if (current < min) {
      return UpgradeDecision(
        kind: UpgradeKind.force,
        message: policy.forceUpdateMessage,
        storeUrl: policy.storeUrl,
        isWeb: isWeb,
      );
    }
    if (current < latest) {
      return UpgradeDecision(
        kind: UpgradeKind.soft,
        message: policy.softUpdateMessage,
        storeUrl: policy.storeUrl,
        isWeb: isWeb,
      );
    }
    return const UpgradeDecision.ok();
  }

  /// Picks android / ios / web blocks from [response], falling back to root.
  static PlatformUpgradePolicy resolvePlatformPolicy(
    AppVersionDto response, {
    required TargetPlatform platform,
    required bool isWeb,
  }) {
    if (isWeb) {
      return PlatformUpgradePolicy(
        latestVersion: response.web.latestVersion,
        minSupportedVersion: response.web.minSupportedVersion,
        softUpdateMessage: response.softUpdateMessage,
        forceUpdateMessage: response.forceUpdateMessage,
      );
    }
    switch (platform) {
      case TargetPlatform.iOS:
        return PlatformUpgradePolicy(
          latestVersion: response.ios.latestVersion,
          minSupportedVersion: response.ios.minSupportedVersion,
          storeUrl: response.ios.storeUrl,
          softUpdateMessage: response.softUpdateMessage,
          forceUpdateMessage: response.forceUpdateMessage,
        );
      case TargetPlatform.android:
        return PlatformUpgradePolicy(
          latestVersion: response.android.latestVersion,
          minSupportedVersion: response.android.minSupportedVersion,
          storeUrl: response.android.storeUrl,
          softUpdateMessage: response.softUpdateMessage,
          forceUpdateMessage: response.forceUpdateMessage,
        );
      default:
        // Desktop / other: use root fields; no store URL.
        return PlatformUpgradePolicy(
          latestVersion: response.latestVersion,
          minSupportedVersion: response.minSupportedVersion,
          softUpdateMessage: response.softUpdateMessage,
          forceUpdateMessage: response.forceUpdateMessage,
        );
    }
  }
}
