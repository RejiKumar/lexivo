import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';

import 'harness.dart';

void main() {
  group('LexivoErrorBanner', () {
    testWidgets('shows message', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoErrorBanner(message: 'Something failed'),
        ),
      );
      expect(find.text('Something failed'), findsOneWidget);
    });

    testWidgets('retry callback fires', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoErrorBanner(
            message: 'Oops',
            onRetry: () => retries++,
          ),
        ),
      );
      await tester.tap(find.text('Retry'));
      expect(retries, 1);
    });

    testWidgets('dismiss callback fires', (tester) async {
      var dismissed = 0;
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoErrorBanner(
            message: 'Oops',
            onDismiss: () => dismissed++,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, 1);
    });

    testWidgets('retry and dismiss both present', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoErrorBanner(
            message: 'Both',
            onRetry: () {},
            onDismiss: () {},
          ),
        ),
      );
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
