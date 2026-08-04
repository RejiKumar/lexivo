import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/components/snackbar.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  goldenTest(
    'LexivoSnackbar variants',
    fileName: 'lexivo_snackbar',
    builder: () => Theme(
      data: AppTheme.light,
      child: ColoredBox(
        color: LexivoColors.light().backgroundDefault,
        child: GoldenTestGroup(
          columns: 1,
          children: [
            for (final variant in LexivoSnackbarVariant.values)
              GoldenTestScenario(
                name: variant.name,
                child: SizedBox(
                  width: 320,
                  child: LexivoSnackbarBody(
                    message: '${variant.name} message',
                    variant: variant,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
