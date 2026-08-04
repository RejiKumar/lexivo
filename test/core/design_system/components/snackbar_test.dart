import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/snackbar.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  group('LexivoSnackbar', () {
    Future<void> pumpHost(WidgetTester tester, Widget home) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: home),
        ),
      );
    }

    testWidgets('show presents info snackbar via helper', (tester) async {
      await pumpHost(
        tester,
        Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => LexivoSnackbar.show(
                context,
                message: 'Saved',
                variant: LexivoSnackbarVariant.info,
              ),
              child: const Text('Go'),
            );
          },
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(LexivoSnackbarBody), findsNothing);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('show success and error variants', (tester) async {
      for (final variant in [
        LexivoSnackbarVariant.success,
        LexivoSnackbarVariant.error,
      ]) {
        await pumpHost(
          tester,
          Builder(
            builder: (context) {
              return TextButton(
                onPressed: () => LexivoSnackbar.show(
                  context,
                  message: variant.name,
                  variant: variant,
                ),
                child: Text('Show ${variant.name}'),
              );
            },
          ),
        );
        await tester.tap(find.text('Show ${variant.name}'));
        await tester.pumpAndSettle();
        expect(find.text(variant.name), findsOneWidget);
        ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
            .hideCurrentSnackBar();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('body widget renders message for each variant', (tester) async {
      for (final variant in LexivoSnackbarVariant.values) {
        await pumpHost(
          tester,
          LexivoSnackbarBody(message: variant.name, variant: variant),
        );
        expect(find.text(variant.name), findsOneWidget);
      }
    });
  });
}
