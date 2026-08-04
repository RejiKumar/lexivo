import 'package:flutter/animation.dart';

/// Named motion preset (duration + curve).
class LexivoMotionPreset {
  const LexivoMotionPreset({
    required this.duration,
    required this.curve,
  });

  final Duration duration;
  final Curve curve;
}

/// Motion tokens — micro-interactions stay ≤300ms.
abstract final class LexivoMotion {
  /// Button press, toggle — 120ms easeOut.
  static const LexivoMotionPreset fast = LexivoMotionPreset(
    duration: Duration(milliseconds: 120),
    curve: Curves.easeOut,
  );

  /// Page transition, expand/collapse — 200ms easeInOut.
  static const LexivoMotionPreset standard = LexivoMotionPreset(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeInOut,
  );

  /// Modal / bottom sheet enter/exit — 300ms easeInOutCubic.
  static const LexivoMotionPreset slow = LexivoMotionPreset(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOutCubic,
  );
}
