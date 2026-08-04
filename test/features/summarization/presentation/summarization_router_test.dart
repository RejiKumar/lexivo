import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/features/auth/auth.dart';
import 'package:lexivo/features/summarization/summarization.dart';

import '../../../helpers/fake_auth_repository.dart';
import '../../../helpers/fake_summarization_repository.dart';
import '../../../helpers/test_harness.dart';

void main() {
  test('summary route exists; unauthenticated → sign-in', () {
    final unauth = ProviderContainer(
      overrides: [
        showcaseEnabledProvider.overrideWith((ref) => false),
        authGuardStateProvider.overrideWith(
          (ref) => const AuthGuardState(isAuthenticated: false),
        ),
        ...summarizationCoreOverrides(),
      ],
    );
    addTearDown(unauth.dispose);
    final router = unauth.read(goRouterProvider);
    expect(
      router.configuration.findMatch(
        Uri.parse(RouteGuards.documentSummary('doc-1')),
      ),
      isNotNull,
    );
    expect(
      RouteGuards.authGuard(
        auth: const AuthGuardState(isAuthenticated: false),
        location: RouteGuards.documentSummary('doc-1'),
      ),
      RouteGuards.signIn,
    );
  });

  test('authenticated container resolves summary route', () {
    final auth = createAuthContainer(
      repository: FakeAuthRepository(initialSession: sampleSession()),
      overrides: [
        summarizationRepositoryProvider.overrideWithValue(
          FakeSummarizationRepository(),
        ),
        ...summarizationCoreOverrides(),
      ],
    );
    addTearDown(auth.dispose);
    final authRouter = auth.read(goRouterProvider);
    expect(
      authRouter.configuration.findMatch(
        Uri.parse(RouteGuards.documentSummary('doc-42')),
      ),
      isNotNull,
    );
  });

  test('RouteGuards.documentSummary is named path only', () {
    expect(
      RouteGuards.documentSummary('abc'),
      '/documents/abc/summary',
    );
  });
}
