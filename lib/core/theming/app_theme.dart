import 'package:flutter/material.dart';

import '../design_system/theme/lexivo_theme.dart';

/// App-level theme entrypoint. Delegates to design-system token assembly.
abstract final class AppTheme {
  static ThemeData get light => LexivoTheme.light();

  static ThemeData get dark => LexivoTheme.dark();
}
