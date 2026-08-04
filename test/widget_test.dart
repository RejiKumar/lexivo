import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/routing/route_guards.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/test_harness.dart';

void main() {
  testWidgets('LexivoRouterApp shows sign-in when unauthenticated',
      (tester) async {
    final repo = FakeAuthRepository();
    await tester.pumpWidget(pumpAuthApp(repository: repo));
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Lexivo'), findsWidgets);
  });

  test('route constants exist', () {
    expect(RouteGuards.home, '/');
    expect(AppRouter.signIn, '/sign-in');
  });
}
