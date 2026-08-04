import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_mapper.dart';

/// Reads the current access token for Authorization header injection.
/// Auth feature supplies this via a domain-level callback — never import
/// `features/auth/data` from core.
typedef AccessTokenReader = Future<String?> Function();

/// App configuration for the HTTP client.
class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
}

/// Default config from dart-defines / env.
final apiConfigProvider = Provider<ApiConfig>((ref) {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  return ApiConfig(baseUrl: baseUrl);
});

/// Override in auth wiring to return the persisted session token.
final accessTokenReaderProvider = Provider<AccessTokenReader>((ref) {
  return () async => null;
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(apiConfigProvider);
  final tokenReader = ref.watch(accessTokenReaderProvider);
  return createLexivoDio(
    config: config,
    tokenReader: tokenReader,
  );
});

/// Builds a configured [Dio] with auth + retry interceptors.
Dio createLexivoDio({
  required ApiConfig config,
  required AccessTokenReader tokenReader,
  int maxRetries = 2,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      headers: const {
        Headers.contentTypeHeader: Headers.jsonContentType,
        Headers.acceptHeader: Headers.jsonContentType,
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenReader();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Surface mapped failure via error.error for callers that check it.
        error = error.copyWith(error: ErrorMapper.map(error));
        handler.next(error);
      },
    ),
  );

  dio.interceptors.add(_RetryInterceptor(dio: dio, maxRetries: maxRetries));

  return dio;
}

/// Retries idempotent GET requests with bounded attempts.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor({required this.dio, required this.maxRetries});

  final Dio dio;
  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final attempt = request.extra['retry_attempt'] as int? ?? 0;
    final isGet = request.method.toUpperCase() == 'GET';
    final retriable = isGet &&
        attempt < maxRetries &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError ||
            (err.response?.statusCode ?? 0) >= 500);

    if (!retriable) {
      return handler.next(err);
    }

    request.extra['retry_attempt'] = attempt + 1;
    try {
      final response = await dio.fetch<dynamic>(request);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}
