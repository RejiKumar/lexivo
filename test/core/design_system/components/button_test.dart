import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/button.dart';

import 'harness.dart';

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
  });
}
