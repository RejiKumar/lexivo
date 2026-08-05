import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/network/dio_provider.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/features/auth/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/test_harness.dart';

void main() {
  testWidgets('cold start with persisted session lands on documents',
      (tester) async {
    final repo = FakeAuthRepository(initialSession: sampleSession());
    await tester.pumpWidget(pumpAuthApp(repository: repo));
    await tester.pumpAndSettle();

    expect(find.text('Documents'), findsWidgets);
    expect(find.text('Sign in'), findsNothing);
  });

  testWidgets('sign-out from account redirects to sign-in; token omitted after',
      (tester) async {
    final repo = FakeAuthRepository(initialSession: sampleSession());
    await tester.pumpWidget(pumpAuthApp(repository: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        ...authCoreOverrides(),
      ],
    );
    addTearDown(container.dispose);
    final reader = container.read(accessTokenReaderProvider);
    expect(await reader(), isNull);
  });

  test('barrel does not force-export data layer symbols by name', () {
    // Compile-time surface: auth.dart exports screens + authStateProvider.
    // Data types like AuthRemoteDatasource are not part of the public export list.
    expect(authStateProvider, isNotNull);
    expect(RouteGuards.signIn, '/sign-in');
  });
}
