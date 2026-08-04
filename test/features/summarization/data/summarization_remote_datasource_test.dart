import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/summarization/data/datasources/summarization_remote_datasource.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_harness.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late SummarizationRemoteDatasource datasource;

  setUp(() {
    dio = createTestDio(baseUrl: 'http://api.test');
    adapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = adapter;
    datasource = SummarizationRemoteDatasource(ApiClient(dio));
  });

  test('get / status / request via ApiClient maps summaries', () async {
    adapter.onGet(
      '/api/v1/documents/doc-1',
      (server) => server.reply(
        200,
        readFixtureSync('documents/get_with_summaries.json'),
      ),
    );
    adapter.onGet(
      '/api/v1/documents/doc-1/summary/status',
      (server) => server.reply(
        200,
        readFixtureSync('documents/summary_status_ready.json'),
      ),
    );
    adapter.onPost(
      '/api/v1/documents/doc-1/summary',
      (server) => server.reply(
        202,
        readFixtureSync('documents/summary_request_accepted.json'),
      ),
    );

    final get = await datasource.getDocument('doc-1');
    expect(get.isSuccess, isTrue);
    expect(get.valueOrNull?.shortSummary, contains('Lease covers'));
    expect(get.valueOrNull?.summaryStatus, SummaryStatus.ready);

    final status = await datasource.getSummaryStatus('doc-1');
    expect(status.valueOrNull, SummaryStatus.ready);

    final request = await datasource.requestSummary('doc-1');
    expect(request.isSuccess, isTrue);
    expect(request.valueOrNull?.summaryStatus, SummaryStatus.processing);
  });

  test('409 not-ready → ValidationFailure', () async {
    adapter.onPost(
      '/api/v1/documents/doc-1/summary',
      (server) => server.reply(
        409,
        readFixtureSync('documents/summary_not_ready_409.json'),
      ),
    );

    final result = await datasource.requestSummary('doc-1');
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
    expect(result.failureOrNull?.message, contains('not ready'));
  });
}
