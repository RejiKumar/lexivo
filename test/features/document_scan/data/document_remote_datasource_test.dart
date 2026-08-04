import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/features/document_scan/data/datasources/document_remote_datasource.dart';
import 'package:lexivo/features/document_scan/data/repositories/document_repository_impl.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_harness.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late DocumentRemoteDatasource remote;
  late DocumentRepositoryImpl repo;

  setUp(() {
    dio = createTestDio(baseUrl: 'http://api.test');
    adapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = adapter;
    remote = DocumentRemoteDatasource(ApiClient(dio));
    repo = DocumentRepositoryImpl(remote);
  });

  test('list/get/status/create via ApiClient mapping', () async {
    adapter.onGet(
      '/api/v1/documents',
      (server) => server.reply(200, readFixtureSync('documents/list.json')),
    );
    adapter.onGet(
      '/api/v1/documents/doc-1',
      (server) => server.reply(200, readFixtureSync('documents/get.json')),
    );
    adapter.onGet(
      '/api/v1/documents/doc-1/status',
      (server) =>
          server.reply(200, readFixtureSync('documents/status_ready.json')),
    );
    adapter.onPost(
      '/api/v1/documents',
      (server) =>
          server.reply(201, readFixtureSync('documents/create_response.json')),
      data: Matchers.any,
    );

    final list = await repo.listDocuments();
    expect(list.valueOrNull?.single.id, 'doc-1');

    final get = await repo.getDocument('doc-1');
    expect(get.valueOrNull?.title, 'Sample');

    final status = await repo.getStatus('doc-1');
    expect(status.valueOrNull?.name, 'ready');

    final created = await repo.createWithUpload(
      bytes: [1],
      filename: 'a.pdf',
      title: 'Lease',
    );
    expect(created.valueOrNull?.status.name, 'processing');
  });
}
