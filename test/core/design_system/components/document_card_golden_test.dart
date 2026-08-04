import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/components/document_card.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  goldenTest(
    'LexivoDocumentCard status variants',
    fileName: 'lexivo_document_card',
    builder: () => Theme(
      data: AppTheme.light,
      child: ColoredBox(
        color: LexivoColors.light().backgroundDefault,
        child: GoldenTestGroup(
          columns: 1,
          children: [
            GoldenTestScenario(
              name: 'processing',
              child: const SizedBox(
                width: 360,
                child: LexivoDocumentCard(
                  name: 'Invoice.pdf',
                  status: LexivoDocumentStatus.processing,
                  timestamp: 'Just now',
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'ready',
              child: SizedBox(
                width: 360,
                child: LexivoDocumentCard(
                  name: 'Handbook.pdf',
                  status: LexivoDocumentStatus.ready,
                  timestamp: '2h ago',
                  thumbnail: ColoredBox(
                    color: LexivoColors.light().brandPrimary.withValues(
                      alpha: 0.15,
                    ),
                    child: Icon(
                      Icons.picture_as_pdf,
                      color: LexivoColors.light().brandPrimary,
                    ),
                  ),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'failed',
              child: const SizedBox(
                width: 360,
                child: LexivoDocumentCard(
                  name: 'Corrupt.scan',
                  status: LexivoDocumentStatus.failed,
                  timestamp: 'Yesterday',
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'missing thumbnail fallback',
              child: const SizedBox(
                width: 360,
                child: LexivoDocumentCard(
                  name: 'Untitled notes',
                  status: LexivoDocumentStatus.ready,
                  timestamp: '3d ago',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
