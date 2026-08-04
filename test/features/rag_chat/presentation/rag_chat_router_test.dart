import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/features/auth/auth.dart';
import 'package:lexivo/features/rag_chat/rag_chat.dart';

import '../../../helpers/fake_auth_repository.dart';
import '../../../helpers/fake_rag_chat_repository.dart';
import '../../../helpers/test_harness.dart';

void main() {
  test('chat route exists; unauthenticated → sign-in', () {
    final unauth = ProviderContainer(
      overrides: [
        showcaseEnabledProvider.overrideWith((ref) => false),
        authGuardStateProvider.overrideWith(
          (ref) => const AuthGuardState(isAuthenticated: false),
        ),
        ...ragChatCoreOverrides(),
      ],
    );
    addTearDown(unauth.dispose);
    final router = unauth.read(goRouterProvider);
    expect(
      router.configuration.findMatch(
        Uri.parse(RouteGuards.documentChat('doc-1')),
      ),
      isNotNull,
    );
    expect(
      RouteGuards.authGuard(
        auth: const AuthGuardState(isAuthenticated: false),
        location: RouteGuards.documentChat('doc-1'),
      ),
      RouteGuards.signIn,
    );
  });

  test('authenticated container resolves chat route', () {
    final auth = createAuthContainer(
      repository: FakeAuthRepository(initialSession: sampleSession()),
      overrides: [
        ragChatRepositoryProvider.overrideWithValue(FakeRagChatRepository()),
        ...ragChatCoreOverrides(),
      ],
    );
    addTearDown(auth.dispose);
    final authRouter = auth.read(goRouterProvider);
    expect(
      authRouter.configuration.findMatch(
        Uri.parse(RouteGuards.documentChat('doc-42')),
      ),
      isNotNull,
    );
  });

  test('RouteGuards.documentChat is named path only', () {
    expect(RouteGuards.documentChat('abc'), '/documents/abc/chat');
  });
}
