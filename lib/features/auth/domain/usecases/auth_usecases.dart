import '../../../../core/utils/result.dart';
import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  const SignUp(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSession>> call({
    required String email,
    required String password,
    String? displayName,
  }) =>
      _repo.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
}

class SignIn {
  const SignIn(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSession>> call({
    required String email,
    required String password,
  }) =>
      _repo.signIn(email: email, password: password);
}

class SignOut {
  const SignOut(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call() => _repo.signOut();
}

class GetCurrentSession {
  const GetCurrentSession(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSession?>> call() => _repo.currentSession();
}

class UpdateAccountSettings {
  const UpdateAccountSettings(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthUser>> call({
    String? displayName,
    String? email,
  }) =>
      _repo.updateAccountSettings(
        displayName: displayName,
        email: email,
      );
}

class GetAccountProfile {
  const GetAccountProfile(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthUser>> call() => _repo.getAccountProfile();
}
