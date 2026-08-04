import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/features/auth/auth.dart';
import 'package:lexivo/features/translation/translation.dart';

import '../../../helpers/fake_auth_repository.dart';
import '../../../helpers/fake_translation_repository.dart';
import '../../../helpers/test_harness.dart';

void main() {
  test('translation route exists; unauthenticated → sign-in', () {
    final unauth = ProviderContainer(
      overrides: [
        showcaseEnabledProvider.overrideWith((ref) => false),
        authGuardStateProvider.overrideWith(
          (ref) => const AuthGuardState(isAuthenticated: false),
        ),
        ...translationCoreOverrides(),
      ],
    );
    addTearDown(unauth.dispose);
    final router = unauth.read(goRouterProvider);
    expect(
      router.configuration.findMatch(
        Uri.parse(RouteGuards.documentTranslation('doc-1')),
      ),
      isNotNull,
    );
    expect(
      RouteGuards.authGuard(
        auth: const AuthGuardState(isAuthenticated: false),
        location: RouteGuards.documentTranslation('doc-1'),
      ),
      RouteGuards.signIn,
    );
  });

  test('authenticated container resolves translation route', () {
    final auth = createAuthContainer(
      repository: FakeAuthRepository(initialSession: sampleSession()),
      overrides: [
        translationRepositoryProvider.overrideWithValue(
          FakeTranslationRepository(),
        ),
        ...translationCoreOverrides(),
      ],
    );
    addTearDown(auth.dispose);
    final authRouter = auth.read(goRouterProvider);
    expect(
      authRouter.configuration.findMatch(
        Uri.parse(RouteGuards.documentTranslation('doc-42')),
      ),
      isNotNull,
    );
  });

  test('RouteGuards.documentTranslation is named path only', () {
    expect(
      RouteGuards.documentTranslation('abc'),
      '/documents/abc/translation',
    );
  });
}
