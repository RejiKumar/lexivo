import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../tokens/color.dart';
import '../tokens/motion.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Chat bubble role / streaming state.
enum LexivoChatBubbleVariant { user, assistant, assistantStreaming }

/// Chat message bubble with optional citation chips slot (generic widgets only).
class LexivoChatBubble extends StatefulWidget {
  const LexivoChatBubble({
    super.key,
    required this.message,
    this.variant = LexivoChatBubbleVariant.assistant,
    this.citationChips,
    @visibleForTesting this.debugDisableStreamingAnimation = false,
  });

  final String message;
  final LexivoChatBubbleVariant variant;

  /// Optional slot for citation chip widgets — no rag feature models.
  final Widget? citationChips;

  /// Freezes streaming indicator for goldens.
  @visibleForTesting
  final bool debugDisableStreamingAnimation;

  @override
  State<LexivoChatBubble> createState() => _LexivoChatBubbleState();
}

class _LexivoChatBubbleState extends State<LexivoChatBubble>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  bool get _streaming =>
      widget.variant == LexivoChatBubbleVariant.assistantStreaming;

  @override
  void initState() {
    super.initState();
    if (_streaming && !widget.debugDisableStreamingAnimation) {
      _pulse = AnimationController(
        vsync: this,
        duration: LexivoMotion.standard.duration,
      )..repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant LexivoChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldAnimate =
        _streaming && !widget.debugDisableStreamingAnimation;
    if (shouldAnimate && _pulse == null) {
      _pulse = AnimationController(
        vsync: this,
        duration: LexivoMotion.standard.duration,
      )..repeat(reverse: true);
    } else if (!shouldAnimate) {
      _pulse?.dispose();
      _pulse = null;
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    final isUser = widget.variant == LexivoChatBubbleVariant.user;

    final bg = isUser ? colors.brandPrimary : colors.backgroundSurfaceElevated;
    final fg = isUser ? colors.contentOnInverse : colors.contentPrimary;

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.symmetric(
        horizontal: LexivoSpacing.md,
        vertical: LexivoSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(LexivoRadius.lg),
          topRight: const Radius.circular(LexivoRadius.lg),
          bottomLeft: Radius.circular(isUser ? LexivoRadius.lg : LexivoRadius.sm),
          bottomRight:
              Radius.circular(isUser ? LexivoRadius.sm : LexivoRadius.lg),
        ),
        border: isUser ? null : Border.all(color: colors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.message.isNotEmpty)
            Text(
              widget.message,
              style: LexivoTypography.body.copyWith(color: fg),
            ),
          if (_streaming) ...[
            if (widget.message.isNotEmpty)
              const SizedBox(height: LexivoSpacing.xs),
            _StreamingDots(
              color: colors.contentSecondary,
              animation: _pulse,
            ),
          ],
          if (widget.citationChips != null) ...[
            const SizedBox(height: LexivoSpacing.sm),
            widget.citationChips!,
          ],
        ],
      ),
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: bubble,
    );
  }
}

class _StreamingDots extends StatelessWidget {
  const _StreamingDots({required this.color, required this.animation});

  final Color color;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    Widget dots(double t) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: LexivoSpacing.xxs),
            Opacity(
              opacity: 0.35 + (0.65 * (((t + i / 3) % 1.0))),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ],
      );
    }

    if (animation == null) {
      return dots(0.5);
    }

    return AnimatedBuilder(
      animation: animation!,
      builder: (context, _) => dots(animation!.value),
    );
  }
}
