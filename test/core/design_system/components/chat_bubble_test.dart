import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/chat_bubble.dart';

import 'harness.dart';

void main() {
  group('LexivoChatBubble', () {
    testWidgets('user variant aligns message', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoChatBubble(
            variant: LexivoChatBubbleVariant.user,
            message: 'Summarize this PDF',
          ),
        ),
      );

      expect(find.text('Summarize this PDF'), findsOneWidget);
      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('assistant variant aligns left', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoChatBubble(
            variant: LexivoChatBubbleVariant.assistant,
            message: 'Here is a summary.',
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('assistantStreaming shows streaming indicator', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoChatBubble(
            variant: LexivoChatBubbleVariant.assistantStreaming,
            message: 'Thinking',
            animateStreaming: false,
          ),
        ),
      );

      expect(find.text('Thinking'), findsOneWidget);
      expect(find.byType(LexivoChatBubble), findsOneWidget);
    });

    testWidgets('citation chips slot is generic', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoChatBubble(
            variant: LexivoChatBubbleVariant.assistant,
            message: 'Cited answer',
            citationChips: Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('Doc A')),
                Chip(label: Text('Doc B')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Doc A'), findsOneWidget);
      expect(find.text('Doc B'), findsOneWidget);
    });
  });
}
