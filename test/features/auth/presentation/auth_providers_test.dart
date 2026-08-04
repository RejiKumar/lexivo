import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/auth/presentation/providers/auth_providers.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  test('auth state: unauthenticated → authenticated after sign-in', () async {
    final repo = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(() {
      repo.dispose();
      container.dispose();
    });

    // Allow init to complete
    await Future<void>.delayed(Duration.zero);
    expect(container.read(authStateProvider).isAuthenticated, isFalse);

    final result = await container.read(authStateProvider.notifier).signIn(
          email: 'alex@lexivo.app',
          password: 'secret',
        );
    expect(result.isSuccess, isTrue);
    expect(container.read(authStateProvider).isAuthenticated, isTrue);
  });

  test('invalid credentials surface Failure without session', () async {
    final repo = FakeAuthRepository();
    repo.nextFailure = const UnauthorizedFailure(message: 'Invalid credentials');
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(() {
      repo.dispose();
      container.dispose();
    });

    await container.read(authStateProvider.notifier).signIn(
          email: 'x',
          password: 'y',
        );
    final state = container.read(authStateProvider);
    expect(state.isAuthenticated, isFalse);
    expect(state.failure, isA<UnauthorizedFailure>());
  });

  test('session restored when repository has persisted session', () async {
    final repo = FakeAuthRepository(initialSession: sampleSession());
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(() {
      repo.dispose();
      container.dispose();
    });

    // Force notifier creation and await init.
    container.read(authStateProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(container.read(authStateProvider).isAuthenticated, isTrue);
    expect(
      container.read(authStateProvider).session?.accessToken,
      'test-access-token',
    );
  });

  test('sign-out clears session', () async {
    final repo = FakeAuthRepository(initialSession: sampleSession());
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(() {
      repo.dispose();
      container.dispose();
    });
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await container.read(authStateProvider.notifier).signOut();
    expect(container.read(authStateProvider).isAuthenticated, isFalse);
  });
}
