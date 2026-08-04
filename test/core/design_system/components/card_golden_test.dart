import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/components/card.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  goldenTest(
    'LexivoCard variants',
    fileName: 'lexivo_card',
    builder: () => Theme(
      data: AppTheme.light,
      child: ColoredBox(
        color: LexivoColors.light().backgroundDefault,
        child: GoldenTestGroup(
          columns: 2,
          children: [
            GoldenTestScenario(
              name: 'flat',
              child: const SizedBox(
                width: 200,
                child: LexivoCard(
                  variant: LexivoCardVariant.flat,
                  child: Text('Flat card'),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'elevated',
              child: const SizedBox(
                width: 200,
                child: LexivoCard(
                  variant: LexivoCardVariant.elevated,
                  child: Text('Elevated card'),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'interactive default',
              child: SizedBox(
                width: 200,
                child: LexivoCard(
                  variant: LexivoCardVariant.interactive,
                  onTap: () {},
                  child: const Text('Interactive'),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'interactive pressed',
              child: SizedBox(
                width: 200,
                child: LexivoCard(
                  variant: LexivoCardVariant.interactive,
                  onTap: () {},
                  debugForcePressed: true,
                  child: const Text('Pressed'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
