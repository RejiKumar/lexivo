import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/showcase/design_system_flags.dart';
import '../design_system/showcase/design_system_showcase.dart';
import '../theming/app_theme.dart';
import 'route_guards.dart';

/// Whether the design-system showcase route is available.
final showcaseEnabledProvider = Provider<bool>((ref) {
  return LexivoDesignSystemFlags.showcaseEnabled;
});

/// Auth snapshot for redirects — override from auth feature barrel.
final authGuardStateProvider = Provider<AuthGuardState>((ref) {
  return const AuthGuardState(isAuthenticated: false);
});

/// Optional screen builders injected from `features/auth` (and later features).
typedef AuthScreenBuilders = ({
  Widget Function(BuildContext context) signIn,
  Widget Function(BuildContext context) signUp,
  Widget Function(BuildContext context) account,
  Widget Function(BuildContext context) home,
});

/// Document feature screen builders — injected from `features/document_scan` barrel.
typedef DocumentScreenBuilders = ({
  Widget Function(BuildContext context) library,
  Widget Function(BuildContext context) scan,
});

/// OCR feature screen builders — injected from `features/ocr` barrel.
typedef OcrScreenBuilders = ({
  Widget Function(BuildContext context, String documentId) result,
});

/// Summarization feature screen builders — injected from `features/summarization` barrel.
typedef SummaryScreenBuilders = ({
  Widget Function(BuildContext context, String documentId) result,
});

/// Translation feature screen builders — injected from `features/translation` barrel.
typedef TranslationScreenBuilders = ({
  Widget Function(BuildContext context, String documentId) result,
});

/// RAG chat feature screen builders — injected from `features/rag_chat` barrel.
typedef RagChatScreenBuilders = ({
  Widget Function(BuildContext context, String documentId) result,
});

/// PDF export feature screen builders — injected from `features/pdf_export` barrel.
typedef PdfExportScreenBuilders = ({
  Widget Function(BuildContext context, String documentId) result,
});

/// Notifications feature screen builders — injected from `features/notifications` barrel.
typedef NotificationsScreenBuilders = ({
  Widget Function(BuildContext context) inbox,
});

/// Subscription feature screen builders — injected from `features/subscription` barrel.
typedef SubscriptionScreenBuilders = ({
  Widget Function(BuildContext context) paywall,
  Widget Function(BuildContext context) upgrade,
  Widget Function(BuildContext context) usageSummary,
});

final authScreenBuildersProvider = Provider<AuthScreenBuilders>((ref) {
  return (
    signIn: (_) => const _StubPage(title: 'Sign in'),
    signUp: (_) => const _StubPage(title: 'Sign up'),
    account: (_) => const _StubPage(title: 'Account'),
    home: (_) => const _StubPage(title: 'Lexivo'),
  );
});

final documentScreenBuildersProvider = Provider<DocumentScreenBuilders>((ref) {
  return (
    library: (_) => const _StubPage(title: 'Documents'),
    scan: (_) => const _StubPage(title: 'Scan'),
  );
});

final ocrScreenBuildersProvider = Provider<OcrScreenBuilders>((ref) {
  return (
    result: (_, documentId) => _StubPage(title: 'OCR $documentId'),
  );
});

final summaryScreenBuildersProvider = Provider<SummaryScreenBuilders>((ref) {
  return (
    result: (_, documentId) => _StubPage(title: 'Summary $documentId'),
  );
});

final translationScreenBuildersProvider =
    Provider<TranslationScreenBuilders>((ref) {
  return (
    result: (_, documentId) => _StubPage(title: 'Translation $documentId'),
  );
});

final ragChatScreenBuildersProvider = Provider<RagChatScreenBuilders>((ref) {
  return (
    result: (_, documentId) => _StubPage(title: 'Chat $documentId'),
  );
});

final pdfExportScreenBuildersProvider = Provider<PdfExportScreenBuilders>((ref) {
  return (
    result: (_, documentId) => _StubPage(title: 'Export $documentId'),
  );
});

final notificationsScreenBuildersProvider =
    Provider<NotificationsScreenBuilders>((ref) {
  return (
    inbox: (_) => const _StubPage(title: 'Notifications'),
  );
});

final subscriptionScreenBuildersProvider =
    Provider<SubscriptionScreenBuilders>((ref) {
  return (
    paywall: (_) => const _StubPage(title: 'Subscription'),
    upgrade: (_) => const _StubPage(title: 'Upgrade'),
    usageSummary: (_) => const _StubPage(title: 'Usage'),
  );
});

/// Paywall UI visibility — override from subscription feature / tests.
final subscriptionPaywallEnabledProvider = Provider<bool>((ref) => false);

final goRouterProvider = Provider<GoRouter>((ref) {
  final builders = ref.watch(authScreenBuildersProvider);
  final documentBuilders = ref.watch(documentScreenBuildersProvider);
  final ocrBuilders = ref.watch(ocrScreenBuildersProvider);
  final summaryBuilders = ref.watch(summaryScreenBuildersProvider);
  final translationBuilders = ref.watch(translationScreenBuildersProvider);
  final ragChatBuilders = ref.watch(ragChatScreenBuildersProvider);
  final pdfExportBuilders = ref.watch(pdfExportScreenBuildersProvider);
  final notificationsBuilders = ref.watch(notificationsScreenBuildersProvider);
  final subscriptionBuilders = ref.watch(subscriptionScreenBuildersProvider);
  final showcaseEnabled = ref.watch(showcaseEnabledProvider);
  final paywallEnabled = ref.watch(subscriptionPaywallEnabledProvider);
  final refresh = _AuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: RouteGuards.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (showcaseEnabled && location == DesignSystemShowcase.routeName) {
        return null;
      }
      final auth = ref.read(authGuardStateProvider);
      final authRedirect = RouteGuards.authGuard(
        auth: auth,
        location: location,
      );
      if (authRedirect != null) return authRedirect;
      return RouteGuards.subscriptionGuard(
        auth: auth,
        location: location,
        paywallEnabled: paywallEnabled,
      );
    },
    routes: [
      GoRoute(
        path: RouteGuards.home,
        name: 'home',
        builder: (context, state) => builders.home(context),
      ),
      GoRoute(
        path: RouteGuards.signIn,
        name: 'sign-in',
        builder: (context, state) => builders.signIn(context),
      ),
      GoRoute(
        path: RouteGuards.signUp,
        name: 'sign-up',
        builder: (context, state) => builders.signUp(context),
      ),
      GoRoute(
        path: RouteGuards.account,
        name: 'account',
        builder: (context, state) => builders.account(context),
      ),
      GoRoute(
        path: RouteGuards.notifications,
        name: 'notifications',
        builder: (context, state) => notificationsBuilders.inbox(context),
      ),
      GoRoute(
        path: RouteGuards.subscription,
        name: 'subscription',
        builder: (context, state) => subscriptionBuilders.paywall(context),
        routes: [
          GoRoute(
            path: 'upgrade',
            name: 'subscription-upgrade',
            builder: (context, state) =>
                subscriptionBuilders.upgrade(context),
          ),
        ],
      ),
      GoRoute(
        path: RouteGuards.documents,
        name: 'documents',
        builder: (context, state) => documentBuilders.library(context),
        routes: [
          GoRoute(
            path: 'scan',
            name: 'document-scan',
            builder: (context, state) => documentBuilders.scan(context),
          ),
          GoRoute(
            path: ':documentId/ocr',
            name: 'document-ocr',
            builder: (context, state) {
              final documentId = state.pathParameters['documentId']!;
              return ocrBuilders.result(context, documentId);
            },
          ),
          GoRoute(
            path: ':documentId/summary',
            name: 'document-summary',
            builder: (context, state) {
              final documentId = state.pathParameters['documentId']!;
              return summaryBuilders.result(context, documentId);
            },
          ),
          GoRoute(
            path: ':documentId/translation',
            name: 'document-translation',
            builder: (context, state) {
              final documentId = state.pathParameters['documentId']!;
              return translationBuilders.result(context, documentId);
            },
          ),
          GoRoute(
            path: ':documentId/chat',
            name: 'document-chat',
            builder: (context, state) {
              final documentId = state.pathParameters['documentId']!;
              return ragChatBuilders.result(context, documentId);
            },
          ),
          GoRoute(
            path: ':documentId/export',
            name: 'document-export',
            builder: (context, state) {
              final documentId = state.pathParameters['documentId']!;
              return pdfExportBuilders.result(context, documentId);
            },
          ),
        ],
      ),
      if (showcaseEnabled)
        GoRoute(
          path: DesignSystemShowcase.routeName,
          name: 'design-system-showcase',
          builder: (context, state) => const DesignSystemShowcase(),
        ),
    ],
  );
});

/// Legacy static helpers used by older tests / showcase wiring.
abstract final class AppRouter {
  static bool showcaseEnabled = LexivoDesignSystemFlags.showcaseEnabled;

  static const String home = RouteGuards.home;
  static const String signIn = RouteGuards.signIn;
  static const String signUp = RouteGuards.signUp;
  static const String account = RouteGuards.account;
  static const String documents = RouteGuards.documents;
  static const String documentScan = RouteGuards.documentScan;
  static const String designSystemShowcase = DesignSystemShowcase.routeName;

  static Widget? pageForRoute(String routeName) {
    switch (routeName) {
      case designSystemShowcase:
        if (!showcaseEnabled) return null;
        return const DesignSystemShowcase();
      default:
        return null;
    }
  }

  static Map<String, WidgetBuilder> get routes {
    if (!showcaseEnabled) return const {};
    return {
      designSystemShowcase: (_) => const DesignSystemShowcase(),
    };
  }

  static Widget? initialHome() {
    if (!showcaseEnabled) return null;
    return const DesignSystemShowcase();
  }
}

class _StubPage extends StatelessWidget {
  const _StubPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}

/// Notifies GoRouter when [authGuardStateProvider] changes.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this._ref) {
    _ref.listen<AuthGuardState>(authGuardStateProvider, (_, _) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

/// Root app using GoRouter + Riverpod.
class LexivoRouterApp extends ConsumerWidget {
  const LexivoRouterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Lexivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
