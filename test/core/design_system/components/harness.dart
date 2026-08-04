import 'package:flutter/material.dart';
import 'package:lexivo/core/theming/app_theme.dart';

/// Shared pump wrapper for design-system widget and golden tests.
Widget wrapWithLexivoTheme({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
  Size? surfaceSize,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: surfaceSize == null
            ? child
            : SizedBox(
                width: surfaceSize.width,
                height: surfaceSize.height,
                child: child,
              ),
      ),
    ),
  );
}
