import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/network/api_models.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_harness.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ApiClient client;

  setUp(() {
    dio = createTestDio(baseUrl: 'http://api.test');
    adapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = adapter;
    client = ApiClient(dio);
  });

  group('ApiClient', () {
    test('getAuthMe', () async {
      adapter.onGet(
        '/api/v1/auth/me',
        (server) => server.reply(200, readFixtureSync('auth_me.json')),
      );
      final result = await client.getAuthMe();
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.subject, 'user-123');
      expect(result.valueOrNull?.displayName, 'Alex');
    });

    test('getUserMe / patchUserMe', () async {
      adapter.onGet(
        '/api/v1/users/me',
        (server) => server.reply(200, readFixtureSync('user_profile.json')),
      );
      adapter.onPatch(
        '/api/v1/users/me',
        (server) => server.reply(200, {
          ...readFixtureSync('user_profile.json'),
          'display_name': 'Alex Updated',
        }),
        data: Matchers.any,
      );

      final get = await client.getUserMe();
      expect(get.valueOrNull?.externalId, 'user-123');

      final patch = await client.patchUserMe(
        const UserProfileUpdateDto(displayName: 'Alex Updated'),
      );
      expect(patch.valueOrNull?.displayName, 'Alex Updated');
    });

    test('documents list / get / status', () async {
      adapter.onGet(
        '/api/v1/documents',
        (server) => server.reply(200, readFixtureSync('documents_list.json')),
      );
      adapter.onGet(
        '/api/v1/documents/doc-1',
        (server) => server.reply(200, readFixtureSync('document.json')),
      );
      adapter.onGet(
        '/api/v1/documents/doc-1/status',
        (server) =>
            server.reply(200, readFixtureSync('document_status.json')),
      );

      final list = await client.listDocuments();
      expect(list.valueOrNull?.items.single.id, 'doc-1');

      final doc = await client.getDocument('doc-1');
      expect(doc.valueOrNull?.status, 'ready');

      final status = await client.getDocumentStatus('doc-1');
      expect(status.valueOrNull?.status, 'processing');
    });
  });
}
