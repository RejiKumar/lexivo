import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/routing/route_guards.dart';

void main() {
  group('RouteGuards.authGuard', () {
    test('unauthenticated → sign-in for protected routes', () {
      expect(
        RouteGuards.authGuard(
          auth: const AuthGuardState(isAuthenticated: false),
          location: RouteGuards.home,
        ),
        RouteGuards.signIn,
      );
      expect(
        RouteGuards.authGuard(
          auth: const AuthGuardState(isAuthenticated: false),
          location: RouteGuards.account,
        ),
        RouteGuards.signIn,
      );
    });

    test('unauthenticated may stay on auth screens', () {
      expect(
        RouteGuards.authGuard(
          auth: const AuthGuardState(isAuthenticated: false),
          location: RouteGuards.signIn,
        ),
        isNull,
      );
      expect(
        RouteGuards.authGuard(
          auth: const AuthGuardState(isAuthenticated: false),
          location: RouteGuards.signUp,
        ),
        isNull,
      );
    });

    test('authenticated on auth screens → documents', () {
      expect(
        RouteGuards.authGuard(
          auth: const AuthGuardState(isAuthenticated: true),
          location: RouteGuards.signIn,
        ),
        RouteGuards.documents,
      );
    });

    test('subscription stub pass-through', () {
      expect(
        RouteGuards.subscriptionGuard(
          auth: const AuthGuardState(isAuthenticated: true),
          location: RouteGuards.home,
        ),
        isNull,
      );
    });

    test('subscription guard redirects when paywall off', () {
      expect(
        RouteGuards.subscriptionGuard(
          auth: const AuthGuardState(isAuthenticated: true),
          location: RouteGuards.subscription,
          paywallEnabled: false,
        ),
        RouteGuards.account,
      );
    });
  });
}
