import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/card.dart';
import 'package:lexivo/core/design_system/tokens/elevation.dart';

import 'harness.dart';

void main() {
  group('LexivoCard', () {
    testWidgets('flat has border and no elevation shadow', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoCard(
            variant: LexivoCardVariant.flat,
            child: Text('Flat'),
          ),
        ),
      );
      expect(find.text('Flat'), findsOneWidget);
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.boxShadow, LexivoElevation.level0);
      expect(decoration.border, isNotNull);
    });

    testWidgets('elevated uses level1 shadow', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoCard(
            variant: LexivoCardVariant.elevated,
            child: Text('Elevated'),
          ),
        ),
      );
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.boxShadow, LexivoElevation.level1);
    });

    testWidgets('interactive presses to level2 elevation', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoCard(
            variant: LexivoCardVariant.interactive,
            onTap: () => taps++,
            child: const Text('Press me'),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Press me')),
      );
      await tester.pump();

      final pressed = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(
        (pressed.decoration! as BoxDecoration).boxShadow,
        LexivoElevation.level2,
      );

      await gesture.up();
      await tester.pumpAndSettle();
      expect(taps, 1);

      final resting = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(
        (resting.decoration! as BoxDecoration).boxShadow,
        LexivoElevation.level1,
      );
    });
  });
}
