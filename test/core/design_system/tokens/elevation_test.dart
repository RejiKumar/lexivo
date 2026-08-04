import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/tokens/elevation.dart';

void main() {
  group('LexivoElevation', () {
    test('level 0 is flat (no shadows)', () {
      expect(LexivoElevation.level0, isEmpty);
    });

    test('level 1 is a single resting card shadow', () {
      final shadows = LexivoElevation.level1;
      expect(shadows, hasLength(1));
      expect(shadows.single.blurRadius, 4);
      expect(shadows.single.offset, const Offset(0, 1));
      expect(shadows.single.spreadRadius, 0);
    });

    test('level 2 is hover/pressed / dropdown shadow', () {
      final shadows = LexivoElevation.level2;
      expect(shadows, hasLength(1));
      expect(shadows.single.blurRadius, 8);
      expect(shadows.single.offset, const Offset(0, 4));
    });

    test('level 3 is modal / bottom sheet shadow', () {
      final shadows = LexivoElevation.level3;
      expect(shadows, hasLength(1));
      expect(shadows.single.blurRadius, 24);
      expect(shadows.single.offset, const Offset(0, 12));
    });

    test('named presets are stable BoxShadow lists (no ad-hoc values)', () {
      expect(identical(LexivoElevation.level1, LexivoElevation.level1), isTrue);
      expect(LexivoElevation.level0, same(LexivoElevation.level0));
    });
  });
}
