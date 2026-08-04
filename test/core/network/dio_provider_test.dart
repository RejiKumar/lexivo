import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lexivo/core/network/dio_provider.dart';

void main() {
  group('createLexivoDio', () {
    test('base options use API_BASE_URL, timeouts, JSON content-type', () {
      final dio = createLexivoDio(
        config: const ApiConfig(
          baseUrl: 'http://api.test',
          connectTimeout: Duration(seconds: 5),
        ),
        tokenReader: () async => null,
      );
      expect(dio.options.baseUrl, 'http://api.test');
      expect(dio.options.connectTimeout, const Duration(seconds: 5));
      expect(
        dio.options.headers[Headers.contentTypeHeader],
        Headers.jsonContentType,
      );
    });

    test('injects Authorization bearer when token available', () async {
      final dio = createLexivoDio(
        config: const ApiConfig(baseUrl: 'http://api.test'),
        tokenReader: () async => 'abc',
        maxRetries: 0,
      );
      final adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;

      String? seen;
      // Appended after auth interceptor so header is already injected.
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            seen = options.headers['Authorization'] as String?;
            handler.next(options);
          },
        ),
      );
      adapter.onGet('/ping', (server) => server.reply(200, {'ok': true}));
      await dio.get<dynamic>('/ping');
      expect(seen, 'Bearer abc');
    });

    test('omits Authorization when anonymous', () async {
      final dio = createLexivoDio(
        config: const ApiConfig(baseUrl: 'http://api.test'),
        tokenReader: () async => null,
        maxRetries: 0,
      );
      final adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;

      String? seen;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            seen = options.headers['Authorization'] as String?;
            handler.next(options);
          },
        ),
      );
      adapter.onGet('/ping', (server) => server.reply(200, {'ok': true}));
      await dio.get<dynamic>('/ping');
      expect(seen, isNull);
    });

    test('retries idempotent GET on connection error up to maxRetries',
        () async {
      var attempts = 0;
      final dio = createLexivoDio(
        config: const ApiConfig(baseUrl: 'http://api.test'),
        tokenReader: () async => null,
        maxRetries: 2,
      );
      dio.httpClientAdapter = _FlakyAdapter(
        failTimes: 2,
        onAttempt: () => attempts++,
      );
      final response = await dio.get<dynamic>('/ping');
      expect(response.statusCode, 200);
      expect(attempts, 3); // initial + 2 retries
    });
  });
}

class _FlakyAdapter implements HttpClientAdapter {
  _FlakyAdapter({required this.failTimes, required this.onAttempt});

  final int failTimes;
  final void Function() onAttempt;
  int _failures = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onAttempt();
    if (_failures < failTimes) {
      _failures++;
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        message: 'flaky',
      );
    }
    return ResponseBody.fromString(
      '{"ok":true}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
