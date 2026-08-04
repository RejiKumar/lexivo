import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../tokens/color.dart';
import '../tokens/elevation.dart';
import '../tokens/icon_size.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Bottom sheet presentation style.
enum LexivoBottomSheetVariant { generic, actionList, scrollable }

/// A single row in an [LexivoBottomSheetVariant.actionList] sheet.
@immutable
class LexivoBottomSheetAction {
  const LexivoBottomSheetAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.isDestructive = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isDestructive;
}

/// Lexivo bottom sheet — glass/blur overlay per ui_design_system §1.
class LexivoBottomSheet extends StatelessWidget {
  const LexivoBottomSheet({
    super.key,
    this.variant = LexivoBottomSheetVariant.generic,
    this.child,
    this.actions = const [],
    this.title,
    @visibleForTesting this.debugDisableBlur = false,
  });

  final LexivoBottomSheetVariant variant;
  final Widget? child;
  final List<LexivoBottomSheetAction> actions;
  final String? title;

  /// Skips [BackdropFilter] for deterministic goldens.
  @visibleForTesting
  final bool debugDisableBlur;

  /// Presents [LexivoBottomSheet] via [showModalBottomSheet].
  static Future<T?> show<T>(
    BuildContext context, {
    LexivoBottomSheetVariant variant = LexivoBottomSheetVariant.generic,
    Widget? child,
    List<LexivoBottomSheetAction> actions = const [],
    String? title,
    bool isScrollControlled = true,
  }) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: colors.overlayScrim,
      isScrollControlled: isScrollControlled,
      builder: (context) => LexivoBottomSheet(
        variant: variant,
        child: child,
        actions: actions,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    final maxScrollBodyHeight = MediaQuery.sizeOf(context).height * 0.55;

    final sheet = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundSurfaceElevated.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(LexivoRadius.lg),
        ),
        boxShadow: LexivoElevation.level3,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            LexivoSpacing.md,
            LexivoSpacing.sm,
            LexivoSpacing.md,
            LexivoSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.borderDefault,
                    borderRadius: BorderRadius.circular(LexivoRadius.pill),
                  ),
                ),
              ),
              if (title != null) ...[
                const SizedBox(height: LexivoSpacing.md),
                Text(
                  title!,
                  style: LexivoTypography.title.copyWith(
                    color: colors.contentPrimary,
                  ),
                ),
              ],
              const SizedBox(height: LexivoSpacing.md),
              _buildBody(colors, maxScrollBodyHeight),
            ],
          ),
        ),
      ),
    );

    if (debugDisableBlur) {
      return sheet;
    }

    // Glass/blur only on overlays (§1) — not on static content.
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(LexivoRadius.lg),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: sheet,
      ),
    );
  }

  Widget _buildBody(LexivoColors colors, double maxScrollBodyHeight) {
    switch (variant) {
      case LexivoBottomSheetVariant.generic:
        return child ?? const SizedBox.shrink();
      case LexivoBottomSheetVariant.actionList:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in actions)
              _ActionTile(action: action, colors: colors),
          ],
        );
      case LexivoBottomSheetVariant.scrollable:
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxScrollBodyHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: LexivoSpacing.md),
            child: child ?? const SizedBox.shrink(),
          ),
        );
    }
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action, required this.colors});

  final LexivoBottomSheetAction action;
  final LexivoColors colors;

  @override
  Widget build(BuildContext context) {
    final fg = action.isDestructive
        ? colors.feedbackDanger
        : colors.contentPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(LexivoRadius.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LexivoSpacing.sm,
              vertical: LexivoSpacing.sm,
            ),
            child: Row(
              children: [
                if (action.icon != null) ...[
                  Icon(action.icon, color: fg, size: LexivoIconSize.md),
                  const SizedBox(width: LexivoSpacing.sm),
                ],
                Expanded(
                  child: Text(
                    action.label,
                    style: LexivoTypography.body.copyWith(color: fg),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
