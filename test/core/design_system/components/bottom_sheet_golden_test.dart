import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/components/bottom_sheet.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  goldenTest(
    'LexivoBottomSheet variants',
    fileName: 'lexivo_bottom_sheet',
    builder: () => Theme(
      data: AppTheme.light,
      child: ColoredBox(
        color: LexivoColors.light().backgroundDefault,
        child: GoldenTestGroup(
          columns: 1,
          children: [
            GoldenTestScenario(
              name: 'generic',
              child: SizedBox(
                width: 360,
                child: LexivoBottomSheet(
                  variant: LexivoBottomSheetVariant.generic,
                  title: 'Details',
                  debugDisableBlur: true,
                  child: Text(
                    'Generic content slot',
                    style: TextStyle(
                      color: LexivoColors.light().contentPrimary,
                    ),
                  ),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'actionList',
              child: SizedBox(
                width: 360,
                child: LexivoBottomSheet(
                  variant: LexivoBottomSheetVariant.actionList,
                  title: 'Document actions',
                  debugDisableBlur: true,
                  actions: [
                    LexivoBottomSheetAction(
                      label: 'Share',
                      icon: Icons.share_outlined,
                      onTap: () {},
                    ),
                    LexivoBottomSheetAction(
                      label: 'Delete',
                      icon: Icons.delete_outline,
                      onTap: () {},
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'scrollable',
              child: SizedBox(
                width: 360,
                child: LexivoBottomSheet(
                  variant: LexivoBottomSheetVariant.scrollable,
                  title: 'Long content',
                  debugDisableBlur: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < 8; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Scrollable line $i',
                            style: TextStyle(
                              color: LexivoColors.light().contentPrimary,
                            ),
                          ),
                        ),
                    ],
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
