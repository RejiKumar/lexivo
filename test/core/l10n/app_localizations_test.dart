import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/l10n/l10n.dart';

void main() {
  testWidgets('AppLocalizations loads for en', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return Text(l10n.appTitle);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(l10n.localeName, 'en');
    expect(l10n.appTitle, 'Lexivo');
    expect(l10n.signInTitle, 'Sign in');
    expect(find.text('Lexivo'), findsOneWidget);
  });
}
