import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/features/notifications/notifications.dart';

import '../../../helpers/fake_auth_repository.dart';
import '../../../helpers/fake_notifications_repository.dart';
import '../../../helpers/test_harness.dart';

void main() {
  test('notifications route exists; unauthenticated → sign-in', () {
    final unauth = ProviderContainer(
      overrides: [
        showcaseEnabledProvider.overrideWith((ref) => false),
        authGuardStateProvider.overrideWith(
          (ref) => const AuthGuardState(isAuthenticated: false),
        ),
        ...notificationsCoreOverrides(),
      ],
    );
    addTearDown(unauth.dispose);
    final router = unauth.read(goRouterProvider);
    expect(
      router.configuration.findMatch(Uri.parse(RouteGuards.notifications)),
      isNotNull,
    );
    expect(
      RouteGuards.authGuard(
        auth: const AuthGuardState(isAuthenticated: false),
        location: RouteGuards.notifications,
      ),
      RouteGuards.signIn,
    );
  });

  test('authenticated container resolves notifications route', () {
    final auth = createAuthContainer(
      repository: FakeAuthRepository(initialSession: sampleSession()),
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(
          FakeNotificationsRepository(),
        ),
        ...notificationsCoreOverrides(),
      ],
    );
    addTearDown(auth.dispose);
    final authRouter = auth.read(goRouterProvider);
    expect(
      authRouter.configuration.findMatch(Uri.parse(RouteGuards.notifications)),
      isNotNull,
    );
  });

  test('RouteGuards.notifications is named path only', () {
    expect(RouteGuards.notifications, '/notifications');
  });
}
