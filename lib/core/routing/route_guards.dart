/// Reusable route guards (auth, subscription).
library;

/// Snapshot of auth used by guards — no feature data imports.
class AuthGuardState {
  const AuthGuardState({required this.isAuthenticated});

  final bool isAuthenticated;
}

/// Redirect helpers for GoRouter.
abstract final class RouteGuards {
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const account = '/account';
  static const home = '/';

  static const authRoutes = {signIn, signUp};

  /// Unauthenticated users hitting protected routes → sign-in.
  /// Authenticated users on auth screens → home.
  static String? authGuard({
    required AuthGuardState auth,
    required String location,
  }) {
    final onAuthRoute = authRoutes.contains(location) ||
        location.startsWith('$signIn/') ||
        location.startsWith('$signUp/');

    if (!auth.isAuthenticated && !onAuthRoute) {
      return signIn;
    }
    if (auth.isAuthenticated && onAuthRoute) {
      return home;
    }
    return null;
  }

  /// Subscription guard stub — pass-through until subscription feature lands.
  static String? subscriptionGuard({
    required AuthGuardState auth,
    required String location,
  }) {
    return null;
  }
}
