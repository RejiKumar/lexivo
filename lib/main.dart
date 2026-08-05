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

  await initSentryIfConfigured();
  await initPosthogIfConfigured();

  final supabaseUrl = AppConfig.supabaseUrl;
  final supabaseAnonKey = AppConfig.supabaseAnonKey;

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  } else if (kDebugMode) {
    debugPrint(
      'SUPABASE_URL / SUPABASE_ANON_KEY not set — auth SDK deferred. '
      'See .env.example.',
    );
  }

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
