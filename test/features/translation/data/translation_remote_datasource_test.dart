import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/features/translation/data/datasources/translation_remote_datasource.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_harness.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late TranslationRemoteDatasource remote;

  setUp(() {
    dio = createTestDio(baseUrl: 'http://api.test');
    adapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = adapter;
    remote = TranslationRemoteDatasource(ApiClient(dio));
  });

  test('getDocument maps translation fields', () async {
    adapter.onGet(
      '/api/v1/documents/doc-1',
      (server) =>
          server.reply(200, readFixtureSync('documents/get_with_translation.json')),
    );
    final result = await remote.getDocument('doc-1');
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.translatedText, contains('Texto traducido'));
    expect(result.valueOrNull?.sourceLang, 'en');
    expect(result.valueOrNull?.targetLang, 'es');
  });

  test('getTranslationStatus / requestTranslation', () async {
    adapter.onGet(
      '/api/v1/documents/doc-1/translation/status',
      (server) => server.reply(
        200,
        readFixtureSync('documents/translation_status_processing.json'),
      ),
    );
    adapter.onPost(
      '/api/v1/documents/doc-1/translation',
      (server) => server.reply(
        202,
        readFixtureSync('documents/translation_request_accepted.json'),
      ),
      data: Matchers.any,
    );

    final status = await remote.getTranslationStatus('doc-1');
    expect(status.valueOrNull?.name, 'processing');

    final requested = await remote.requestTranslation(
      'doc-1',
      sourceLang: 'en',
      targetLang: 'es',
    );
    expect(requested.isSuccess, isTrue);
    expect(requested.valueOrNull?.translationStatus.name, 'processing');
  });

  test('requestTranslation 409 → ValidationFailure', () async {
    adapter.onPost(
      '/api/v1/documents/doc-1/translation',
      (server) => server.reply(
        409,
        readFixtureSync('documents/translation_not_ready_409.json'),
      ),
      data: Matchers.any,
    );
    final result = await remote.requestTranslation(
      'doc-1',
      sourceLang: 'en',
      targetLang: 'es',
    );
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message, contains('not ready'));
  });
}
