import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/features/auth/auth.dart';
import 'package:lexivo/features/auth/domain/usecases/auth_usecases.dart';

import '../../../helpers/fake_auth_repository.dart';
import 'package:lexivo/core/utils/result.dart';

void main() {
  group('Auth entities', () {
    test('AuthUser / AuthSession equality', () {
      const user = AuthUser(id: '1', email: 'a@b.c', displayName: 'A');
      final session = AuthSession(user: user, accessToken: 't');
      expect(session.user.email, 'a@b.c');
      expect(session.copyWith(accessToken: 't2').accessToken, 't2');
    });
  });

  group('Usecases', () {
    late FakeAuthRepository repo;

    setUp(() => repo = FakeAuthRepository());
    tearDown(() => repo.dispose());

    test('SignIn / SignUp / SignOut / GetCurrentSession / UpdateAccount',
        () async {
      final signIn = SignIn(repo);
      final signUp = SignUp(repo);
      final signOut = SignOut(repo);
      final current = GetCurrentSession(repo);
      final update = UpdateAccountSettings(repo);

      final created = await signUp(
        email: 'new@lexivo.app',
        password: 'secret1',
        displayName: 'New',
      );
      expect(created.isSuccess, isTrue);

      await signOut();
      expect((await current()).valueOrNull, isNull);

      repo.nextFailure = const UnauthorizedFailure(message: 'bad');
      final bad = await signIn(email: 'x', password: 'y');
      expect(bad.isFailure, isTrue);

      final ok = await signIn(email: 'alex@lexivo.app', password: 'secret1');
      expect(ok.isSuccess, isTrue);

      final updated = await update(displayName: 'Alex2');
      expect(updated.valueOrNull?.displayName, 'Alex2');
    });
  });
}
