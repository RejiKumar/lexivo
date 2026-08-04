import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/network/error_mapper.dart';
import 'package:lexivo/core/utils/result.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('ErrorMapper', () {
    test('401 → UnauthorizedFailure with body message', () {
      final body = readFixtureSync('error_unauthorized.json');
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/me'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/me'),
          statusCode: 401,
          data: body,
        ),
      );
      final failure = ErrorMapper.map(err);
      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, 'Invalid credentials');
    });

    test('422 → ValidationFailure', () {
      final body = readFixtureSync('error_validation.json');
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/v1/users/me'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/users/me'),
          statusCode: 422,
          data: body,
        ),
      );
      final failure = ErrorMapper.map(err);
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, contains('email'));
    });

    test('5xx / timeout → NetworkFailure', () {
      final timeout = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(ErrorMapper.map(timeout), isA<NetworkFailure>());

      final server = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 503,
          data: {'detail': 'unavailable'},
        ),
      );
      expect(ErrorMapper.map(server), isA<NetworkFailure>());
    });

    test('409 → ValidationFailure (not-ready)', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/v1/documents/x/summary'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/documents/x/summary'),
          statusCode: 409,
          data: {
            'detail':
                'Document OCR is not ready; summarization requires status=ready',
          },
        ),
      );
      final failure = ErrorMapper.map(err);
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, contains('not ready'));
    });

    test('unknown → UnexpectedFailure', () {
      expect(ErrorMapper.map(StateError('boom')), isA<UnexpectedFailure>());
    });
  });
}
