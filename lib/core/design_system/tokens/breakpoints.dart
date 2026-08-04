import 'spacing.dart';

/// Shared layout breakpoints for Lexivo (Responsive Framework–compatible).
///
/// Features adapt spacing/typography using these widths with the same token
/// scales — not separate mobile/web component sets. Wire via
/// `responsive_framework` (or equivalent) when the app shell lands; until then
/// consumers call [LexivoBreakpoints.resolve] from [MediaQuery] width.
///
/// Aligns with ui_design_system.md §5 (`mobile`, `tablet`, `desktop`).
enum LexivoBreakpoint { mobile, tablet, desktop }

abstract final class LexivoBreakpoints {
  /// Max width for [LexivoBreakpoint.mobile] (exclusive upper bound of tablet).
  static const double mobileMax = 599;

  /// Max width for [LexivoBreakpoint.tablet] (exclusive upper bound of desktop).
  static const double tabletMax = 1023;

  /// Resolves the active breakpoint from a logical width.
  static LexivoBreakpoint resolve(double width) {
    if (width <= mobileMax) return LexivoBreakpoint.mobile;
    if (width <= tabletMax) return LexivoBreakpoint.tablet;
    return LexivoBreakpoint.desktop;
  }

  /// Horizontal page padding scaled by breakpoint (spacing tokens only).
  static double pagePadding(LexivoBreakpoint breakpoint) {
    switch (breakpoint) {
      case LexivoBreakpoint.mobile:
        return LexivoSpacing.md;
      case LexivoBreakpoint.tablet:
        return LexivoSpacing.lg;
      case LexivoBreakpoint.desktop:
        return LexivoSpacing.xl;
    }
  }
}
