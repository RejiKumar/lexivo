import 'package:flutter/material.dart';

/// Semantic color tokens for Lexivo. Resolve via
/// `Theme.of(context).extension<LexivoColors>()` — never hard-code hex in UI.
@immutable
class LexivoColors extends ThemeExtension<LexivoColors> {
  const LexivoColors({
    required this.backgroundDefault,
    required this.backgroundSurface,
    required this.backgroundSurfaceElevated,
    required this.backgroundInverse,
    required this.contentPrimary,
    required this.contentSecondary,
    required this.contentDisabled,
    required this.contentOnInverse,
    required this.borderDefault,
    required this.borderFocus,
    required this.brandPrimary,
    required this.brandPrimaryHover,
    required this.brandPrimaryPressed,
    required this.feedbackSuccess,
    required this.feedbackWarning,
    required this.feedbackDanger,
    required this.feedbackInfo,
  });

  /// Light theme values — see `BRAND.md`.
  factory LexivoColors.light() => const LexivoColors(
        backgroundDefault: Color(0xFFF8FAFC),
        backgroundSurface: Color(0xFFFFFFFF),
        backgroundSurfaceElevated: Color(0xFFFFFFFF),
        backgroundInverse: Color(0xFF0F172A),
        contentPrimary: Color(0xFF0F172A),
        contentSecondary: Color(0xFF475569),
        contentDisabled: Color(0xFF94A3B8),
        contentOnInverse: Color(0xFFF8FAFC),
        borderDefault: Color(0xFFE2E8F0),
        borderFocus: Color(0xFF0F766E),
        brandPrimary: Color(0xFF0F766E),
        brandPrimaryHover: Color(0xFF0D9488),
        brandPrimaryPressed: Color(0xFF115E59),
        feedbackSuccess: Color(0xFF15803D),
        feedbackWarning: Color(0xFFB45309),
        feedbackDanger: Color(0xFFDC2626),
        feedbackInfo: Color(0xFF0369A1),
      );

  /// Dark theme values — see `BRAND.md`.
  factory LexivoColors.dark() => const LexivoColors(
        backgroundDefault: Color(0xFF0B1220),
        backgroundSurface: Color(0xFF111827),
        backgroundSurfaceElevated: Color(0xFF1E293B),
        backgroundInverse: Color(0xFFF8FAFC),
        contentPrimary: Color(0xFFF1F5F9),
        contentSecondary: Color(0xFF94A3B8),
        contentDisabled: Color(0xFF64748B),
        contentOnInverse: Color(0xFF0F172A),
        borderDefault: Color(0xFF334155),
        borderFocus: Color(0xFF2DD4BF),
        brandPrimary: Color(0xFF2DD4BF),
        brandPrimaryHover: Color(0xFF5EEAD4),
        brandPrimaryPressed: Color(0xFF14B8A6),
        feedbackSuccess: Color(0xFF4ADE80),
        feedbackWarning: Color(0xFFFBBF24),
        feedbackDanger: Color(0xFFF87171),
        feedbackInfo: Color(0xFF38BDF8),
      );

  // Background
  final Color backgroundDefault;
  final Color backgroundSurface;
  final Color backgroundSurfaceElevated;
  final Color backgroundInverse;

  // Content
  final Color contentPrimary;
  final Color contentSecondary;
  final Color contentDisabled;
  final Color contentOnInverse;

  // Border
  final Color borderDefault;
  final Color borderFocus;

  // Brand
  final Color brandPrimary;
  final Color brandPrimaryHover;
  final Color brandPrimaryPressed;

  // Feedback
  final Color feedbackSuccess;
  final Color feedbackWarning;
  final Color feedbackDanger;
  final Color feedbackInfo;

  @override
  LexivoColors copyWith({
    Color? backgroundDefault,
    Color? backgroundSurface,
    Color? backgroundSurfaceElevated,
    Color? backgroundInverse,
    Color? contentPrimary,
    Color? contentSecondary,
    Color? contentDisabled,
    Color? contentOnInverse,
    Color? borderDefault,
    Color? borderFocus,
    Color? brandPrimary,
    Color? brandPrimaryHover,
    Color? brandPrimaryPressed,
    Color? feedbackSuccess,
    Color? feedbackWarning,
    Color? feedbackDanger,
    Color? feedbackInfo,
  }) {
    return LexivoColors(
      backgroundDefault: backgroundDefault ?? this.backgroundDefault,
      backgroundSurface: backgroundSurface ?? this.backgroundSurface,
      backgroundSurfaceElevated:
          backgroundSurfaceElevated ?? this.backgroundSurfaceElevated,
      backgroundInverse: backgroundInverse ?? this.backgroundInverse,
      contentPrimary: contentPrimary ?? this.contentPrimary,
      contentSecondary: contentSecondary ?? this.contentSecondary,
      contentDisabled: contentDisabled ?? this.contentDisabled,
      contentOnInverse: contentOnInverse ?? this.contentOnInverse,
      borderDefault: borderDefault ?? this.borderDefault,
      borderFocus: borderFocus ?? this.borderFocus,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandPrimaryHover: brandPrimaryHover ?? this.brandPrimaryHover,
      brandPrimaryPressed: brandPrimaryPressed ?? this.brandPrimaryPressed,
      feedbackSuccess: feedbackSuccess ?? this.feedbackSuccess,
      feedbackWarning: feedbackWarning ?? this.feedbackWarning,
      feedbackDanger: feedbackDanger ?? this.feedbackDanger,
      feedbackInfo: feedbackInfo ?? this.feedbackInfo,
    );
  }

  @override
  LexivoColors lerp(ThemeExtension<LexivoColors>? other, double t) {
    if (other is! LexivoColors) return this;
    if (t == 0.0) return this;
    if (t == 1.0) return other;
    return LexivoColors(
      backgroundDefault:
          Color.lerp(backgroundDefault, other.backgroundDefault, t)!,
      backgroundSurface:
          Color.lerp(backgroundSurface, other.backgroundSurface, t)!,
      backgroundSurfaceElevated: Color.lerp(
        backgroundSurfaceElevated,
        other.backgroundSurfaceElevated,
        t,
      )!,
      backgroundInverse:
          Color.lerp(backgroundInverse, other.backgroundInverse, t)!,
      contentPrimary: Color.lerp(contentPrimary, other.contentPrimary, t)!,
      contentSecondary:
          Color.lerp(contentSecondary, other.contentSecondary, t)!,
      contentDisabled: Color.lerp(contentDisabled, other.contentDisabled, t)!,
      contentOnInverse:
          Color.lerp(contentOnInverse, other.contentOnInverse, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandPrimaryHover:
          Color.lerp(brandPrimaryHover, other.brandPrimaryHover, t)!,
      brandPrimaryPressed:
          Color.lerp(brandPrimaryPressed, other.brandPrimaryPressed, t)!,
      feedbackSuccess: Color.lerp(feedbackSuccess, other.feedbackSuccess, t)!,
      feedbackWarning: Color.lerp(feedbackWarning, other.feedbackWarning, t)!,
      feedbackDanger: Color.lerp(feedbackDanger, other.feedbackDanger, t)!,
      feedbackInfo: Color.lerp(feedbackInfo, other.feedbackInfo, t)!,
    );
  }
}
