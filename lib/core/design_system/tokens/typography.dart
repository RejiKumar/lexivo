import 'package:flutter/material.dart';

/// Type scale and [TextTheme] mapping.
///
/// Families (see `BRAND.md`):
/// - UI: Plus Jakarta Sans (`PlusJakartaSans`)
/// - Display: Sora (`Sora`)
///
/// Load faces at app/runtime via `google_fonts` (or bundled assets). Token
/// [TextStyle]s carry family names only so unit tests stay offline.
abstract final class LexivoTypography {
  static const String uiFontFamily = 'PlusJakartaSans';
  static const String displayFontFamily = 'Sora';

  static const TextStyle display = TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle title = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  /// Compact label for dense chips/badges (12/16, weight 600).
  static const TextStyle labelCompact = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  /// Compact caption for dense nav destinations (11/13.2, weight 400).
  static const TextStyle captionCompact = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w400,
  );

  /// Material [TextTheme] wired to Lexivo roles.
  static TextTheme textTheme() {
    return const TextTheme(
      displayLarge: display,
      headlineMedium: headline,
      titleMedium: title,
      bodyMedium: body,
      bodyLarge: bodyStrong,
      bodySmall: caption,
      labelLarge: label,
    );
  }
}
