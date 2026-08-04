import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  group('AppTheme / LexivoTheme assembly', () {
    test('light ThemeData exposes LexivoColors light tokens', () {
      final theme = AppTheme.light;
      final colors = theme.extension<LexivoColors>();

      expect(theme.brightness, Brightness.light);
      expect(colors, isNotNull);
      expect(colors!.brandPrimary, LexivoColors.light().brandPrimary);
      expect(colors.backgroundDefault, LexivoColors.light().backgroundDefault);
      expect(theme.scaffoldBackgroundColor, colors.backgroundDefault);
      expect(theme.colorScheme.primary, colors.brandPrimary);
    });

    test('dark ThemeData exposes LexivoColors dark tokens', () {
      final theme = AppTheme.dark;
      final colors = theme.extension<LexivoColors>();

      expect(theme.brightness, Brightness.dark);
      expect(colors, isNotNull);
      expect(colors!.brandPrimary, LexivoColors.dark().brandPrimary);
      expect(colors.backgroundDefault, LexivoColors.dark().backgroundDefault);
      expect(theme.scaffoldBackgroundColor, colors.backgroundDefault);
      expect(theme.colorScheme.primary, colors.brandPrimary);
    });

    test('light and dark themes use typography from tokens', () {
      expect(
        AppTheme.light.textTheme.bodyMedium?.fontSize,
        LexivoTypography.body.fontSize,
      );
      expect(
        AppTheme.dark.textTheme.headlineMedium?.fontSize,
        LexivoTypography.headline.fontSize,
      );
      expect(
        AppTheme.light.textTheme.labelLarge?.letterSpacing,
        LexivoTypography.label.letterSpacing,
      );
    });

    testWidgets('themeMode switch resolves matching LexivoColors', (tester) async {
      final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

      await tester.pumpWidget(
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeMode,
          builder: (context, mode, _) {
            return MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: mode,
              home: Builder(
                builder: (context) {
                  final colors = Theme.of(context).extension<LexivoColors>()!;
                  return Text(
                    '${Theme.of(context).brightness}|${colors.brandPrimary.toARGB32()}',
                  );
                },
              ),
            );
          },
        ),
      );

      expect(
        find.text(
          'Brightness.light|${LexivoColors.light().brandPrimary.toARGB32()}',
        ),
        findsOneWidget,
      );

      themeMode.value = ThemeMode.dark;
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Brightness.dark|${LexivoColors.dark().brandPrimary.toARGB32()}',
        ),
        findsOneWidget,
      );
    });
  });
}
