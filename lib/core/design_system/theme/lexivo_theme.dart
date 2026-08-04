import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/color.dart';
import '../tokens/typography.dart';

/// Assembles Material [ThemeData] from Lexivo design tokens (light/dark).
abstract final class LexivoTheme {
  static ThemeData light() {
    final colors = LexivoColors.light();
    final textTheme = _resolveTextTheme().apply(
      bodyColor: colors.contentPrimary,
      displayColor: colors.contentPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.backgroundDefault,
      colorScheme: ColorScheme.light(
        primary: colors.brandPrimary,
        onPrimary: colors.contentOnInverse,
        secondary: colors.brandPrimaryHover,
        onSecondary: colors.contentOnInverse,
        surface: colors.backgroundSurface,
        onSurface: colors.contentPrimary,
        error: colors.feedbackDanger,
        onError: colors.contentOnInverse,
        outline: colors.borderDefault,
      ),
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }

  static ThemeData dark() {
    final colors = LexivoColors.dark();
    final textTheme = _resolveTextTheme().apply(
      bodyColor: colors.contentPrimary,
      displayColor: colors.contentPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.backgroundDefault,
      colorScheme: ColorScheme.dark(
        primary: colors.brandPrimary,
        onPrimary: colors.contentOnInverse,
        secondary: colors.brandPrimaryHover,
        onSecondary: colors.contentOnInverse,
        surface: colors.backgroundSurface,
        onSurface: colors.contentPrimary,
        error: colors.feedbackDanger,
        onError: colors.contentOnInverse,
        outline: colors.borderDefault,
      ),
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }

  /// Applies Google Fonts faces onto token metrics when runtime fetch is allowed.
  static TextTheme _resolveTextTheme() {
    final base = LexivoTypography.textTheme();
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return base;
    }
    return TextTheme(
      displayLarge: GoogleFonts.sora(textStyle: base.displayLarge),
      headlineMedium:
          GoogleFonts.plusJakartaSans(textStyle: base.headlineMedium),
      titleMedium: GoogleFonts.plusJakartaSans(textStyle: base.titleMedium),
      bodyMedium: GoogleFonts.plusJakartaSans(textStyle: base.bodyMedium),
      bodyLarge: GoogleFonts.plusJakartaSans(textStyle: base.bodyLarge),
      bodySmall: GoogleFonts.plusJakartaSans(textStyle: base.bodySmall),
      labelLarge: GoogleFonts.plusJakartaSans(textStyle: base.labelLarge),
    );
  }
}
