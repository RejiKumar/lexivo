import 'package:flutter/material.dart';

import '../design_system/showcase/design_system_flags.dart';
import '../design_system/showcase/design_system_showcase.dart';

/// Route table stubs for Lexivo.
///
/// Showcase is registered only when [showcaseEnabled] is true (compile-time
/// `--dart-define=LEXIVO_SHOWCASE=true` or an explicit test override).
abstract final class AppRouter {
  /// Whether the design-system showcase route is available.
  static bool showcaseEnabled = LexivoDesignSystemFlags.showcaseEnabled;

  static const String home = '/';
  static const String designSystemShowcase = DesignSystemShowcase.routeName;

  /// Builds the widget for [routeName], or null when unknown / gated off.
  static Widget? pageForRoute(String routeName) {
    switch (routeName) {
      case designSystemShowcase:
        if (!showcaseEnabled) return null;
        return const DesignSystemShowcase();
      default:
        return null;
    }
  }

  /// Named routes map for [MaterialApp.routes] — empty when showcase is off.
  static Map<String, WidgetBuilder> get routes {
    if (!showcaseEnabled) return const {};
    return {
      designSystemShowcase: (_) => const DesignSystemShowcase(),
    };
  }

  /// Initial home widget: showcase when flagged, else null (caller supplies default).
  static Widget? initialHome() {
    if (!showcaseEnabled) return null;
    return const DesignSystemShowcase();
  }
}
