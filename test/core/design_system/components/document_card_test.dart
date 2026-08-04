import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/badge.dart';
import 'package:lexivo/core/design_system/components/card.dart';
import 'package:lexivo/core/design_system/components/document_card.dart';

import 'harness.dart';

void main() {
  group('LexivoDocumentCard', () {
    testWidgets('renders name, timestamp, and status badge', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoDocumentCard(
            name: 'Contract.pdf',
            status: LexivoDocumentStatus.ready,
            timestamp: '2h ago',
          ),
        ),
      );

      expect(find.text('Contract.pdf'), findsOneWidget);
      expect(find.text('2h ago'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.byType(LexivoBadge), findsOneWidget);
      expect(find.byType(LexivoCard), findsOneWidget);
    });

    testWidgets('processing and failed badge labels', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoDocumentCard(
            name: 'Scan.jpg',
            status: LexivoDocumentStatus.processing,
            timestamp: 'Just now',
          ),
        ),
      );
      expect(find.text('Processing'), findsOneWidget);

      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoDocumentCard(
            name: 'Broken.pdf',
            status: LexivoDocumentStatus.failed,
            timestamp: 'Yesterday',
          ),
        ),
      );
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('thumbnail slot and missing-thumbnail fallback', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoDocumentCard(
            name: 'No thumb',
            status: LexivoDocumentStatus.ready,
            timestamp: '1d ago',
          ),
        ),
      );
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);

      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoDocumentCard(
            name: 'With thumb',
            status: LexivoDocumentStatus.ready,
            timestamp: '1d ago',
            thumbnail: ColoredBox(
              color: Colors.teal.shade100,
              child: const Icon(Icons.picture_as_pdf),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    testWidgets('onTap fires via interactive card', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoDocumentCard(
            name: 'Tap me.pdf',
            status: LexivoDocumentStatus.ready,
            timestamp: 'Now',
            onTap: () => taps++,
          ),
        ),
      );
      await tester.tap(find.text('Tap me.pdf'));
      expect(taps, 1);
    });
  });
}
