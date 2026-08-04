import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../tokens/color.dart';
import '../tokens/elevation.dart';
import '../tokens/motion.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

/// Card surface style.
enum LexivoCardVariant { flat, elevated, interactive }

/// Lexivo card — base surface for list items and composed cards.
class LexivoCard extends StatefulWidget {
  const LexivoCard({
    super.key,
    required this.child,
    this.variant = LexivoCardVariant.elevated,
    this.onTap,
    this.padding,
    @visibleForTesting this.debugForcePressed = false,
  });

  final Widget child;
  final LexivoCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  /// Forces pressed elevation (goldens / tests only).
  @visibleForTesting
  final bool debugForcePressed;

  @override
  State<LexivoCard> createState() => _LexivoCardState();
}

class _LexivoCardState extends State<LexivoCard> {
  bool _pressed = false;

  bool get _isPressed => widget.debugForcePressed || _pressed;

  List<BoxShadow> _shadows() {
    switch (widget.variant) {
      case LexivoCardVariant.flat:
        return LexivoElevation.level0;
      case LexivoCardVariant.elevated:
        return LexivoElevation.level1;
      case LexivoCardVariant.interactive:
        return _isPressed ? LexivoElevation.level2 : LexivoElevation.level1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    final isInteractive =
        widget.variant == LexivoCardVariant.interactive && widget.onTap != null;

    final content = AnimatedContainer(
      duration: LexivoMotion.fast.duration,
      curve: LexivoMotion.fast.curve,
      decoration: BoxDecoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(LexivoRadius.lg),
        border: widget.variant == LexivoCardVariant.flat
            ? Border.all(color: colors.borderDefault)
            : null,
        boxShadow: _shadows(),
      ),
      padding: widget.padding ?? const EdgeInsets.all(LexivoSpacing.md),
      child: widget.child,
    );

    if (!isInteractive) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (v) => setState(() => _pressed = v),
        borderRadius: BorderRadius.circular(LexivoRadius.lg),
        child: content,
      ),
    );
  }
}
