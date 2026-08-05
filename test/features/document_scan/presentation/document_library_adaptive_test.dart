import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/features/document_scan/presentation/providers/document_providers.dart';
import 'package:lexivo/features/document_scan/presentation/screens/_document_library_shared.dart';
import 'package:lexivo/features/document_scan/presentation/screens/document_library_screen.dart';

import '../../../helpers/document_test_harness.dart';
import '../../../helpers/fake_document_repository.dart';

void main() {
  testWidgets('library uses mobile single-pane layout at ≤599', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = FakeDocumentRepository(
      initial: [
        sampleDocument(id: 'a', status: DocumentStatus.ready, title: 'Lease'),
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

    expect(find.byKey(DocumentLibraryLayoutKeys.mobile), findsOneWidget);
    expect(find.byKey(DocumentLibraryLayoutKeys.listPane), findsOneWidget);
    expect(find.byKey(DocumentLibraryLayoutKeys.detailPane), findsNothing);
    expect(find.byKey(DocumentLibraryLayoutKeys.desktop), findsNothing);
  });

  testWidgets('library uses desktop multi-pane layout at ≥1024', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = FakeDocumentRepository(
      initial: [
        sampleDocument(id: 'a', status: DocumentStatus.ready, title: 'Lease'),
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

    expect(find.byKey(DocumentLibraryLayoutKeys.desktop), findsOneWidget);
    expect(find.byKey(DocumentLibraryLayoutKeys.listPane), findsOneWidget);
    expect(find.byKey(DocumentLibraryLayoutKeys.detailPane), findsOneWidget);
    expect(find.byKey(DocumentLibraryLayoutKeys.mobile), findsNothing);
  });
}
