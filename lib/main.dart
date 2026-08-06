import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lexivo/core/config/app_config.dart';
import 'package:lexivo/core/design_system/showcase/design_system_flags.dart';
import 'package:lexivo/core/design_system/showcase/design_system_showcase.dart';
import 'package:lexivo/core/l10n/l10n.dart';
import 'package:lexivo/core/observability/posthog_bootstrap.dart';
import 'package:lexivo/core/observability/sentry_bootstrap.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/features/auth/auth.dart';
import 'package:lexivo/features/document_scan/document_scan.dart';
import 'package:lexivo/features/notifications/notifications.dart';
import 'package:lexivo/features/ocr/ocr.dart';
import 'package:lexivo/features/pdf_export/pdf_export.dart';
import 'package:lexivo/features/rag_chat/rag_chat.dart';
import 'package:lexivo/features/subscription/subscription.dart';
import 'package:lexivo/features/summarization/summarization.dart';
import 'package:lexivo/features/translation/translation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppRouter.showcaseEnabled = LexivoDesignSystemFlags.showcaseEnabled;

  if (kDebugMode) {
    AppConfig.logStartupConfig(debugPrint);
  }

  final missing = AppConfig.missingRequired();
  if (missing.isNotEmpty) {
    final message =
        'Missing required dart-defines: ${missing.join(', ')}.\n'
        'Copy .env.example → .env.development, fill SUPABASE_URL and '
        'SUPABASE_ANON_KEY, then run:\n'
        '  flutter run --dart-define-from-file=.env.development -d chrome\n'
        'AI keys (Gemini/Mistral/R2) go in backend/.env — not Flutter.';
    if (kDebugMode) {
      debugPrint(message);
    }
    runApp(_MissingConfigApp(missingKeys: missing));
    return;
  }

  await initSentryIfConfigured();
  await initPosthogIfConfigured();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );

  runApp(
    ProviderScope(
      overrides: [
        ...authCoreOverrides(),
        ...documentScanCoreOverrides(),
        ...ocrCoreOverrides(),
        ...summarizationCoreOverrides(),
        ...translationCoreOverrides(),
        ...ragChatCoreOverrides(),
        ...pdfExportCoreOverrides(),
        ...notificationsCoreOverrides(),
        ...subscriptionCoreOverrides(),
        showcaseEnabledProvider.overrideWith(
          (ref) => AppRouter.showcaseEnabled,
        ),
      ],
      child: const LexivoRouterApp(),
    ),
  );
}

/// Shown when required client env is missing — avoids a cryptic SDK crash.
class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp({required this.missingKeys});

  final List<String> missingKeys;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexivo — config required',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              'Lexivo cannot start: missing required configuration.\n\n'
              'Missing: ${missingKeys.join(', ')}\n\n'
              '1. Copy .env.example to .env.development\n'
              '2. Set SUPABASE_URL and SUPABASE_ANON_KEY\n'
              '3. flutter run --dart-define-from-file=.env.development -d chrome\n\n'
              'Put GEMINI_API_KEY, MISTRAL_API_KEY, and R2_* in backend/.env only.\n'
              'Never commit secrets.',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lightweight root used by design-system showcase tests (no auth wiring).
class LexivoApp extends StatelessWidget {
  const LexivoApp({
    super.key,
    this.showcaseEnabled,
  });

  final bool? showcaseEnabled;

  bool get _showcaseOn => showcaseEnabled ?? AppRouter.showcaseEnabled;

  @override
  Widget build(BuildContext context) {
    final showShowcase = _showcaseOn;
    return MaterialApp(
      title: 'Lexivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
