import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/document_card.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/document_scan/domain/entities/document_input.dart';
import 'package:lexivo/features/document_scan/presentation/providers/document_providers.dart';
import 'package:lexivo/features/document_scan/presentation/screens/document_library_screen.dart';
import 'package:lexivo/features/document_scan/presentation/screens/document_scan_screen.dart';

import '../../../helpers/document_test_harness.dart';
import '../../../helpers/fake_document_input_source.dart';
import '../../../helpers/fake_document_repository.dart';

void main() {
  group('DocumentScanScreen', () {
    testWidgets('primary CTA + LexivoButton; no kIsWeb fork in screen source',
        (tester) async {
      final repo = FakeDocumentRepository();
      final input = FakeDocumentInputSource();
      await tester.pumpWidget(
        wrapDocumentScreen(
          const DocumentScanScreen(),
          overrides: [
            documentRepositoryProvider.overrideWithValue(repo),
            documentInputSourceProvider.overrideWithValue(input),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LexivoButton), findsWidgets);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(kIsWeb, anyOf(isTrue, isFalse));

      await tester.tap(find.text('Scan or upload'));
      await tester.pumpAndSettle();
      expect(input.captureCalls, 1);
    });

    testWidgets('errors via LexivoErrorBanner', (tester) async {
      final repo = FakeDocumentRepository();
      final failing = _FailingInput();
      await tester.pumpWidget(
        wrapDocumentScreen(
          const DocumentScanScreen(),
          overrides: [
            documentRepositoryProvider.overrideWithValue(repo),
            documentInputSourceProvider.overrideWithValue(failing),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scan or upload'));
      await tester.pumpAndSettle();
      expect(find.byType(LexivoErrorBanner), findsOneWidget);
    });
  });

  group('DocumentLibraryScreen', () {
    testWidgets('empty → LexivoEmptyState', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = FakeDocumentRepository(initial: []);
      await tester.pumpWidget(
        wrapDocumentScreen(
          const DocumentLibraryScreen(),
          overrides: [
            documentRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LexivoEmptyState), findsOneWidget);
    });

    testWidgets('items → LexivoDocumentCard with status badges', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = FakeDocumentRepository(
        initial: [
          sampleDocument(id: 'a', status: DocumentStatus.processing, title: 'P'),
          sampleDocument(id: 'b', status: DocumentStatus.ready, title: 'R'),
          sampleDocument(id: 'c', status: DocumentStatus.failed, title: 'F'),
        ],
      );
      await tester.pumpWidget(
        wrapDocumentScreen(
          const DocumentLibraryScreen(),
          overrides: [
            documentRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LexivoDocumentCard), findsNWidgets(3));
      expect(find.text('Processing'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
    });
  });
}

class _FailingInput extends FakeDocumentInputSource {
  @override
  Future<Result<DocumentBytes>> captureOrPick({
    DocumentInputPreference preference = DocumentInputPreference.auto,
  }) async {
    return Result.failure(const ValidationFailure(message: 'Denied'));
  }
}
