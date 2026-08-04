import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/design_system/components/skeleton_loader.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/summarization/presentation/providers/summarization_providers.dart';
import 'package:lexivo/features/summarization/summarization.dart';

import '../../../helpers/fake_summarization_repository.dart';
import '../../../helpers/summarization_test_harness.dart';

void main() {
  group('SummaryScreen', () {
    testWidgets('ready → short + detailed sections', (tester) async {
      final repo = FakeSummarizationRepository(
        initial: [sampleSummaryDocument()],
      );
      await tester.pumpWidget(
        wrapSummaryScreen(
          const SummaryScreen(documentId: 'doc-1'),
          overrides: [
            summarizationRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Short summary'), findsOneWidget);
      expect(find.text('Detailed summary'), findsOneWidget);
      expect(find.textContaining('Lease covers'), findsOneWidget);
      expect(find.textContaining('rental term'), findsOneWidget);
    });

    testWidgets('empty ready → LexivoEmptyState', (tester) async {
      final repo = FakeSummarizationRepository(
        initial: [
          sampleSummaryDocument(
            shortSummary: null,
            detailedSummary: null,
          ),
        ],
      );
      await tester.pumpWidget(
        wrapSummaryScreen(
          const SummaryScreen(documentId: 'doc-1'),
          overrides: [
            summarizationRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LexivoEmptyState), findsOneWidget);
      expect(find.text('No summaries yet'), findsOneWidget);
    });

    testWidgets('failed → LexivoErrorBanner with retry', (tester) async {
      final repo = FakeSummarizationRepository(
        initial: [
          sampleSummaryDocument(
            summaryStatus: SummaryStatus.failed,
            shortSummary: null,
            detailedSummary: null,
          ),
        ],
      );
      await tester.pumpWidget(
        wrapSummaryScreen(
          const SummaryScreen(documentId: 'doc-1'),
          overrides: [
            summarizationRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LexivoErrorBanner), findsOneWidget);
    });

    testWidgets('not-ready → clear error copy', (tester) async {
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

      await tester.pumpWidget(
        wrapSummaryScreen(
          const SummaryScreen(documentId: 'doc-1'),
          overrides: [
            summarizationRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LexivoErrorBanner), findsOneWidget);
      expect(find.textContaining('not ready'), findsOneWidget);
    });

    testWidgets('processing → skeleton affordance', (tester) async {
      final repo = FakeSummarizationRepository(
        initial: [
          sampleSummaryDocument(
            summaryStatus: SummaryStatus.processing,
            shortSummary: null,
            detailedSummary: null,
          ),
        ],
      );
      repo.statusSequence.addAll([
        SummaryStatus.processing,
        SummaryStatus.processing,
        SummaryStatus.processing,
        SummaryStatus.ready,
      ]);
      repo.documents[0] = sampleSummaryDocument();

      await tester.pumpWidget(
        wrapSummaryScreen(
          const SummaryScreen(documentId: 'doc-1'),
          overrides: [
            summarizationRepositoryProvider.overrideWithValue(repo),
            summaryJobPollerProvider.overrideWithValue(
              const JobPoller(
                interval: Duration(milliseconds: 80),
                timeout: Duration(seconds: 5),
              ),
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));

      expect(find.byType(LexivoSkeleton), findsWidgets);
      expect(find.textContaining('Generating summaries'), findsOneWidget);
      expect(find.textContaining('Lease covers'), findsNothing);

      await tester.pumpAndSettle();
      expect(find.textContaining('Lease covers'), findsOneWidget);
    });
  });
}
