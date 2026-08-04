import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/input.dart';

import 'harness.dart';

void main() {
  group('LexivoTextField', () {
    testWidgets('text variant renders label and hint', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoTextField(
            label: 'Email',
            hintText: 'you@lexivo.app',
          ),
        ),
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('you@lexivo.app'), findsOneWidget);
    });

    testWidgets('multiline allows multiple lines', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoTextField(
            variant: LexivoTextFieldVariant.multiline,
            hintText: 'Notes',
          ),
        ),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.minLines, 3);
      expect(field.maxLines, isNull);
    });

    testWidgets('search shows leading icon and clear when text present',
        (tester) async {
      final controller = TextEditingController(text: 'query');
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoTextField(
            variant: LexivoTextFieldVariant.search,
            controller: controller,
            hintText: 'Search',
          ),
        ),
      );
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(controller.text, isEmpty);
    });

    testWidgets('shows error helper text', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoTextField(
            label: 'Name',
            errorText: 'Required',
          ),
        ),
      );
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('disabled prevents editing', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoTextField(
            enabled: false,
            hintText: 'Locked',
          ),
        ),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
    });

    testWidgets('focused state updates when focus gained', (tester) async {
      final focus = FocusNode();
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoTextField(
            focusNode: focus,
            hintText: 'Focus me',
          ),
        ),
      );
      expect(focus.hasFocus, isFalse);
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isTrue);
    });

    testWidgets('meets min height 44', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoTextField(hintText: 'Tall enough'),
        ),
      );
      final box = tester.getSize(find.byType(TextField));
      expect(box.height, greaterThanOrEqualTo(44));
    });
  });
}
