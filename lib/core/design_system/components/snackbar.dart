import 'package:flutter/material.dart';

import '../tokens/color.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Snackbar tone.
enum LexivoSnackbarVariant { info, success, error }

/// Global snackbar helper — never call ScaffoldMessenger with ad-hoc styling.
abstract final class LexivoSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    LexivoSnackbarVariant variant = LexivoSnackbarVariant.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        content: _LexivoSnackbarContent(
          message: message,
          variant: variant,
          colors: colors,
        ),
      ),
    );
  }
}

/// Visible snackbar body (also used by golden / widget tests).
class LexivoSnackbarBody extends StatelessWidget {
  const LexivoSnackbarBody({
    super.key,
    required this.message,
    this.variant = LexivoSnackbarVariant.info,
  });

  final String message;
  final LexivoSnackbarVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    return _LexivoSnackbarContent(
      message: message,
      variant: variant,
      colors: colors,
    );
  }
}

class _LexivoSnackbarContent extends StatelessWidget {
  const _LexivoSnackbarContent({
    required this.message,
    required this.variant,
    required this.colors,
  });

  final String message;
  final LexivoSnackbarVariant variant;
  final LexivoColors colors;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (variant) {
      LexivoSnackbarVariant.info => (
          colors.feedbackInfo,
          colors.contentOnInverse,
          Icons.info_outline,
        ),
      LexivoSnackbarVariant.success => (
          colors.feedbackSuccess,
          colors.contentOnInverse,
          Icons.check_circle_outline,
        ),
      LexivoSnackbarVariant.error => (
          colors.feedbackDanger,
          colors.contentOnInverse,
          Icons.error_outline,
        ),
    };

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(LexivoRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LexivoSpacing.md,
          vertical: LexivoSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: LexivoSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: LexivoTypography.body.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
