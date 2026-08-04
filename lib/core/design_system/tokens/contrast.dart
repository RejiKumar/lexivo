import 'dart:math' as math;

import 'package:flutter/material.dart';

/// WCAG relative luminance and contrast helpers for token audits.
abstract final class LexivoContrast {
  /// Relative luminance per WCAG 2.x (sRGB).
  static double relativeLuminance(Color color) {
    double channel(double c) {
      final v = c;
      return v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = channel(color.r);
    final g = channel(color.g);
    final b = channel(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Contrast ratio between two colors (1–21).
  static double ratio(Color a, Color b) {
    final l1 = relativeLuminance(a);
    final l2 = relativeLuminance(b);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// WCAG AA for normal text (≥4.5:1).
  static const double aaNormal = 4.5;

  /// WCAG AA for large text / UI components (≥3:1).
  static const double aaLarge = 3.0;
}
