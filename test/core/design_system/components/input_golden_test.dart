import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/components/input.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  goldenTest(
    'LexivoTextField variants × key states',
    fileName: 'lexivo_text_field',
    builder: () => Theme(
      data: AppTheme.light,
      child: ColoredBox(
        color: LexivoColors.light().backgroundDefault,
        child: GoldenTestGroup(
          columns: 2,
          children: [
            GoldenTestScenario(
              name: 'text default',
              child: const SizedBox(
                width: 280,
                child: LexivoTextField(
                  label: 'Email',
                  hintText: 'you@lexivo.app',
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'text error',
              child: const SizedBox(
                width: 280,
                child: LexivoTextField(
                  label: 'Email',
                  hintText: 'you@lexivo.app',
                  errorText: 'Enter a valid email',
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'text disabled',
              child: const SizedBox(
                width: 280,
                child: LexivoTextField(
                  label: 'Email',
                  hintText: 'disabled',
                  enabled: false,
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'multiline',
              child: const SizedBox(
                width: 280,
                child: LexivoTextField(
                  variant: LexivoTextFieldVariant.multiline,
                  label: 'Notes',
                  hintText: 'Write something…',
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'search empty',
              child: const SizedBox(
                width: 280,
                child: LexivoTextField(
                  variant: LexivoTextFieldVariant.search,
                  hintText: 'Search documents',
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'search with text',
              child: SizedBox(
                width: 280,
                child: LexivoTextField(
                  variant: LexivoTextFieldVariant.search,
                  controller: TextEditingController(text: 'contracts'),
                  hintText: 'Search documents',
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'text focused',
              child: SizedBox(
                width: 280,
                child: LexivoTextField(
                  label: 'Focused',
                  hintText: 'Has focus',
                  focusNode: FocusNode()..requestFocus(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
