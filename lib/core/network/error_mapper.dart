import 'package:dio/dio.dart';

import '../utils/result.dart';

/// Maps Dio / HTTP errors to domain [Failure] types.
abstract final class ErrorMapper {
  static Failure map(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) return error;

    if (error is DioException) {
      return _mapDio(error);
    }

    return UnexpectedFailure(
      message: error.toString(),
      cause: error,
    );
  }

  static Failure _mapDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.transformTimeout:
        return NetworkFailure(
          message: 'Network unavailable',
          cause: error,
        );
      case DioExceptionType.badResponse:
        return _mapStatus(error.response?.statusCode, error);
      case DioExceptionType.cancel:
        return const UnexpectedFailure(message: 'Request cancelled');
      case DioExceptionType.badCertificate:
        return NetworkFailure(message: 'Bad certificate', cause: error);
      case DioExceptionType.unknown:
        return UnexpectedFailure(
          message: error.message ?? 'Unknown network error',
          cause: error,
        );
    }
  }

  static Failure _mapStatus(int? status, DioException error) {
    final bodyMessage = _extractMessage(error.response?.data);
    if (status == 401 || status == 403) {
      return UnauthorizedFailure(
        message: bodyMessage ?? 'Unauthorized',
        cause: error,
      );
    }
    if (status == 429) {
      final quota = _extractQuotaDetail(error.response?.data);
      if (quota != null) {
        return QuotaFailure(
          message: quota.message,
          resource: quota.resource,
          limit: quota.limit,
          period: quota.period,
          cause: error,
        );
      }
    }
    if (status == 422 || status == 409) {
      return ValidationFailure(
        message: bodyMessage ??
            (status == 409 ? 'Document not ready' : 'Validation failed'),
        cause: error,
      );
    }
    if (status != null && status >= 500) {
      return NetworkFailure(
        message: bodyMessage ?? 'Server error',
        cause: error,
      );
    }
    if (status != null && status >= 400) {
      return NetworkFailure(
        message: bodyMessage ?? 'Request failed ($status)',
        cause: error,
      );
    }
    return UnexpectedFailure(
      message: bodyMessage ?? 'Unexpected response',
      cause: error,
    );
  }

  static ({String resource, int limit, String? period, String message})?
      _extractQuotaDetail(Object? data) {
    if (data is! Map) return null;
    final detail = data['detail'];
    if (detail is! Map) return null;
    if (detail['code'] != 'quota_exceeded') return null;
    final resource = detail['resource'];
    final limit = detail['limit'];
    final message = detail['message'];
    if (resource is! String || limit is! num || message is! String) {
      return null;
    }
    final period = detail['period'];
    return (
      resource: resource,
      limit: limit.toInt(),
      period: period is String ? period : null,
      message: message,
    );
  }

  static String? _extractMessage(Object? data) {
    if (data == null) return null;
    if (data is String && data.isNotEmpty) return data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is Map && detail['message'] is String) {
        return detail['message'] as String;
      }
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] is String) {
          return first['msg'] as String;
        }
        return detail.first.toString();
      }
      final message = data['message'];
      if (message is String) return message;
    }
    return null;
  }
}
