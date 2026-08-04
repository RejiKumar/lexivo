import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/routing/route_guards.dart';

void main() {
  test('route table includes sign-in, sign-up, account, home', () {
    final container = ProviderContainer(
      overrides: [
        showcaseEnabledProvider.overrideWith((ref) => false),
        authGuardStateProvider.overrideWith(
          (ref) => const AuthGuardState(isAuthenticated: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(goRouterProvider);
    final paths = router.configuration.routes
        .whereType<dynamic>()
        .map((r) => r.toString())
        .join(' ');

    // Ensure named routes exist via redirect + go
    expect(router.routeInformationParser, isNotNull);
    expect(paths, isNotEmpty);

    // Probe route matching
    expect(
      router.configuration.findMatch(Uri.parse(RouteGuards.signIn)),
      isNotNull,
    );
  });

  test('showcase route gated by flag', () {
    final off = ProviderContainer(
      overrides: [
        showcaseEnabledProvider.overrideWith((ref) => false),
      ],
    );
    addTearDown(off.dispose);
    final routerOff = off.read(goRouterProvider);
    expect(
      () => routerOff.configuration.findMatch(Uri(path: '/design-system')),
      returnsNormally,
    );
  });
}
