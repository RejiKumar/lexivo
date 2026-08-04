import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/features/auth/auth.dart';
import 'package:lexivo/features/document_scan/document_scan.dart';

import '../../../helpers/fake_auth_repository.dart';
import '../../../helpers/fake_document_input_source.dart';
import '../../../helpers/fake_document_repository.dart';
import '../../../helpers/test_harness.dart';

void main() {
  test('document routes exist; unauthenticated redirect leaves guard', () {
    final unauth = ProviderContainer(
      overrides: [
        showcaseEnabledProvider.overrideWith((ref) => false),
        authGuardStateProvider.overrideWith(
          (ref) => const AuthGuardState(isAuthenticated: false),
        ),
        ...documentScanCoreOverrides(),
      ],
    );
    addTearDown(unauth.dispose);
    final router = unauth.read(goRouterProvider);
    expect(
      router.configuration.findMatch(Uri.parse(RouteGuards.documents)),
      isNotNull,
    );
    expect(
      router.configuration.findMatch(Uri.parse(RouteGuards.documentScan)),
      isNotNull,
    );
    expect(
      RouteGuards.authGuard(
        auth: const AuthGuardState(isAuthenticated: false),
        location: RouteGuards.documents,
      ),
      RouteGuards.signIn,
    );
  });

  test('authenticated container can resolve document routes', () {
    final auth = createAuthContainer(
      repository: FakeAuthRepository(initialSession: sampleSession()),
      overrides: [
        documentRepositoryProvider.overrideWithValue(FakeDocumentRepository()),
        documentInputSourceProvider.overrideWithValue(FakeDocumentInputSource()),
        ...documentScanCoreOverrides(),
      ],
    );
    addTearDown(auth.dispose);
    final authRouter = auth.read(goRouterProvider);
    expect(
      authRouter.configuration.findMatch(Uri.parse(RouteGuards.documents)),
      isNotNull,
    );
    expect(
      authRouter.configuration.findMatch(Uri.parse(RouteGuards.documentScan)),
      isNotNull,
    );
  });
}
