import 'package:flutter/material.dart';

import '../tokens/color.dart';
import '../tokens/motion.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Button visual style.
enum LexivoButtonVariant { primary, secondary, ghost, destructive }

/// Button size token mapping.
enum LexivoButtonSize { sm, md, lg }

/// Lexivo button — tokens only; ≥44×44 hit target.
///
/// States: default, hover (web / pointer), pressed, disabled, loading.
class LexivoButton extends StatefulWidget {
  const LexivoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = LexivoButtonVariant.primary,
    this.size = LexivoButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final LexivoButtonVariant variant;
  final LexivoButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool fullWidth;
  final bool enabled;
  final bool loading;

  bool get _interactive => enabled && !loading && onPressed != null;

  @override
  State<LexivoButton> createState() => _LexivoButtonState();
}

class _LexivoButtonState extends State<LexivoButton> {
  bool _pressed = false;
  bool _hovered = false;

  double get _minHeight {
    switch (widget.size) {
      case LexivoButtonSize.sm:
      case LexivoButtonSize.md:
        return 44;
      case LexivoButtonSize.lg:
        return 48;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case LexivoButtonSize.sm:
        return const EdgeInsets.symmetric(
          horizontal: LexivoSpacing.md,
          vertical: LexivoSpacing.xs,
        );
      case LexivoButtonSize.md:
        return const EdgeInsets.symmetric(
          horizontal: LexivoSpacing.lg,
          vertical: LexivoSpacing.sm,
        );
      case LexivoButtonSize.lg:
        return const EdgeInsets.symmetric(
          horizontal: LexivoSpacing.xl,
          vertical: LexivoSpacing.md,
        );
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case LexivoButtonSize.sm:
        return 16;
      case LexivoButtonSize.md:
        return 18;
      case LexivoButtonSize.lg:
        return 20;
    }
  }

  /// Pressed wins over hover; both only apply when interactive.
  _ButtonColors _resolveColors(LexivoColors colors) {
    final interactive = widget._interactive;
    final pressed = interactive && _pressed;
    final hovered = interactive && _hovered && !pressed;

    switch (widget.variant) {
      case LexivoButtonVariant.primary:
        Color background;
        if (!interactive) {
          background = colors.contentDisabled.withValues(alpha: 0.24);
        } else if (pressed) {
          background = colors.brandPrimaryPressed;
        } else if (hovered) {
          background = colors.brandPrimaryHover;
        } else {
          background = colors.brandPrimary;
        }
        return _ButtonColors(
          background: background,
          foreground: interactive
              ? colors.contentOnInverse
              : colors.contentDisabled,
          border: Colors.transparent,
        );
      case LexivoButtonVariant.secondary:
        Color background;
        if (!interactive) {
          background = colors.backgroundSurface;
        } else if (pressed) {
          background = colors.brandPrimary.withValues(alpha: 0.12);
        } else if (hovered) {
          background = colors.brandPrimary.withValues(alpha: 0.06);
        } else {
          background = colors.backgroundSurface;
        }
        return _ButtonColors(
          background: background,
          foreground:
              interactive ? colors.brandPrimary : colors.contentDisabled,
          border: colors.borderDefault,
        );
      case LexivoButtonVariant.ghost:
        Color background;
        if (!interactive) {
          background = Colors.transparent;
        } else if (pressed) {
          background = colors.brandPrimary.withValues(alpha: 0.12);
        } else if (hovered) {
          background = colors.brandPrimary.withValues(alpha: 0.08);
        } else {
          background = Colors.transparent;
        }
        return _ButtonColors(
          background: background,
          foreground:
              interactive ? colors.brandPrimary : colors.contentDisabled,
          border: Colors.transparent,
        );
      case LexivoButtonVariant.destructive:
        Color background;
        if (!interactive) {
          background = colors.contentDisabled.withValues(alpha: 0.24);
        } else if (pressed) {
          background = colors.feedbackDanger.withValues(alpha: 0.85);
        } else if (hovered) {
          background = Color.alphaBlend(
            colors.contentOnInverse.withValues(alpha: 0.12),
            colors.feedbackDanger,
          );
        } else {
          background = colors.feedbackDanger;
        }
        return _ButtonColors(
          background: background,
          foreground: interactive
              ? colors.contentOnInverse
              : colors.contentDisabled,
          border: Colors.transparent,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    final palette = _resolveColors(colors);
    final labelStyle =
        LexivoTypography.label.copyWith(color: palette.foreground);

    final content = widget.loading
        ? SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              // Determinate keeps goldens stable.
              value: 0.7,
              color: palette.foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leadingIcon != null) ...[
                Icon(
                  widget.leadingIcon,
                  size: _iconSize,
                  color: palette.foreground,
                ),
                const SizedBox(width: LexivoSpacing.xs),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: labelStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.trailingIcon != null) ...[
                const SizedBox(width: LexivoSpacing.xs),
                Icon(
                  widget.trailingIcon,
                  size: _iconSize,
                  color: palette.foreground,
                ),
              ],
            ],
          );

    Widget button = MouseRegion(
      onEnter: (_) {
        if (!widget._interactive) return;
        setState(() => _hovered = true);
      },
      onExit: (_) {
        if (!_hovered && !_pressed) return;
        setState(() {
          _hovered = false;
          // Leave pressed to InkWell highlight lifecycle.
        });
      },
      child: AnimatedScale(
        scale: _pressed && widget._interactive ? 0.98 : 1,
        duration: LexivoMotion.fast.duration,
        curve: LexivoMotion.fast.curve,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 44,
            minHeight: _minHeight,
          ),
          child: Material(
            color: palette.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LexivoRadius.md),
              side: BorderSide(
                color: palette.border,
                width: palette.border == Colors.transparent ? 0 : 1,
              ),
            ),
            child: InkWell(
              onTap: widget._interactive ? widget.onPressed : null,
              onHighlightChanged: (highlighted) {
                if (!widget._interactive) return;
                setState(() => _pressed = highlighted);
              },
              borderRadius: BorderRadius.circular(LexivoRadius.md),
              child: Padding(
                padding: _padding,
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
