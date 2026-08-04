import 'package:flutter/material.dart';

import '../tokens/color.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Badge tone.
enum LexivoBadgeVariant { neutral, success, warning, danger }

/// Compact status / tier badge.
class LexivoBadge extends StatelessWidget {
  const LexivoBadge({
    super.key,
    required this.label,
    this.variant = LexivoBadgeVariant.neutral,
  });

  final String label;
  final LexivoBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    final (bg, fg) = switch (variant) {
      LexivoBadgeVariant.neutral => (
          colors.contentSecondary.withValues(alpha: 0.12),
          colors.contentSecondary,
        ),
      LexivoBadgeVariant.success => (
          colors.feedbackSuccess.withValues(alpha: 0.14),
          colors.feedbackSuccess,
        ),
      LexivoBadgeVariant.warning => (
          colors.feedbackWarning.withValues(alpha: 0.16),
          colors.feedbackWarning,
        ),
      LexivoBadgeVariant.danger => (
          colors.feedbackDanger.withValues(alpha: 0.14),
          colors.feedbackDanger,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LexivoSpacing.xs,
        vertical: LexivoSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(LexivoRadius.pill),
      ),
      child: Text(
        label,
        style: LexivoTypography.labelCompact.copyWith(color: fg),
      ),
    );
  }
}
