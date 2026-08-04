import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';

import 'harness.dart';

void main() {
  group('LexivoEmptyState', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoEmptyState(
            title: 'No documents',
            description: 'Upload your first file to get started.',
          ),
        ),
      );
      expect(find.text('No documents'), findsOneWidget);
      expect(
        find.text('Upload your first file to get started.'),
        findsOneWidget,
      );
    });

    testWidgets('renders icon slot', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoEmptyState(
            title: 'Empty',
            description: 'Nothing here',
            icon: Icons.inbox_outlined,
          ),
        ),
      );
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders illustration slot', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoEmptyState(
            title: 'Empty',
            description: 'Nothing here',
            illustration: FlutterLogo(size: 64),
          ),
        ),
      );
      expect(find.byType(FlutterLogo), findsOneWidget);
    });

    testWidgets('optional CTA uses LexivoButton', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoEmptyState(
            title: 'Empty',
            description: 'Add something',
            ctaLabel: 'Add document',
            onCtaPressed: () => taps++,
          ),
        ),
      );
      expect(find.byType(LexivoButton), findsOneWidget);
      await tester.tap(find.text('Add document'));
      expect(taps, 1);
    });
  });
}
