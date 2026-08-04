import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/showcase/design_system_flags.dart';
import 'package:lexivo/core/design_system/showcase/design_system_showcase.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/theming/app_theme.dart';

void main() {
  AppRouter.showcaseEnabled = LexivoDesignSystemFlags.showcaseEnabled;
  runApp(const LexivoApp());
}

/// Root application widget for Lexivo.
class LexivoApp extends StatelessWidget {
  const LexivoApp({
    super.key,
    this.showcaseEnabled,
  });

  /// Override for tests; defaults to compile-time / [AppRouter] flag.
  final bool? showcaseEnabled;

  bool get _showcaseOn =>
      showcaseEnabled ?? AppRouter.showcaseEnabled;

  @override
  Widget build(BuildContext context) {
    final showShowcase = _showcaseOn;
    return MaterialApp(
      title: 'Lexivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routes: showShowcase
          ? <String, WidgetBuilder>{
              AppRouter.designSystemShowcase: (_) =>
                  const DesignSystemShowcase(),
            }
          : const <String, WidgetBuilder>{},
      home: showShowcase
          ? const DesignSystemShowcase()
          : const LexivoHomePlaceholder(),
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
