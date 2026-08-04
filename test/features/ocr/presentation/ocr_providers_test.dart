import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/ocr/presentation/providers/ocr_providers.dart';

import '../../../helpers/fake_ocr_repository.dart';
import '../../../helpers/ocr_test_harness.dart';

void main() {
  test('ready doc → AsyncValue data with extracted text', () async {
    final repo = FakeOcrRepository(initial: [sampleOcrDocument()]);
    final container = createOcrContainer(repository: repo);
    addTearDown(container.dispose);

    final view = await container.read(ocrResultProvider('doc-1').future);
    expect(view.extractedText, contains('Extracted OCR'));
    expect(view.status, DocumentStatus.ready);
    expect(repo.getCalls, greaterThanOrEqualTo(1));
  });

  test('processing → JobPoller → ready → fetches text', () async {
    final repo = FakeOcrRepository(
      initial: [
        sampleOcrDocument(
          id: 'doc-p',
          status: DocumentStatus.processing,
          extractedText: null,
        ),
      ],
    );
    repo.statusSequence.addAll([
      DocumentStatus.processing,
      DocumentStatus.processing,
      DocumentStatus.ready,
    ]);
    // When ready, getDocument should return text.
    repo.documents[0] = sampleOcrDocument(
      id: 'doc-p',
      status: DocumentStatus.ready,
      extractedText: 'Polled text',
    );

    final container = createOcrContainer(
      repository: repo,
      poller: const JobPoller(
        interval: Duration(milliseconds: 1),
        timeout: Duration(seconds: 2),
      ),
    );
    addTearDown(container.dispose);

    final view = await container.read(ocrResultProvider('doc-p').future);
    expect(view.extractedText, 'Polled text');
    expect(repo.statusCalls, greaterThan(1));
  });

  test('processing → failed → error', () async {
    final repo = FakeOcrRepository(
      initial: [
        sampleOcrDocument(
          id: 'doc-f',
          status: DocumentStatus.processing,
          extractedText: null,
        ),
      ],
    );
    repo.statusSequence.addAll([
      DocumentStatus.processing,
      DocumentStatus.failed,
    ]);

    final container = createOcrContainer(
      repository: repo,
      poller: const JobPoller(
        interval: Duration(milliseconds: 1),
        timeout: Duration(seconds: 2),
      ),
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(ocrResultProvider('doc-f').future),
      throwsA(isA<UnexpectedFailure>()),
    );
  });

  test('dispose cancels polling', () async {
    final repo = FakeOcrRepository(
      initial: [
        sampleOcrDocument(
          id: 'doc-c',
          status: DocumentStatus.processing,
          extractedText: null,
        ),
      ],
    );
    repo.statusSequence.addAll([
      DocumentStatus.processing,
      DocumentStatus.processing,
      DocumentStatus.processing,
      DocumentStatus.ready,
    ]);

    final container = createOcrContainer(
      repository: repo,
      poller: const JobPoller(
        interval: Duration(milliseconds: 30),
        timeout: Duration(seconds: 5),
      ),
    );

    // Start load then dispose quickly.
    final future = container.read(ocrResultProvider('doc-c').future);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    container.dispose();

    await expectLater(future, throwsA(anything));
  });

  test('timeout maps to UnexpectedFailure', () async {
    final repo = FakeOcrRepository(
      initial: [
        sampleOcrDocument(
          id: 'doc-t',
          status: DocumentStatus.processing,
          extractedText: null,
        ),
      ],
    );
    // Always processing — never terminal.
    repo.statusSequence.addAll([DocumentStatus.processing]);

    final container = createOcrContainer(
      repository: repo,
      poller: const JobPoller(
        interval: Duration(milliseconds: 1),
        timeout: Duration(milliseconds: 20),
      ),
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(ocrResultProvider('doc-t').future),
      throwsA(
        isA<UnexpectedFailure>().having(
          (f) => f.message,
          'message',
          contains('longer than expected'),
        ),
      ),
    );
  });

  test('retry re-enters load path', () async {
    final repo = FakeOcrRepository(
      initial: [
        sampleOcrDocument(id: 'doc-r', status: DocumentStatus.failed),
      ],
    );
    final container = createOcrContainer(repository: repo);
    addTearDown(container.dispose);

    await expectLater(
      container.read(ocrResultProvider('doc-r').future),
      throwsA(isA<UnexpectedFailure>()),
    );

    repo.documents[0] = sampleOcrDocument(
      id: 'doc-r',
      status: DocumentStatus.ready,
      extractedText: 'After retry',
    );

    await container.read(ocrResultProvider('doc-r').notifier).retry();
    final view = container.read(ocrResultProvider('doc-r')).valueOrNull;
    expect(view?.extractedText, 'After retry');
  });
}
