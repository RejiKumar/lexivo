import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/utils/result.dart';

void main() {
  group('Result', () {
    test('success / failure constructors', () {
      final ok = Result.success(42);
      final err = Result<int>.failure(const NetworkFailure(message: 'down'));

      expect(ok.isSuccess, isTrue);
      expect(err.isFailure, isTrue);
      expect(ok.valueOrNull, 42);
      expect(err.failureOrNull, isA<NetworkFailure>());
    });

    test('when / fold / map', () {
      final ok = Result.success(2);
      expect(ok.when(success: (v) => v * 2, onFailure: (_) => -1), 4);
      expect(
        ok.fold(failure: (_) => 'f', success: (v) => 's$v'),
        's2',
      );
      expect(ok.map((v) => '$v').valueOrNull, '2');

      final err = Result<int>.failure(const ValidationFailure(message: 'bad'));
      expect(err.map((v) => v).failureOrNull?.message, 'bad');
    });

    test('equality', () {
      expect(Result.success(1), Result.success(1));
      expect(
        Result<int>.failure(const UnauthorizedFailure()),
        Result<int>.failure(const UnauthorizedFailure()),
      );
    });
  });

  group('Failure', () {
    test('subtypes are distinct', () {
      expect(
        const NetworkFailure(message: 'x'),
        isNot(const UnauthorizedFailure(message: 'x')),
      );
    });
  });
}
