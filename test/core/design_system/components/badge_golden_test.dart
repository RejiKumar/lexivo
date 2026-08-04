import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/components/badge.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  goldenTest(
    'LexivoBadge variants',
    fileName: 'lexivo_badge',
    builder: () => Theme(
      data: AppTheme.light,
      child: ColoredBox(
        color: LexivoColors.light().backgroundDefault,
        child: GoldenTestGroup(
          columns: 4,
          children: [
            for (final variant in LexivoBadgeVariant.values)
              GoldenTestScenario(
                name: variant.name,
                child: LexivoBadge(label: variant.name, variant: variant),
              ),
          ],
        ),
      ),
    ),
  );
}
