import 'package:flutter/material.dart';

import '../tokens/color.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Inline error surface with optional retry / dismiss actions.
class LexivoErrorBanner extends StatelessWidget {
  const LexivoErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(LexivoSpacing.md),
        decoration: BoxDecoration(
          color: colors.feedbackDanger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(LexivoRadius.md),
          border: Border.all(
            color: colors.feedbackDanger.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colors.feedbackDanger, size: 20),
            const SizedBox(width: LexivoSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: LexivoTypography.body.copyWith(
                  color: colors.contentPrimary,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: colors.feedbackDanger,
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: LexivoSpacing.xs,
                  ),
                  textStyle: LexivoTypography.label,
                ),
                child: const Text('Retry'),
              ),
            if (onDismiss != null)
              IconButton(
                tooltip: 'Dismiss',
                onPressed: onDismiss,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: colors.contentSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
