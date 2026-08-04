import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/pdf_export/pdf_export.dart';

import '../../helpers/fake_pdf_export_repository.dart';
import '../../helpers/pdf_export_test_harness.dart';

void main() {
  testWidgets('PdfExportScreen shows toggles and export CTA', (tester) async {
    final repo = FakePdfExportRepository();
    await tester.pumpWidget(
      wrapPdfExportScreen(
        const PdfExportScreen(documentId: 'doc-1'),
        overrides: [
          pdfExportRepositoryProvider.overrideWithValue(repo),
          ...pdfExportCoreOverrides(),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Export PDF'), findsWidgets);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Translation'), findsOneWidget);
    expect(find.text('Chat annotations'), findsOneWidget);
  });

  testWidgets('ready job shows Download PDF CTA', (tester) async {
    final repo = FakePdfExportRepository(
      initial: sampleExportJob(),
    );
    final launched = <Uri>[];

    await tester.pumpWidget(
      wrapPdfExportScreen(
        PdfExportScreen(
          documentId: 'doc-1',
          launchUrlFn: (uri) async {
            launched.add(uri);
            return true;
          },
        ),
        overrides: [
          pdfExportRepositoryProvider.overrideWithValue(repo),
          ...pdfExportCoreOverrides(),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Download PDF'), findsOneWidget);
    await tester.tap(find.text('Download PDF'));
    await tester.pumpAndSettle();
    expect(launched.single.toString(), contains('signed.test'));
  });

  testWidgets('failed export shows LexivoErrorBanner with retry', (tester) async {
    final repo = FakePdfExportRepository(
      initial: sampleExportJob(status: ExportJobStatus.failed)
          .copyWith(errorMessage: 'PDF boom', signedUrl: null),
    );

    await tester.pumpWidget(
      wrapPdfExportScreen(
        const PdfExportScreen(documentId: 'doc-1'),
        overrides: [
          pdfExportRepositoryProvider.overrideWithValue(repo),
          pdfExportJobPollerProvider.overrideWithValue(
            const JobPoller(
              interval: Duration(milliseconds: 1),
              timeout: Duration(seconds: 2),
            ),
          ),
          ...pdfExportCoreOverrides(),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LexivoErrorBanner), findsOneWidget);
  });

  testWidgets('export flow: toggles → ready download', (tester) async {
    final repo = FakePdfExportRepository();
    repo.statusSequence.addAll([
      ExportJobStatus.processing,
      ExportJobStatus.ready,
    ]);

    await tester.pumpWidget(
      wrapPdfExportScreen(
        const PdfExportScreen(documentId: 'doc-1'),
        overrides: [
          pdfExportRepositoryProvider.overrideWithValue(repo),
          pdfExportJobPollerProvider.overrideWithValue(
            const JobPoller(
              interval: Duration(milliseconds: 1),
              timeout: Duration(seconds: 5),
            ),
          ),
          ...pdfExportCoreOverrides(),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(LexivoButton, 'Export PDF'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('Download PDF'), findsOneWidget);
    expect(repo.requestCalls, 1);
    expect(repo.lastRequestToggles?.includeSummary, isTrue);
  });

  testWidgets('409 surfaces error without download CTA', (tester) async {
    final repo = FakePdfExportRepository()
      ..nextRequestFailure = const ValidationFailure(
        message: 'Summary is not ready',
      );

    await tester.pumpWidget(
      wrapPdfExportScreen(
        const PdfExportScreen(documentId: 'doc-1'),
        overrides: [
          pdfExportRepositoryProvider.overrideWithValue(repo),
          ...pdfExportCoreOverrides(),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(LexivoButton, 'Export PDF'));
    await tester.pumpAndSettle();

    expect(find.byType(LexivoErrorBanner), findsOneWidget);
    expect(find.text('Download PDF'), findsNothing);
  });
}
