import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/tokens/radius.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';

void main() {
  group('LexivoSpacing', () {
    test('exposes 8pt scale per §2.2', () {
      expect(LexivoSpacing.xxs, 4);
      expect(LexivoSpacing.xs, 8);
      expect(LexivoSpacing.sm, 12);
      expect(LexivoSpacing.md, 16);
      expect(LexivoSpacing.lg, 24);
      expect(LexivoSpacing.xl, 32);
      expect(LexivoSpacing.xxl, 48);
    });
  });

  group('LexivoRadius', () {
    test('exposes radius scale per §2.3', () {
      expect(LexivoRadius.sm, 8);
      expect(LexivoRadius.md, 12);
      expect(LexivoRadius.lg, 16);
      expect(LexivoRadius.pill, 999);
    });
  });
}
