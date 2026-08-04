import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/pdf_export/pdf_export.dart';

import '../../helpers/fake_pdf_export_repository.dart';
import '../../helpers/pdf_export_test_harness.dart';

void main() {
  test('initial load with no prior export → null idle', () async {
    final repo = FakePdfExportRepository();
    final container = createPdfExportContainer(repository: repo);
    addTearDown(container.dispose);

    final job = await container.read(pdfExportProvider('doc-1').future);
    expect(job, isNull);
  });

  test('request toggles → processing → ready with signedUrl', () async {
    final repo = FakePdfExportRepository();
    repo.statusSequence.addAll([
      ExportJobStatus.processing,
      ExportJobStatus.ready,
    ]);
    final container = createPdfExportContainer(
      repository: repo,
      poller: const JobPoller(
        interval: Duration(milliseconds: 1),
        timeout: Duration(seconds: 5),
      ),
    );
    addTearDown(container.dispose);

    await container.read(pdfExportProvider('doc-1').future);
    await container.read(pdfExportProvider('doc-1').notifier).requestExport(
          const ExportSectionToggles(
            includeSummary: true,
            includeTranslation: true,
            includeChat: true,
          ),
        );

    final job = container.read(pdfExportProvider('doc-1')).asData?.value;
    expect(job?.isReady, isTrue);
    expect(job?.signedUrl, contains('signed.test'));
    expect(repo.lastRequestToggles?.includeChat, isTrue);
  });

  test('summary-only request body matches toggles', () async {
    final repo = FakePdfExportRepository()
      ..requestResultStatus = ExportJobStatus.ready;
    final container = createPdfExportContainer(repository: repo);
    addTearDown(container.dispose);

    await container.read(pdfExportProvider('doc-1').future);
    await container.read(pdfExportProvider('doc-1').notifier).requestExport(
          const ExportSectionToggles(includeSummary: true),
        );

    expect(repo.lastRequestToggles?.includeSummary, isTrue);
    expect(repo.lastRequestToggles?.includeTranslation, isFalse);
    expect(repo.lastRequestToggles?.includeChat, isFalse);
  });

  test('409 does not start successful poll', () async {
    final repo = FakePdfExportRepository()
      ..nextRequestFailure = const ValidationFailure(
        message: 'Summary is not ready',
      );
    final container = createPdfExportContainer(repository: repo);
    addTearDown(container.dispose);

    await container.read(pdfExportProvider('doc-1').future);
    await container.read(pdfExportProvider('doc-1').notifier).requestExport(
          const ExportSectionToggles(includeSummary: true),
        );

    final async = container.read(pdfExportProvider('doc-1'));
    expect(async, isA<AsyncError>());
    expect(async.error.toString(), contains('not ready'));
    expect(repo.statusCalls, lessThan(2));
  });

  test('failed terminal status → error + retry re-POSTs', () async {
    final repo = FakePdfExportRepository();
    final container = createPdfExportContainer(
      repository: repo,
      poller: const JobPoller(
        interval: Duration(milliseconds: 1),
        timeout: Duration(seconds: 5),
      ),
    );
    addTearDown(container.dispose);

    await container.read(pdfExportProvider('doc-1').future);

    repo.statusSequence.addAll([ExportJobStatus.failed]);
    await container.read(pdfExportProvider('doc-1').notifier).requestExport(
          const ExportSectionToggles(includeSummary: true),
        );
    expect(container.read(pdfExportProvider('doc-1')), isA<AsyncError>());

    repo.statusSequence
      ..clear()
      ..addAll([ExportJobStatus.processing, ExportJobStatus.ready]);
    repo.requestResultStatus = ExportJobStatus.processing;

    await container.read(pdfExportProvider('doc-1').notifier).retry();
    expect(
      container.read(pdfExportProvider('doc-1')).asData?.value?.isReady,
      isTrue,
    );
    expect(repo.requestCalls, 2);
  });
}
