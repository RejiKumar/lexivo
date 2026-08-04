import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/design_system/tokens/contrast.dart';

void main() {
  group('WCAG AA contrast — light', () {
    final c = LexivoColors.light();

    test('content.primary on background.default', () {
      expect(
        LexivoContrast.ratio(c.contentPrimary, c.backgroundDefault),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('content.primary on background.surface', () {
      expect(
        LexivoContrast.ratio(c.contentPrimary, c.backgroundSurface),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('content.secondary on background.default', () {
      expect(
        LexivoContrast.ratio(c.contentSecondary, c.backgroundDefault),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('content.onInverse on brand.primary (button label)', () {
      expect(
        LexivoContrast.ratio(c.contentOnInverse, c.brandPrimary),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('brand.primary on background.default (links / accents)', () {
      expect(
        LexivoContrast.ratio(c.brandPrimary, c.backgroundDefault),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('content.onInverse on background.inverse', () {
      expect(
        LexivoContrast.ratio(c.contentOnInverse, c.backgroundInverse),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('feedback.danger on background.default', () {
      expect(
        LexivoContrast.ratio(c.feedbackDanger, c.backgroundDefault),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('feedback.success on background.default', () {
      expect(
        LexivoContrast.ratio(c.feedbackSuccess, c.backgroundDefault),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });
  });

  group('WCAG AA contrast — dark', () {
    final c = LexivoColors.dark();

    test('content.primary on background.default', () {
      expect(
        LexivoContrast.ratio(c.contentPrimary, c.backgroundDefault),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('content.primary on background.surface', () {
      expect(
        LexivoContrast.ratio(c.contentPrimary, c.backgroundSurface),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('content.secondary on background.default', () {
      expect(
        LexivoContrast.ratio(c.contentSecondary, c.backgroundDefault),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('content.onInverse on brand.primary (button label)', () {
      expect(
        LexivoContrast.ratio(c.contentOnInverse, c.brandPrimary),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('brand.primary on background.default (links / accents)', () {
      expect(
        LexivoContrast.ratio(c.brandPrimary, c.backgroundDefault),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('content.onInverse on background.inverse', () {
      expect(
        LexivoContrast.ratio(c.contentOnInverse, c.backgroundInverse),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('feedback.danger on background.default', () {
      expect(
        LexivoContrast.ratio(c.feedbackDanger, c.backgroundDefault),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });

    test('feedback.success on background.default', () {
      expect(
        LexivoContrast.ratio(c.feedbackSuccess, c.backgroundDefault),
        greaterThanOrEqualTo(LexivoContrast.aaNormal),
      );
    });
  });
}
