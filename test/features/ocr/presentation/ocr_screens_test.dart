import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/design_system/components/skeleton_loader.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/features/ocr/ocr.dart';
import 'package:lexivo/features/ocr/presentation/providers/ocr_providers.dart';

import '../../../helpers/fake_ocr_repository.dart';
import '../../../helpers/ocr_test_harness.dart';

void main() {
  group('OcrResultScreen', () {
    testWidgets('ready → scrollable extracted text', (tester) async {
      final repo = FakeOcrRepository(initial: [sampleOcrDocument()]);
      await tester.pumpWidget(
        wrapOcrScreen(
          const OcrResultScreen(documentId: 'doc-1'),
          overrides: [
            ocrRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Extracted OCR body'),
        findsOneWidget,
      );
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('empty ready text → LexivoEmptyState', (tester) async {
      final repo = FakeOcrRepository(
        initial: [
          sampleOcrDocument(extractedText: null),
        ],
      );
      await tester.pumpWidget(
        wrapOcrScreen(
          const OcrResultScreen(documentId: 'doc-1'),
          overrides: [
            ocrRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LexivoEmptyState), findsOneWidget);
      expect(find.text('No text extracted'), findsOneWidget);
    });

    testWidgets('failed → LexivoErrorBanner with retry', (tester) async {
      final repo = FakeOcrRepository(
        initial: [
          sampleOcrDocument(status: DocumentStatus.failed, extractedText: null),
        ],
      );
      await tester.pumpWidget(
        wrapOcrScreen(
          const OcrResultScreen(documentId: 'doc-1'),
          overrides: [
            ocrRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LexivoErrorBanner), findsOneWidget);
      expect(find.textContaining('OCR failed'), findsOneWidget);
    });

    testWidgets('processing → skeleton / processing copy', (tester) async {
      final repo = FakeOcrRepository(
        initial: [
          sampleOcrDocument(
            status: DocumentStatus.processing,
            extractedText: null,
          ),
        ],
      );
      // Stay processing long enough to assert loading UI.
      repo.statusSequence.addAll([
        DocumentStatus.processing,
        DocumentStatus.processing,
        DocumentStatus.processing,
        DocumentStatus.ready,
      ]);
      repo.documents[0] = sampleOcrDocument(
        status: DocumentStatus.ready,
        extractedText: 'Done',
      );

      await tester.pumpWidget(
        wrapOcrScreen(
          const OcrResultScreen(documentId: 'doc-1'),
          overrides: [
            ocrRepositoryProvider.overrideWithValue(repo),
            ocrJobPollerProvider.overrideWithValue(
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
      expect(find.textContaining('Processing'), findsOneWidget);
      expect(find.text('Done'), findsNothing);

      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);
    });
  });
}
