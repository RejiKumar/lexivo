import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  goldenTest(
    'LexivoErrorBanner variants',
    fileName: 'lexivo_error_banner',
    builder: () => Theme(
      data: AppTheme.light,
      child: ColoredBox(
        color: LexivoColors.light().backgroundDefault,
        child: GoldenTestGroup(
          columns: 1,
          children: [
            GoldenTestScenario(
              name: 'message only',
              child: const SizedBox(
                width: 360,
                child: LexivoErrorBanner(message: 'Upload failed'),
              ),
            ),
            GoldenTestScenario(
              name: 'with retry',
              child: SizedBox(
                width: 360,
                child: LexivoErrorBanner(
                  message: 'Network error',
                  onRetry: () {},
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'with dismiss',
              child: SizedBox(
                width: 360,
                child: LexivoErrorBanner(
                  message: 'Warning',
                  onDismiss: () {},
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'with both',
              child: SizedBox(
                width: 360,
                child: LexivoErrorBanner(
                  message: 'Could not sync',
                  onRetry: () {},
                  onDismiss: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
