/// Reusable async job poller (OCR, translation, export, etc.).
library;

/// Polls [fetch] until [isTerminal] returns true, [timeout] elapses, or
/// [isCancelled] returns true.
class JobPoller {
  const JobPoller({
    this.interval = const Duration(seconds: 2),
    this.timeout = const Duration(minutes: 5),
    this.backoffFactor = 1.0,
    this.maxInterval = const Duration(seconds: 15),
  });

  final Duration interval;
  final Duration timeout;
  final double backoffFactor;
  final Duration maxInterval;

  Future<T> poll<T>({
    required Future<T> Function() fetch,
    required bool Function(T value) isTerminal,
    bool Function()? isCancelled,
    void Function(T value)? onTick,
  }) async {
    final started = DateTime.now();
    var delay = interval;

    while (true) {
      if (isCancelled?.call() ?? false) {
        throw const JobPollerCancelled();
      }
      if (DateTime.now().difference(started) > timeout) {
        throw const JobPollerTimeout();
      }

      final value = await fetch();
      onTick?.call(value);
      if (isTerminal(value)) return value;

      await Future<void>.delayed(delay);
      if (backoffFactor > 1.0) {
        final nextMs = (delay.inMilliseconds * backoffFactor).round();
        delay = Duration(
          milliseconds: nextMs.clamp(0, maxInterval.inMilliseconds),
        );
      }
    }
  }
}

class JobPollerTimeout implements Exception {
  const JobPollerTimeout();

  @override
  String toString() => 'JobPollerTimeout';
}

class JobPollerCancelled implements Exception {
  const JobPollerCancelled();

  @override
  String toString() => 'JobPollerCancelled';
}
