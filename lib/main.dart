import 'package:flutter/material.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  runApp(const LexivoApp());
}

/// Root application widget for Lexivo.
class LexivoApp extends StatelessWidget {
  const LexivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const LexivoHomePlaceholder(),
    );
  }
}

/// Temporary home until feature screens land after design-system DoD.
class LexivoHomePlaceholder extends StatelessWidget {
  const LexivoHomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Lexivo',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
