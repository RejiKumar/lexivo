import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/summarization/presentation/providers/summarization_providers.dart';

import '../../../helpers/fake_summarization_repository.dart';
import '../../../helpers/summarization_test_harness.dart';

void main() {
  test('ready document → AsyncValue data with short + detailed', () async {
    final repo = FakeSummarizationRepository(
      initial: [sampleSummaryDocument()],
    );
    final container = createSummarizationContainer(repository: repo);
    addTearDown(container.dispose);

    final view = await container.read(summaryResultProvider('doc-1').future);
    expect(view.shortSummary, contains('Lease covers'));
    expect(view.detailedSummary, contains('rental term'));
    expect(repo.requestCalls, 0);
  });

  test('idle → request then poll to ready', () async {
    final repo = FakeSummarizationRepository(
      initial: [
        sampleSummaryDocument(
          summaryStatus: SummaryStatus.idle,
          shortSummary: 'Lease covers term and rent.',
          detailedSummary:
              'This lease agreement outlines the rental term, payment schedule, and tenant obligations in detail.',
        ),
      ],
    )
      ..requestResultStatus = SummaryStatus.processing
      ..statusSequence.addAll([
        SummaryStatus.idle,
        SummaryStatus.processing,
        SummaryStatus.ready,
      ]);

    final container = createSummarizationContainer(
      repository: repo,
      poller: const JobPoller(
        interval: Duration(milliseconds: 10),
        timeout: Duration(seconds: 2),
      ),
    );
    addTearDown(container.dispose);

    final view = await container.read(summaryResultProvider('doc-1').future);
    expect(repo.requestCalls, greaterThanOrEqualTo(1));
    expect(view.hasSummaries, isTrue);
  });

  test('processing → poll until ready', () async {
    final repo = FakeSummarizationRepository(
      initial: [
        sampleSummaryDocument(
          summaryStatus: SummaryStatus.processing,
        ),
      ],
    )..statusSequence.addAll([
        SummaryStatus.processing,
        SummaryStatus.processing,
        SummaryStatus.ready,
      ]);

    final container = createSummarizationContainer(
      repository: repo,
      poller: const JobPoller(
        interval: Duration(milliseconds: 10),
        timeout: Duration(seconds: 2),
      ),
    );
    addTearDown(container.dispose);

    final view = await container.read(summaryResultProvider('doc-1').future);
    expect(repo.requestCalls, 0);
    expect(view.shortSummary, isNotEmpty);
  });

  test('409 not-ready → error without polling', () async {
    final repo = FakeSummarizationRepository(
      initial: [
        sampleSummaryDocument(
          summaryStatus: SummaryStatus.idle,
          shortSummary: null,
          detailedSummary: null,
        ),
      ],
    )..nextRequestFailure = const ValidationFailure(
        message: 'Document OCR is not ready',
      );

    final container = createSummarizationContainer(repository: repo);
    addTearDown(container.dispose);

    await expectLater(
      container.read(summaryResultProvider('doc-1').future),
      throwsA(isA<ValidationFailure>()),
    );
    expect(repo.statusCalls, lessThan(3));
  });

  test('failed status → error; retry re-requests', () async {
    final repo = FakeSummarizationRepository(
      initial: [
        sampleSummaryDocument(
          summaryStatus: SummaryStatus.failed,
          shortSummary: null,
          detailedSummary: null,
        ),
      ],
    );
    final container = createSummarizationContainer(repository: repo);
    addTearDown(container.dispose);

    await expectLater(
      container.read(summaryResultProvider('doc-1').future),
      throwsA(isA<UnexpectedFailure>()),
    );

    repo.requestResultStatus = SummaryStatus.ready;
    repo.documents[0] = sampleSummaryDocument(summaryStatus: SummaryStatus.idle);
    await container.read(summaryResultProvider('doc-1').notifier).retry();
    final view = await container.read(summaryResultProvider('doc-1').future);
    expect(view.hasSummaries, isTrue);
    expect(repo.requestCalls, greaterThanOrEqualTo(1));
  });

  test('dispose cancels polling', () async {
    final repo = FakeSummarizationRepository(
      initial: [
        sampleSummaryDocument(
          summaryStatus: SummaryStatus.processing,
          shortSummary: null,
          detailedSummary: null,
        ),
      ],
    )..statusSequence.addAll([
        SummaryStatus.processing,
        SummaryStatus.processing,
        SummaryStatus.processing,
      ]);

    final container = createSummarizationContainer(
      repository: repo,
      poller: const JobPoller(
        interval: Duration(milliseconds: 20),
        timeout: Duration(seconds: 5),
      ),
    );

    final future = container.read(summaryResultProvider('doc-1').future);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    container.dispose();

    await expectLater(future, throwsA(isA<JobPollerCancelled>()));
  });
}
