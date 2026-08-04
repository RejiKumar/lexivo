import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/tokens/icon_size.dart';
import 'package:lexivo/core/design_system/tokens/radius.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';

void main() {
  group('LexivoSpacing', () {
    test('exposes 8pt scale per §2.2 plus micro hairline', () {
      expect(LexivoSpacing.micro, 2);
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

  group('LexivoIconSize', () {
    test('exposes named icon sizes', () {
      expect(LexivoIconSize.sm, 16);
      expect(LexivoIconSize.md, 22);
      expect(LexivoIconSize.lg, 24);
    });
  });
}
