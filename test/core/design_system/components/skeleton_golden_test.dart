import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/components/skeleton_loader.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  goldenTest(
    'LexivoSkeleton variants',
    fileName: 'lexivo_skeleton',
    builder: () => Theme(
      data: AppTheme.light,
      child: ColoredBox(
        color: LexivoColors.light().backgroundDefault,
        child: GoldenTestGroup(
          columns: 3,
          children: [
            GoldenTestScenario(
              name: 'line',
              child: const LexivoSkeleton(
                variant: LexivoSkeletonVariant.line,
                animate: false,
              ),
            ),
            GoldenTestScenario(
              name: 'card',
              child: const LexivoSkeleton(
                variant: LexivoSkeletonVariant.card,
                animate: false,
              ),
            ),
            GoldenTestScenario(
              name: 'avatar',
              child: const LexivoSkeleton(
                variant: LexivoSkeletonVariant.avatar,
                animate: false,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
