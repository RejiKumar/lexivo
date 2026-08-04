import 'package:flutter/material.dart';

import '../tokens/color.dart';
import '../tokens/motion.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

/// Skeleton placeholder shape.
enum LexivoSkeletonVariant { line, card, avatar }

/// Shimmering loading placeholder composed from tokens.
class LexivoSkeleton extends StatefulWidget {
  const LexivoSkeleton({
    super.key,
    this.variant = LexivoSkeletonVariant.line,
    this.width,
    this.height,
    this.animate = true,
  });

  final LexivoSkeletonVariant variant;
  final double? width;
  final double? height;

  /// When false, shows a static frame (useful for goldens).
  final bool animate;

  @override
  State<LexivoSkeleton> createState() => _LexivoSkeletonState();
}

class _LexivoSkeletonState extends State<LexivoSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: LexivoMotion.slow.duration * 2,
    );
    if (widget.animate) {
      _controller.repeat();
    } else {
      _controller.value = 0.35;
    }
  }

  @override
  void didUpdateWidget(covariant LexivoSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0.35;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Size _size() {
    switch (widget.variant) {
      case LexivoSkeletonVariant.line:
        return Size(widget.width ?? 160, widget.height ?? LexivoSpacing.sm);
      case LexivoSkeletonVariant.card:
        return Size(widget.width ?? 200, widget.height ?? 120);
      case LexivoSkeletonVariant.avatar:
        final s = widget.width ?? widget.height ?? 40;
        return Size(s, s);
    }
  }

  BorderRadius _radius() {
    switch (widget.variant) {
      case LexivoSkeletonVariant.line:
        return BorderRadius.circular(LexivoRadius.sm);
      case LexivoSkeletonVariant.card:
        return BorderRadius.circular(LexivoRadius.lg);
      case LexivoSkeletonVariant.avatar:
        return BorderRadius.circular(LexivoRadius.pill);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    final size = _size();
    final base = colors.borderDefault;
    final highlight = colors.backgroundSurfaceElevated;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            borderRadius: _radius(),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _controller.value, 0),
              end: Alignment(1 + 2 * _controller.value, 0),
              colors: [
                base,
                highlight,
                base,
              ],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}
