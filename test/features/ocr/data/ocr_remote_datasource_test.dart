import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/features/ocr/data/datasources/ocr_remote_datasource.dart';
import 'package:lexivo/features/ocr/data/repositories/ocr_repository_impl.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_harness.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late OcrRemoteDatasource remote;
  late OcrRepositoryImpl repo;

  setUp(() {
    dio = createTestDio(baseUrl: 'http://api.test');
    adapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = adapter;
    remote = OcrRemoteDatasource(ApiClient(dio));
    repo = OcrRepositoryImpl(remote);
  });

  test('get/status via ApiClient maps extractedText', () async {
    adapter.onGet(
      '/api/v1/documents/doc-1',
      (server) => server.reply(
        200,
        readFixtureSync('documents/get_with_extracted_text.json'),
      ),
    );
    adapter.onGet(
      '/api/v1/documents/doc-1/status',
      (server) =>
          server.reply(200, readFixtureSync('documents/status_ready.json')),
    );

    final get = await repo.getDocument('doc-1');
    expect(get.valueOrNull?.extractedText, contains('Extracted OCR'));
    expect(get.valueOrNull?.status.name, 'ready');

    final status = await repo.getStatus('doc-1');
    expect(status.valueOrNull?.name, 'ready');
  });

  test('get maps Dio errors via ErrorMapper', () async {
    adapter.onGet(
      '/api/v1/documents/missing',
      (server) => server.reply(
        422,
        readFixtureSync('documents/error_validation.json'),
      ),
    );

    final result = await repo.getDocument('missing');
    expect(result.isFailure, isTrue);
  });
}
