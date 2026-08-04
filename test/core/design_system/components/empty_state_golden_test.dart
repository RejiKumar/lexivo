import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  goldenTest(
    'LexivoEmptyState variants',
    fileName: 'lexivo_empty_state',
    builder: () => Theme(
      data: AppTheme.light,
      child: ColoredBox(
        color: LexivoColors.light().backgroundDefault,
        child: GoldenTestGroup(
          columns: 2,
          children: [
            GoldenTestScenario(
              name: 'with icon no cta',
              child: const SizedBox(
                width: 320,
                child: LexivoEmptyState(
                  title: 'No chats',
                  description: 'Start a conversation about your documents.',
                  icon: Icons.chat_bubble_outline,
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'with illustration and cta',
              child: SizedBox(
                width: 320,
                child: LexivoEmptyState(
                  title: 'No documents',
                  description: 'Upload a PDF or scan a page.',
                  illustration: Icon(
                    Icons.folder_open,
                    size: 56,
                    color: LexivoColors.light().brandPrimary,
                  ),
                  ctaLabel: 'Upload',
                  onCtaPressed: () {},
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'text only',
              child: const SizedBox(
                width: 320,
                child: LexivoEmptyState(
                  title: 'Nothing found',
                  description: 'Try a different search query.',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
