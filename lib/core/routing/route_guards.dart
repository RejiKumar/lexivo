/// Reusable route guards (auth, subscription).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Snapshot of auth used by guards — no feature data imports.
class AuthGuardState {
  const AuthGuardState({
    required this.isAuthenticated,
    this.isLoading = false,
  });

  final bool isAuthenticated;
  final bool isLoading;
}

/// Auth snapshot for redirects — override from auth feature barrel.
final authGuardStateProvider = Provider<AuthGuardState>((ref) {
  return const AuthGuardState(isAuthenticated: false);
});

/// Redirect helpers for GoRouter.
abstract final class RouteGuards {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const account = '/account';
  static const home = '/';
  static const documents = '/documents';
  static const documentScan = '/documents/scan';
  static const notifications = '/notifications';

  /// OCR result for [documentId].
  static String documentOcr(String documentId) =>
      '/documents/$documentId/ocr';

  /// Summarization for [documentId].
  static String documentSummary(String documentId) =>
      '/documents/$documentId/summary';

  /// Translation for [documentId].
  static String documentTranslation(String documentId) =>
      '/documents/$documentId/translation';

  /// Ask-the-document chat for [documentId].
  static String documentChat(String documentId) =>
      '/documents/$documentId/chat';

  /// PDF export for [documentId].
  static String documentExport(String documentId) =>
      '/documents/$documentId/export';

  static const subscription = '/subscription';
  static const subscriptionUpgrade = '/subscription/upgrade';

  static const authRoutes = {signIn, signUp};

  static bool isSubscriptionRoute(String location) =>
      location == subscription ||
      location == subscriptionUpgrade ||
      location.startsWith('$subscription/');

  /// Unauthenticated users hitting protected routes → sign-in.
  /// Authenticated users on auth screens → documents (primary home).
  /// Splash is exempt so the branded intro can finish before routing.
  static String? authGuard({
    required AuthGuardState auth,
    required String location,
  }) {
    if (location == splash) {
      return null;
    }

    final onAuthRoute = authRoutes.contains(location) ||
        location.startsWith('$signIn/') ||
        location.startsWith('$signUp/');

    if (!auth.isAuthenticated && !onAuthRoute) {
      return signIn;
    }
    if (auth.isAuthenticated && onAuthRoute) {
      return documents;
    }
    return null;
  }

  /// Hide paywall/upgrade routes when [paywallEnabled] is false.
  /// Auth remains the responsibility of [authGuard].
  static String? subscriptionGuard({
    required AuthGuardState auth,
    required String location,
    bool paywallEnabled = false,
  }) {
    if (!paywallEnabled && isSubscriptionRoute(location)) {
      return account;
    }
    return null;
  }
}
