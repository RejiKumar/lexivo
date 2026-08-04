import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';

void main() {
  group('LexivoTypography', () {
    late TextTheme theme;

    setUp(() {
      theme = LexivoTypography.textTheme();
    });

    test('display is 32/40 weight 700 with Sora', () {
      final style = LexivoTypography.display;
      expect(style.fontSize, 32);
      expect(style.height, closeTo(40 / 32, 0.001));
      expect(style.fontWeight, FontWeight.w700);
      expect(style.fontFamily, contains('Sora'));
    });

    test('headline is 24/32 weight 700 with Plus Jakarta Sans', () {
      final style = LexivoTypography.headline;
      expect(style.fontSize, 24);
      expect(style.height, closeTo(32 / 24, 0.001));
      expect(style.fontWeight, FontWeight.w700);
      expect(style.fontFamily, contains('PlusJakartaSans'));
    });

    test('title is 18/24 weight 600', () {
      final style = LexivoTypography.title;
      expect(style.fontSize, 18);
      expect(style.height, closeTo(24 / 18, 0.001));
      expect(style.fontWeight, FontWeight.w600);
    });

    test('body is 16/24 weight 400', () {
      final style = LexivoTypography.body;
      expect(style.fontSize, 16);
      expect(style.height, closeTo(24 / 16, 0.001));
      expect(style.fontWeight, FontWeight.w400);
    });

    test('bodyStrong is 16/24 weight 600', () {
      final style = LexivoTypography.bodyStrong;
      expect(style.fontSize, 16);
      expect(style.height, closeTo(24 / 16, 0.001));
      expect(style.fontWeight, FontWeight.w600);
    });

    test('caption is 13/18 weight 400', () {
      final style = LexivoTypography.caption;
      expect(style.fontSize, 13);
      expect(style.height, closeTo(18 / 13, 0.001));
      expect(style.fontWeight, FontWeight.w400);
    });

    test('label is 13/18 weight 600 letter-spacing 0.2', () {
      final style = LexivoTypography.label;
      expect(style.fontSize, 13);
      expect(style.height, closeTo(18 / 13, 0.001));
      expect(style.fontWeight, FontWeight.w600);
      expect(style.letterSpacing, 0.2);
    });

    test('TextTheme maps scale roles', () {
      expect(theme.displayLarge?.fontSize, LexivoTypography.display.fontSize);
      expect(theme.headlineMedium?.fontSize, LexivoTypography.headline.fontSize);
      expect(theme.titleMedium?.fontSize, LexivoTypography.title.fontSize);
      expect(theme.bodyMedium?.fontSize, LexivoTypography.body.fontSize);
      expect(theme.bodyLarge?.fontWeight, FontWeight.w600);
      expect(theme.bodySmall?.fontSize, LexivoTypography.caption.fontSize);
      expect(theme.labelLarge?.letterSpacing, 0.2);
    });
  });
}
