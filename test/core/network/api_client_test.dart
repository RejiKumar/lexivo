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
      expect(
        doc.valueOrNull?.extractedText,
        'Extracted OCR body from the lease agreement.',
      );

      final status = await client.getDocumentStatus('doc-1');
      expect(status.valueOrNull?.status, 'processing');
    });

    test('getDocument parses nullable extracted_text', () async {
      adapter.onGet(
        '/api/v1/documents/doc-1',
        (server) => server.reply(
          200,
          readFixtureSync('documents/get_with_extracted_text.json'),
        ),
      );
      adapter.onGet(
        '/api/v1/documents/doc-empty',
        (server) => server.reply(
          200,
          readFixtureSync('documents/get_ready_empty_text.json'),
        ),
      );
      adapter.onGet(
        '/api/v1/documents/doc-proc',
        (server) => server.reply(
          200,
          readFixtureSync('documents/get_processing.json'),
        ),
      );

      final ready = await client.getDocument('doc-1');
      expect(ready.valueOrNull?.extractedText, isNotNull);

      final empty = await client.getDocument('doc-empty');
      expect(empty.valueOrNull?.extractedText, isNull);
      expect(empty.valueOrNull?.status, 'ready');

      final processing = await client.getDocument('doc-proc');
      expect(processing.valueOrNull?.extractedText, isNull);
      expect(processing.valueOrNull?.status, 'processing');
    });

    test('createDocument multipart file + optional title', () async {
      adapter.onPost(
        '/api/v1/documents',
        (server) => server.reply(
          201,
          readFixtureSync('documents/create_response.json'),
        ),
        data: Matchers.any,
      );

      final result = await client.createDocument(
        bytes: [37, 80, 68, 70], // %PDF
        filename: 'lease.pdf',
        title: 'Lease',
      );
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.id, 'doc-new');
      expect(result.valueOrNull?.status, 'processing');
      expect(result.valueOrNull?.title, 'Lease');
    });

    test('createDocument maps Dio errors via ErrorMapper', () async {
      adapter.onPost(
        '/api/v1/documents',
        (server) => server.reply(
          422,
          readFixtureSync('documents/error_validation.json'),
        ),
        data: Matchers.any,
      );

      final result = await client.createDocument(
        bytes: [1, 2, 3],
        filename: 'bad.bin',
      );
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isNotNull);
    });

    test('requestSummary / getSummaryStatus', () async {
      adapter.onPost(
        '/api/v1/documents/doc-1/summary',
        (server) => server.reply(
          202,
          readFixtureSync('documents/summary_request_accepted.json'),
        ),
      );
      adapter.onGet(
        '/api/v1/documents/doc-1/summary/status',
        (server) => server.reply(
          200,
          readFixtureSync('documents/summary_status_processing.json'),
        ),
      );
      adapter.onGet(
        '/api/v1/documents/doc-sum',
        (server) => server.reply(
          200,
          readFixtureSync('documents/get_with_summaries.json'),
        ),
      );

      final requested = await client.requestSummary('doc-1');
      expect(requested.isSuccess, isTrue);
      expect(requested.valueOrNull?.summaryStatus, 'processing');

      final status = await client.getSummaryStatus('doc-1');
      expect(status.valueOrNull?.summaryStatus, 'processing');

      final doc = await client.getDocument('doc-sum');
      expect(doc.valueOrNull?.shortSummary, contains('Lease covers'));
      expect(doc.valueOrNull?.detailedSummary, contains('rental term'));
      expect(doc.valueOrNull?.summaryStatus, 'ready');
    });

    test('requestSummary 409 → ValidationFailure', () async {
      adapter.onPost(
        '/api/v1/documents/doc-1/summary',
        (server) => server.reply(
          409,
          readFixtureSync('documents/summary_not_ready_409.json'),
        ),
      );

      final result = await client.requestSummary('doc-1');
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.message, contains('not ready'));
    });
  });
}
