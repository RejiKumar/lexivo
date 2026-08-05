import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/app_upgrade/semver.dart';
import 'package:lexivo/core/app_upgrade/upgrade_policy.dart';
import 'package:lexivo/core/network/api_models.dart';

void main() {
  group('SemVer', () {
    test('parses major.minor.patch', () {
      expect(SemVer.parse('1.2.3'), const SemVer(1, 2, 3));
    });

    test('ignores build metadata', () {
      expect(SemVer.parse('1.0.0+42'), const SemVer(1, 0, 0));
      expect(SemVer.parse('2.1.0+1').compareTo(SemVer.parse('2.1.0')), 0);
    });

    test('strips pre-release for policy compare', () {
      expect(SemVer.parse('1.2.0-beta.1'), const SemVer(1, 2, 0));
    });

    test('orders correctly', () {
      expect(SemVer.parse('1.0.0') < SemVer.parse('1.0.1'), isTrue);
      expect(SemVer.parse('1.1.0') > SemVer.parse('1.0.9'), isTrue);
      expect(SemVer.parse('2.0.0') >= SemVer.parse('1.9.9'), isTrue);
    });
  });

  group('UpgradePolicyEvaluator', () {
    const softMsg = 'Soft available';
    const forceMsg = 'Must update';

    PlatformUpgradePolicy policy({
      String latest = '1.2.0',
      String min = '1.0.0',
      String store = 'https://play.google.com/store/apps/details?id=com.lexivo',
    }) {
      return PlatformUpgradePolicy(
        latestVersion: latest,
        minSupportedVersion: min,
        storeUrl: store,
        softUpdateMessage: softMsg,
        forceUpdateMessage: forceMsg,
      );
    }

    test('current below MSV → force', () {
      final d = UpgradePolicyEvaluator.evaluate(
        currentVersion: '0.9.0',
        policy: policy(),
      );
      expect(d.kind, UpgradeKind.force);
      expect(d.message, forceMsg);
      expect(d.storeUrl, isNotEmpty);
    });

    test('current in soft band → soft', () {
      final d = UpgradePolicyEvaluator.evaluate(
        currentVersion: '1.0.0',
        policy: policy(),
      );
      expect(d.kind, UpgradeKind.soft);
      expect(d.message, softMsg);
    });

    test('current equals latest → ok', () {
      final d = UpgradePolicyEvaluator.evaluate(
        currentVersion: '1.2.0',
        policy: policy(),
      );
      expect(d.kind, UpgradeKind.ok);
    });

    test('current above latest → ok', () {
      final d = UpgradePolicyEvaluator.evaluate(
        currentVersion: '1.3.0',
        policy: policy(),
      );
      expect(d.kind, UpgradeKind.ok);
    });

    test('build metadata ignored for policy', () {
      final d = UpgradePolicyEvaluator.evaluate(
        currentVersion: '1.2.0+99',
        policy: policy(latest: '1.2.0', min: '1.0.0'),
      );
      expect(d.kind, UpgradeKind.ok);
    });

    test('unparseable version fails open to ok', () {
      final d = UpgradePolicyEvaluator.evaluate(
        currentVersion: 'not-a-version',
        policy: policy(),
      );
      expect(d.kind, UpgradeKind.ok);
    });

    test('resolvePlatformPolicy picks android block', () {
      final dto = AppVersionDto(
        latestVersion: '1.0.0',
        minSupportedVersion: '1.0.0',
        softUpdateMessage: softMsg,
        forceUpdateMessage: forceMsg,
        android: const PlatformVersionInfoDto(
          latestVersion: '2.0.0',
          minSupportedVersion: '1.5.0',
          storeUrl: 'https://play.example/lexivo',
        ),
        ios: const PlatformVersionInfoDto(
          latestVersion: '3.0.0',
          minSupportedVersion: '2.0.0',
          storeUrl: 'https://apps.example/lexivo',
        ),
        web: const WebVersionInfoDto(
          latestVersion: '4.0.0',
          minSupportedVersion: '3.0.0',
        ),
      );

      final android = UpgradePolicyEvaluator.resolvePlatformPolicy(
        dto,
        platform: TargetPlatform.android,
        isWeb: false,
      );
      expect(android.latestVersion, '2.0.0');
      expect(android.minSupportedVersion, '1.5.0');
      expect(android.storeUrl, 'https://play.example/lexivo');

      final web = UpgradePolicyEvaluator.resolvePlatformPolicy(
        dto,
        platform: TargetPlatform.android,
        isWeb: true,
      );
      expect(web.latestVersion, '4.0.0');
      expect(web.storeUrl, isEmpty);
    });
  });
}
