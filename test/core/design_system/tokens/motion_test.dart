import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/tokens/motion.dart';

void main() {
  group('LexivoMotion', () {
    test('fast is 120ms easeOut', () {
      expect(LexivoMotion.fast.duration, const Duration(milliseconds: 120));
      expect(LexivoMotion.fast.curve, Curves.easeOut);
    });

    test('standard is 200ms easeInOut', () {
      expect(LexivoMotion.standard.duration, const Duration(milliseconds: 200));
      expect(LexivoMotion.standard.curve, Curves.easeInOut);
    });

    test('slow is 300ms easeInOutCubic', () {
      expect(LexivoMotion.slow.duration, const Duration(milliseconds: 300));
      expect(LexivoMotion.slow.curve, Curves.easeInOutCubic);
    });
  });
}
