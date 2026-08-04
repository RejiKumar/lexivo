import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/components/chat_bubble.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/design_system/tokens/radius.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/theming/app_theme.dart';

Widget _chip(String label) {
  final colors = LexivoColors.light();
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: LexivoSpacing.xs,
      vertical: LexivoSpacing.xxs,
    ),
    decoration: BoxDecoration(
      color: colors.brandPrimary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(LexivoRadius.pill),
    ),
    child: Text(
      label,
      style: LexivoTypography.caption.copyWith(color: colors.brandPrimary),
    ),
  );
}

void main() {
  goldenTest(
    'LexivoChatBubble variants',
    fileName: 'lexivo_chat_bubble',
    builder: () => Theme(
      data: AppTheme.light,
      child: ColoredBox(
        color: LexivoColors.light().backgroundDefault,
        child: GoldenTestGroup(
          columns: 1,
          children: [
            GoldenTestScenario(
              name: 'user',
              child: const SizedBox(
                width: 360,
                child: LexivoChatBubble(
                  variant: LexivoChatBubbleVariant.user,
                  message: 'What does section 2 say?',
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'assistant',
              child: const SizedBox(
                width: 360,
                child: LexivoChatBubble(
                  variant: LexivoChatBubbleVariant.assistant,
                  message: 'Section 2 covers onboarding and setup steps.',
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'assistantStreaming',
              child: const SizedBox(
                width: 360,
                child: LexivoChatBubble(
                  variant: LexivoChatBubbleVariant.assistantStreaming,
                  message: 'Drafting a reply',
                  animateStreaming: false,
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'assistant with citations',
              child: SizedBox(
                width: 360,
                child: LexivoChatBubble(
                  variant: LexivoChatBubbleVariant.assistant,
                  message: 'Based on your documents:',
                  citationChips: Wrap(
                    spacing: LexivoSpacing.xs,
                    runSpacing: LexivoSpacing.xs,
                    children: [_chip('Guide.pdf p.3'), _chip('Notes.md')],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
