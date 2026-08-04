import 'package:flutter/material.dart';

import '../tokens/color.dart';
import '../tokens/elevation.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'button.dart';

/// Dialog presentation style.
enum LexivoDialogVariant { confirmation, alert, custom }

/// Lexivo dialog — confirmation (2 actions), alert (1 action), or custom content.
class LexivoDialog extends StatelessWidget {
  const LexivoDialog({
    super.key,
    this.variant = LexivoDialogVariant.confirmation,
    this.title,
    this.body,
    this.content,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.primaryVariant = LexivoButtonVariant.primary,
  });

  final LexivoDialogVariant variant;
  final String? title;
  final String? body;

  /// Arbitrary content for [LexivoDialogVariant.custom].
  final Widget? content;

  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final LexivoButtonVariant primaryVariant;

  /// Presents [LexivoDialog] via [showDialog].
  static Future<T?> show<T>(
    BuildContext context, {
    LexivoDialogVariant variant = LexivoDialogVariant.confirmation,
    String? title,
    String? body,
    Widget? content,
    String? primaryLabel,
    VoidCallback? onPrimary,
    String? secondaryLabel,
    VoidCallback? onSecondary,
    LexivoButtonVariant primaryVariant = LexivoButtonVariant.primary,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => LexivoDialog(
        variant: variant,
        title: title,
        body: body,
        content: content,
        primaryLabel: primaryLabel,
        onPrimary: onPrimary,
        secondaryLabel: secondaryLabel,
        onSecondary: onSecondary,
        primaryVariant: primaryVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: LexivoSpacing.lg,
        vertical: LexivoSpacing.xl,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundSurfaceElevated,
          borderRadius: BorderRadius.circular(LexivoRadius.lg),
          boxShadow: LexivoElevation.level3,
        ),
        child: Padding(
          padding: const EdgeInsets.all(LexivoSpacing.lg),
          child: variant == LexivoDialogVariant.custom
              ? (content ?? const SizedBox.shrink())
              : _StandardDialogBody(
                  colors: colors,
                  title: title,
                  body: body,
                  showSecondary: variant == LexivoDialogVariant.confirmation,
                  primaryLabel: primaryLabel,
                  onPrimary: onPrimary,
                  secondaryLabel: secondaryLabel,
                  onSecondary: onSecondary,
                  primaryVariant: primaryVariant,
                ),
        ),
      ),
    );
  }
}

class _StandardDialogBody extends StatelessWidget {
  const _StandardDialogBody({
    required this.colors,
    required this.title,
    required this.body,
    required this.showSecondary,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    required this.primaryVariant,
  });

  final LexivoColors colors;
  final String? title;
  final String? body;
  final bool showSecondary;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final LexivoButtonVariant primaryVariant;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Text(
            title!,
            style: LexivoTypography.title.copyWith(color: colors.contentPrimary),
          ),
        if (body != null) ...[
          const SizedBox(height: LexivoSpacing.sm),
          Text(
            body!,
            style: LexivoTypography.body.copyWith(
              color: colors.contentSecondary,
            ),
          ),
        ],
        if (primaryLabel != null) ...[
          const SizedBox(height: LexivoSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showSecondary && secondaryLabel != null) ...[
                LexivoButton(
                  label: secondaryLabel!,
                  onPressed: onSecondary,
                  variant: LexivoButtonVariant.ghost,
                  size: LexivoButtonSize.sm,
                ),
                const SizedBox(width: LexivoSpacing.xs),
              ],
              LexivoButton(
                label: primaryLabel!,
                onPressed: onPrimary,
                variant: primaryVariant,
                size: LexivoButtonSize.sm,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
