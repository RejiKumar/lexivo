/// Shared [Result] / [Failure] types used by every usecase.
library;

/// Domain failure hierarchy mapped from network and auth errors.
sealed class Failure {
  const Failure({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() => message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.cause});
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Unauthorized',
    super.cause,
  });
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.cause});
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'Unexpected error',
    super.cause,
  });
}

/// Free-tier quota exceeded (HTTP 429 + ``quota_exceeded``).
final class QuotaFailure extends Failure {
  const QuotaFailure({
    required super.message,
    required this.resource,
    required this.limit,
    this.period,
    super.cause,
  });

  final String resource;
  final int limit;
  final String? period;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuotaFailure &&
          message == other.message &&
          resource == other.resource &&
          limit == other.limit &&
          period == other.period;

  @override
  int get hashCode => Object.hash(runtimeType, message, resource, limit, period);
}

/// Result of a usecase or repository call.
sealed class Result<T> {
  const Result();

  factory Result.success(T value) = Success<T>;
  factory Result.failure(Failure failure) = Failed<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failed<T>;

  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failed() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success() => null,
        Failed(:final failure) => failure,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure error) onFailure,
  }) {
    return switch (this) {
      Success(:final value) => success(value),
      Failed(:final failure) => onFailure(failure),
    };
  }

  R fold<R>({
    required R Function(Failure error) failure,
    required R Function(T value) success,
  }) =>
      when(success: success, onFailure: failure);

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Success(:final value) => Result.success(transform(value)),
        Failed(:final failure) => Result.failure(failure),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T> && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Failed<T> && failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}
