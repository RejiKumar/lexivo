import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/utils/result.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_harness.dart';

void main() {
  late ApiClient client;
  late DioAdapter adapter;

  setUp(() {
    final dio = createTestDio();
    adapter = DioAdapter(dio: dio);
    client = ApiClient(dio);
  });

  group('ApiClient export', () {
    test('requestExport / getExportStatus / getExport', () async {
      adapter.onPost(
        '/api/v1/documents/doc-1/export',
        (server) => server.reply(
          202,
          readFixtureSync('exports/export_processing.json'),
        ),
        data: Matchers.any,
      );
      adapter.onGet(
        '/api/v1/documents/doc-1/export/status',
        (server) =>
            server.reply(200, readFixtureSync('exports/export_ready.json')),
      );
      adapter.onGet(
        '/api/v1/exports/exp-1',
        (server) =>
            server.reply(200, readFixtureSync('exports/export_ready.json')),
      );

      final requested = await client.requestExport(
        'doc-1',
        includeSummary: true,
        includeTranslation: true,
        includeChat: true,
      );
      expect(requested.isSuccess, isTrue);
      expect(requested.valueOrNull?.exportStatus, 'processing');
      expect(requested.valueOrNull?.includeSummary, isTrue);

      final status = await client.getExportStatus('doc-1');
      expect(status.valueOrNull?.exportStatus, 'ready');
      expect(status.valueOrNull?.signedUrl, contains('signed.test'));

      final byId = await client.getExport('exp-1');
      expect(byId.valueOrNull?.id, 'exp-1');
      expect(byId.valueOrNull?.signedUrl, isNotNull);
    });

    test('requestExport 409 → ValidationFailure', () async {
      adapter.onPost(
        '/api/v1/documents/doc-1/export',
        (server) => server.reply(
          409,
          readFixtureSync('exports/export_section_not_ready_409.json'),
        ),
        data: Matchers.any,
      );

      final result = await client.requestExport(
        'doc-1',
        includeSummary: true,
      );
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull?.message, contains('not ready'));
    });

    test('requestExport 422 → ValidationFailure', () async {
      adapter.onPost(
        '/api/v1/documents/doc-1/export',
        (server) => server.reply(
          422,
          readFixtureSync('exports/export_no_toggles_422.json'),
        ),
        data: Matchers.any,
      );

      final result = await client.requestExport('doc-1');
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull?.message.toLowerCase(), contains('toggle'));
    });
  });
}
