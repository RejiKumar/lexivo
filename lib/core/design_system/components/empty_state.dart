import 'package:flutter/material.dart';

import '../tokens/color.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'button.dart';

/// Empty / zero-result surface with optional CTA.
class LexivoEmptyState extends StatelessWidget {
  const LexivoEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.illustration,
    this.ctaLabel,
    this.onCtaPressed,
  });

  final String title;
  final String description;
  final IconData? icon;
  final Widget? illustration;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    final showCta = ctaLabel != null && onCtaPressed != null;

    return Padding(
      padding: const EdgeInsets.all(LexivoSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (illustration != null)
            illustration!
          else if (icon != null)
            Icon(icon, size: 48, color: colors.contentSecondary),
          if (illustration != null || icon != null)
            const SizedBox(height: LexivoSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: LexivoTypography.headline.copyWith(
              color: colors.contentPrimary,
            ),
          ),
          const SizedBox(height: LexivoSpacing.sm),
          Text(
            description,
            textAlign: TextAlign.center,
            style: LexivoTypography.body.copyWith(
              color: colors.contentSecondary,
            ),
          ),
          if (showCta) ...[
            const SizedBox(height: LexivoSpacing.lg),
            LexivoButton(
              label: ctaLabel!,
              onPressed: onCtaPressed,
            ),
          ],
        ],
      ),
    );
  }
}
