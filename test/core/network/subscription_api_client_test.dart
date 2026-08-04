import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/network/api_models.dart';
import 'package:lexivo/core/network/error_mapper.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_harness.dart';

void main() {
  group('Subscription DTOs + ApiClient', () {
    test('SubscriptionMeDto parses free usage buckets', () {
      final json = readFixtureSync('subscription_me_free.json');
      final dto = SubscriptionMeDto.fromJson(json);
      expect(dto.tier, 'free');
      expect(dto.paywallEnabled, isFalse);
      expect(dto.usage.documents.limit, 20);
      expect(dto.usage.chatMessages.limit, 100);
      expect(dto.usage.ocrPages.limit, 500);
    });

    test('getSubscriptionMe via ApiClient', () async {
      final dio = createTestDio();
      final adapter = DioAdapter(dio: dio);
      adapter.onGet(
        '/api/v1/subscriptions/me',
        (server) => server.reply(200, readFixtureSync('subscription_me_free.json')),
      );
      final client = ApiClient(dio);
      final result = await client.getSubscriptionMe();
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.tier, 'free');
    });

    test('upgradeSubscription parses paid stub', () async {
      final dio = createTestDio();
      final adapter = DioAdapter(dio: dio);
      adapter.onPost(
        '/api/v1/subscriptions/upgrade',
        (server) => server.reply(200, readFixtureSync('upgrade_success.json')),
      );
      final client = ApiClient(dio);
      final result = await client.upgradeSubscription();
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.tier, 'paid');
    });

    test('upgrade disabled 403 → UnauthorizedFailure', () async {
      final dio = createTestDio();
      final adapter = DioAdapter(dio: dio);
      adapter.onPost(
        '/api/v1/subscriptions/upgrade',
        (server) => server.reply(403, readFixtureSync('upgrade_disabled.json')),
      );
      final client = ApiClient(dio);
      final result = await client.upgradeSubscription();
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
    });
  });

  group('ErrorMapper quota', () {
    test('429 quota_exceeded → QuotaFailure', () {
      final body = readFixtureSync('quota_exceeded_documents.json');
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/v1/documents'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/documents'),
          statusCode: 429,
          data: body,
        ),
      );
      final failure = ErrorMapper.map(err);
      expect(failure, isA<QuotaFailure>());
      final quota = failure as QuotaFailure;
      expect(quota.resource, 'documents');
      expect(quota.limit, 20);
      expect(quota.period, 'month');
      expect(quota.message, contains('20'));
    });

    test('429 without quota code → NetworkFailure', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 429,
          data: {'detail': 'slow down'},
        ),
      );
      expect(ErrorMapper.map(err), isA<NetworkFailure>());
    });
  });
}
