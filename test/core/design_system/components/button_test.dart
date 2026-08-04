import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';

import 'harness.dart';

Material _buttonMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find.descendant(
      of: find.byType(LexivoButton),
      matching: find.byType(Material),
    ),
  );
}

void main() {
  group('LexivoButton', () {
    testWidgets('renders label for each variant', (tester) async {
      for (final variant in LexivoButtonVariant.values) {
        await tester.pumpWidget(
          wrapWithLexivoTheme(
            child: LexivoButton(
              label: variant.name,
              variant: variant,
              onPressed: () {},
            ),
          ),
        );
        expect(find.text(variant.name), findsOneWidget);
      }
    });

    testWidgets('sizes sm/md/lg meet ≥44×44 touch target', (tester) async {
      for (final size in LexivoButtonSize.values) {
        await tester.pumpWidget(
          wrapWithLexivoTheme(
            child: LexivoButton(
              label: 'Go',
              size: size,
              onPressed: () {},
            ),
          ),
        );
        final box = tester.renderObject<RenderBox>(find.byType(LexivoButton));
        expect(box.size.width, greaterThanOrEqualTo(44));
        expect(box.size.height, greaterThanOrEqualTo(44));
      }
    });

    testWidgets('invokes onPressed when tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoButton(
            label: 'Tap',
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(LexivoButton));
      expect(taps, 1);
    });

    testWidgets('disabled does not invoke onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoButton(
            label: 'Nope',
            onPressed: () => taps++,
            enabled: false,
          ),
        ),
      );
      await tester.tap(find.byType(LexivoButton));
      expect(taps, 0);
    });

    testWidgets('loading shows spinner and hides label', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoButton(
            label: 'Save',
            onPressed: () {},
            loading: true,
          ),
        ),
      );
      expect(find.text('Save'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('loading does not invoke onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoButton(
            label: 'Save',
            onPressed: () => taps++,
            loading: true,
          ),
        ),
      );
      await tester.tap(find.byType(LexivoButton));
      expect(taps, 0);
    });

    testWidgets('leading and trailing icons render', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoButton(
            label: 'Next',
            onPressed: () {},
            leadingIcon: Icons.add,
            trailingIcon: Icons.arrow_forward,
          ),
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('fullWidth expands to parent width', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: SizedBox(
            width: 320,
            child: LexivoButton(
              label: 'Wide',
              onPressed: () {},
              fullWidth: true,
            ),
          ),
        ),
      );
      final box = tester.renderObject<RenderBox>(find.byType(LexivoButton));
      expect(box.size.width, 320);
    });

    testWidgets('pressed scales content via GestureDetector', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoButton(
            label: 'Press',
            onPressed: () {},
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(LexivoButton)),
      );
      await tester.pump();
      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scale.scale, lessThan(1));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('hover applies brandPrimaryHover on primary', (tester) async {
      final colors = LexivoColors.light();
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoButton(
            label: 'Hover',
            onPressed: () {},
          ),
        ),
      );

      expect(_buttonMaterial(tester).color, colors.brandPrimary);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.byType(LexivoButton)));
      await tester.pumpAndSettle();

      expect(_buttonMaterial(tester).color, colors.brandPrimaryHover);

      await gesture.moveTo(const Offset(-40, -40));
      await tester.pumpAndSettle();
      expect(_buttonMaterial(tester).color, colors.brandPrimary);
    });

    testWidgets('pressed takes precedence over hover on primary', (tester) async {
      final colors = LexivoColors.light();
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoButton(
            label: 'Press',
            onPressed: () {},
          ),
        ),
      );

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.byType(LexivoButton)));
      await tester.pumpAndSettle();
      expect(_buttonMaterial(tester).color, colors.brandPrimaryHover);

      final press = await tester.startGesture(
        tester.getCenter(find.byType(LexivoButton)),
      );
      await tester.pump();
      expect(_buttonMaterial(tester).color, colors.brandPrimaryPressed);
      await press.up();
      await tester.pumpAndSettle();
    });

    testWidgets('disabled ignores hover', (tester) async {
      final colors = LexivoColors.light();
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoButton(
            label: 'Nope',
            onPressed: () {},
            enabled: false,
          ),
        ),
      );

      final disabledBg = colors.contentDisabled.withValues(alpha: 0.24);
      expect(_buttonMaterial(tester).color, disabledBg);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.byType(LexivoButton)));
      await tester.pumpAndSettle();

      expect(_buttonMaterial(tester).color, disabledBg);
    });

    testWidgets('secondary hover uses brandPrimary tint', (tester) async {
      final colors = LexivoColors.light();
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoButton(
            label: 'Secondary',
            variant: LexivoButtonVariant.secondary,
            onPressed: () {},
          ),
        ),
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.byType(LexivoButton)));
      await tester.pumpAndSettle();

      expect(
        _buttonMaterial(tester).color,
        colors.brandPrimary.withValues(alpha: 0.06),
      );
    });
  });
}
