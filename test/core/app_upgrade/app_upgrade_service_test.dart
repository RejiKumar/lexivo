import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lexivo/core/app_upgrade/app_upgrade_service.dart';
import 'package:lexivo/core/app_upgrade/upgrade_policy.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helpers/test_harness.dart';

void main() {
  PackageInfo packageInfo(String version) {
    return PackageInfo(
      appName: 'Lexivo',
      packageName: 'com.lexivo.lexivo',
      version: version,
      buildNumber: '1',
    );
  }

  Map<String, dynamic> versionJson({
    String latest = '2.0.0',
    String min = '1.5.0',
  }) {
    return {
      'latest_version': latest,
      'min_supported_version': min,
      'soft_update_message': 'Soft',
      'force_update_message': 'Force',
      'android': {
        'latest_version': latest,
        'min_supported_version': min,
        'store_url': 'https://play.example/lexivo',
      },
      'ios': {
        'latest_version': latest,
        'min_supported_version': min,
        'store_url': 'https://apps.example/lexivo',
      },
      'web': {
        'latest_version': latest,
        'min_supported_version': min,
      },
    };
  }

  group('AppUpgradeService', () {
    test('maps remote policy to soft/force/ok', () async {
      final dio = createTestDio();
      final adapter = DioAdapter(dio: dio);
      adapter.onGet(
        '/api/v1/app/version',
        (server) => server.reply(200, versionJson()),
      );
      final client = ApiClient(dio);

      Future<UpgradeDecision> check(String current) {
        return AppUpgradeService(
          apiClient: client,
          packageInfoLoader: () async => packageInfo(current),
          platform: TargetPlatform.android,
          isWeb: false,
        ).check();
      }

      expect((await check('1.0.0')).kind, UpgradeKind.force);
      expect((await check('1.6.0')).kind, UpgradeKind.soft);
      expect((await check('2.0.0')).kind, UpgradeKind.ok);
    });

    test('network failure fails open to OK', () async {
      final dio = createTestDio();
      final adapter = DioAdapter(dio: dio);
      adapter.onGet(
        '/api/v1/app/version',
        (server) => server.reply(500, {'detail': 'boom'}),
      );
      final service = AppUpgradeService(
        apiClient: ApiClient(dio),
        packageInfoLoader: () async => packageInfo('1.0.0'),
        platform: TargetPlatform.android,
        isWeb: false,
      );

      final decision = await service.check();
      expect(decision.kind, UpgradeKind.ok);
    });

    test('connection error fails open to OK', () async {
      final dio = createTestDio();
      final adapter = DioAdapter(dio: dio);
      adapter.onGet(
        '/api/v1/app/version',
        (server) => server.throws(
          0,
          DioException(
            requestOptions: RequestOptions(path: '/api/v1/app/version'),
            type: DioExceptionType.connectionError,
          ),
        ),
      );
      final service = AppUpgradeService(
        apiClient: ApiClient(dio),
        packageInfoLoader: () async => packageInfo('0.1.0'),
        platform: TargetPlatform.android,
        isWeb: false,
      );

      final decision = await service.check();
      expect(decision.kind, UpgradeKind.ok);
    });
  });

  group('ApiClient.getAppVersion', () {
    test('parses AppVersionDto', () async {
      final dio = createTestDio();
      final adapter = DioAdapter(dio: dio);
      adapter.onGet(
        '/api/v1/app/version',
        (server) => server.reply(200, versionJson()),
      );
      final result = await ApiClient(dio).getAppVersion();
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.latestVersion, '2.0.0');
      expect(result.valueOrNull!.android.storeUrl, contains('play.example'));
    });
  });
}
