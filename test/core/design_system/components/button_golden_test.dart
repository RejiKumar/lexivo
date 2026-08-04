import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  goldenTest(
    'LexivoButton variants × sizes × key states',
    fileName: 'lexivo_button',
    builder: () => Theme(
      data: AppTheme.light,
      child: ColoredBox(
        color: LexivoColors.light().backgroundDefault,
        child: GoldenTestGroup(
          columns: 3,
          children: [
            for (final variant in LexivoButtonVariant.values)
              GoldenTestScenario(
                name: '${variant.name} md',
                child: LexivoButton(
                  label: variant.name,
                  variant: variant,
                  onPressed: () {},
                ),
              ),
            for (final size in LexivoButtonSize.values)
              GoldenTestScenario(
                name: 'primary ${size.name}',
                child: LexivoButton(
                  label: size.name,
                  size: size,
                  onPressed: () {},
                ),
              ),
            GoldenTestScenario(
              name: 'primary disabled',
              child: LexivoButton(
                label: 'Disabled',
                onPressed: () {},
                enabled: false,
              ),
            ),
            GoldenTestScenario(
              name: 'primary loading',
              child: LexivoButton(
                label: 'Loading',
                onPressed: () {},
                loading: true,
              ),
            ),
            GoldenTestScenario(
              name: 'icons fullWidth',
              child: SizedBox(
                width: 240,
                child: LexivoButton(
                  label: 'Continue',
                  onPressed: () {},
                  leadingIcon: Icons.check,
                  trailingIcon: Icons.arrow_forward,
                  fullWidth: true,
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'destructive disabled',
              child: LexivoButton(
                label: 'Delete',
                variant: LexivoButtonVariant.destructive,
                onPressed: () {},
                enabled: false,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
