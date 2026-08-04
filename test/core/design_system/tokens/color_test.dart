import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';

void main() {
  group('LexivoColors light', () {
    final colors = LexivoColors.light();

    test('background tokens match brand light palette', () {
      expect(colors.backgroundDefault, const Color(0xFFF8FAFC));
      expect(colors.backgroundSurface, const Color(0xFFFFFFFF));
      expect(colors.backgroundSurfaceElevated, const Color(0xFFFFFFFF));
      expect(colors.backgroundInverse, const Color(0xFF0F172A));
    });

    test('content tokens match brand light palette', () {
      expect(colors.contentPrimary, const Color(0xFF0F172A));
      expect(colors.contentSecondary, const Color(0xFF475569));
      expect(colors.contentDisabled, const Color(0xFF94A3B8));
      expect(colors.contentOnInverse, const Color(0xFFF8FAFC));
    });

    test('border and brand tokens match brand light palette', () {
      expect(colors.borderDefault, const Color(0xFFE2E8F0));
      expect(colors.borderFocus, const Color(0xFF0F766E));
      expect(colors.brandPrimary, const Color(0xFF0F766E));
      expect(colors.brandPrimaryHover, const Color(0xFF0D9488));
      expect(colors.brandPrimaryPressed, const Color(0xFF115E59));
    });

    test('feedback tokens match brand light palette', () {
      expect(colors.feedbackSuccess, const Color(0xFF15803D));
      expect(colors.feedbackWarning, const Color(0xFFB45309));
      expect(colors.feedbackDanger, const Color(0xFFDC2626));
      expect(colors.feedbackInfo, const Color(0xFF0369A1));
    });

    test('overlayScrim is tokenized dark barrier', () {
      expect(colors.overlayScrim, const Color(0x8A000000));
    });
  });

  group('LexivoColors dark', () {
    final colors = LexivoColors.dark();

    test('background tokens match brand dark palette', () {
      expect(colors.backgroundDefault, const Color(0xFF0B1220));
      expect(colors.backgroundSurface, const Color(0xFF111827));
      expect(colors.backgroundSurfaceElevated, const Color(0xFF1E293B));
      expect(colors.backgroundInverse, const Color(0xFFF8FAFC));
    });

    test('content tokens match brand dark palette', () {
      expect(colors.contentPrimary, const Color(0xFFF1F5F9));
      expect(colors.contentSecondary, const Color(0xFF94A3B8));
      expect(colors.contentDisabled, const Color(0xFF64748B));
      expect(colors.contentOnInverse, const Color(0xFF0F172A));
    });

    test('border and brand tokens match brand dark palette', () {
      expect(colors.borderDefault, const Color(0xFF334155));
      expect(colors.borderFocus, const Color(0xFF2DD4BF));
      expect(colors.brandPrimary, const Color(0xFF2DD4BF));
      expect(colors.brandPrimaryHover, const Color(0xFF5EEAD4));
      expect(colors.brandPrimaryPressed, const Color(0xFF14B8A6));
    });

    test('feedback tokens match brand dark palette', () {
      expect(colors.feedbackSuccess, const Color(0xFF4ADE80));
      expect(colors.feedbackWarning, const Color(0xFFFBBF24));
      expect(colors.feedbackDanger, const Color(0xFFF87171));
      expect(colors.feedbackInfo, const Color(0xFF38BDF8));
    });

    test('overlayScrim is tokenized dark barrier', () {
      expect(colors.overlayScrim, const Color(0x8A000000));
    });
  });

  group('ThemeExtension<LexivoColors>', () {
    testWidgets('resolves light extension from ThemeData', (tester) async {
      late LexivoColors? resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: [LexivoColors.light()],
          ),
          home: Builder(
            builder: (context) {
              resolved = Theme.of(context).extension<LexivoColors>();
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, isNotNull);
      expect(resolved!.brandPrimary, const Color(0xFF0F766E));
      expect(resolved!.backgroundDefault, const Color(0xFFF8FAFC));
    });

    testWidgets('resolves dark extension from ThemeData', (tester) async {
      late LexivoColors? resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            extensions: [LexivoColors.dark()],
          ),
          home: Builder(
            builder: (context) {
              resolved = Theme.of(context).extension<LexivoColors>();
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, isNotNull);
      expect(resolved!.brandPrimary, const Color(0xFF2DD4BF));
      expect(resolved!.backgroundDefault, const Color(0xFF0B1220));
    });

    test('lerp returns identical instance at t=0 and other at t=1', () {
      final light = LexivoColors.light();
      final dark = LexivoColors.dark();
      expect(light.lerp(dark, 0), same(light));
      expect(light.lerp(dark, 1), same(dark));
    });

    test('copyWith overrides selected fields', () {
      final original = LexivoColors.light();
      final updated = original.copyWith(
        brandPrimary: const Color(0xFF123456),
      );
      expect(updated.brandPrimary, const Color(0xFF123456));
      expect(updated.contentPrimary, original.contentPrimary);
    });
  });
}
