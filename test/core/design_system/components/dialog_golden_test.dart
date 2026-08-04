import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/dialog.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  goldenTest(
    'LexivoDialog variants',
    fileName: 'lexivo_dialog',
    builder: () => Theme(
      data: AppTheme.light,
      child: ColoredBox(
        color: LexivoColors.light().backgroundDefault,
        child: GoldenTestGroup(
          columns: 1,
          children: [
            GoldenTestScenario(
              name: 'confirmation',
              child: SizedBox(
                width: 360,
                child: LexivoDialog(
                  variant: LexivoDialogVariant.confirmation,
                  title: 'Delete document?',
                  body: 'This cannot be undone.',
                  primaryLabel: 'Delete',
                  onPrimary: () {},
                  secondaryLabel: 'Cancel',
                  onSecondary: () {},
                  primaryVariant: LexivoButtonVariant.destructive,
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'alert',
              child: SizedBox(
                width: 360,
                child: LexivoDialog(
                  variant: LexivoDialogVariant.alert,
                  title: 'Upload complete',
                  body: 'Your file is ready to chat.',
                  primaryLabel: 'OK',
                  onPrimary: () {},
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'custom',
              child: SizedBox(
                width: 360,
                child: LexivoDialog(
                  variant: LexivoDialogVariant.custom,
                  content: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Custom slot content',
                      style: TextStyle(
                        color: LexivoColors.light().contentPrimary,
                      ),
                    ),
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
