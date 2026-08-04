import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/dialog.dart';

import 'harness.dart';

void main() {
  group('LexivoDialog', () {
    testWidgets('confirmation shows title, body, and two LexivoButton actions',
        (tester) async {
      var confirmed = 0;
      var cancelled = 0;
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoDialog(
            variant: LexivoDialogVariant.confirmation,
            title: 'Delete document?',
            body: 'This cannot be undone.',
            primaryLabel: 'Delete',
            onPrimary: () => confirmed++,
            secondaryLabel: 'Cancel',
            onSecondary: () => cancelled++,
          ),
        ),
      );

      expect(find.text('Delete document?'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);
      expect(find.byType(LexivoButton), findsNWidgets(2));

      await tester.tap(find.text('Cancel'));
      expect(cancelled, 1);
      await tester.tap(find.text('Delete'));
      expect(confirmed, 1);
    });

    testWidgets('alert shows single action', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoDialog(
            variant: LexivoDialogVariant.alert,
            title: 'Upload complete',
            body: 'Your file is ready.',
            primaryLabel: 'OK',
            onPrimary: () => taps++,
          ),
        ),
      );

      expect(find.text('Upload complete'), findsOneWidget);
      expect(find.byType(LexivoButton), findsOneWidget);
      await tester.tap(find.text('OK'));
      expect(taps, 1);
    });

    testWidgets('custom renders content slot', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoDialog(
            variant: LexivoDialogVariant.custom,
            content: const Text('Custom dialog body'),
          ),
        ),
      );

      expect(find.text('Custom dialog body'), findsOneWidget);
      expect(find.byType(LexivoButton), findsNothing);
    });

    testWidgets('show presents dialog via overlay', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LexivoDialog.show(
                    context,
                    variant: LexivoDialogVariant.alert,
                    title: 'Shown',
                    primaryLabel: 'Close',
                    onPrimary: () => Navigator.of(context).pop(),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Shown'), findsOneWidget);
    });
  });
}
