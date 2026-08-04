import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/utils/job_poller.dart';

void main() {
  group('JobPoller', () {
    test('polls until terminal', () async {
      var ticks = 0;
      final poller = JobPoller(
        interval: const Duration(milliseconds: 1),
        timeout: const Duration(seconds: 2),
      );
      final result = await poller.poll<int>(
        fetch: () async => ++ticks,
        isTerminal: (v) => v >= 3,
      );
      expect(result, 3);
      expect(ticks, 3);
    });

    test('times out', () async {
      final poller = JobPoller(
        interval: const Duration(milliseconds: 1),
        timeout: const Duration(milliseconds: 20),
      );
      expect(
        () => poller.poll<int>(
          fetch: () async => 0,
          isTerminal: (_) => false,
        ),
        throwsA(isA<JobPollerTimeout>()),
      );
    });

    test('cancels', () async {
      var cancelled = false;
      final poller = JobPoller(
        interval: const Duration(milliseconds: 1),
        timeout: const Duration(seconds: 2),
      );
      Future.delayed(const Duration(milliseconds: 5), () {
        cancelled = true;
      });
      expect(
        () => poller.poll<int>(
          fetch: () async => 0,
          isTerminal: (_) => false,
          isCancelled: () => cancelled,
        ),
        throwsA(isA<JobPollerCancelled>()),
      );
    });
  });
}
