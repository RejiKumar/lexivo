import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/utils/result.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDatasource _remote;

  @override
  Stream<AuthSession?> authStateChanges() => _remote.authStateChanges();

  @override
  Future<Result<AuthSession>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) =>
      _remote.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

  @override
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) =>
      _remote.signIn(email: email, password: password);

  @override
  Future<Result<void>> signOut() => _remote.signOut();

  @override
  Future<Result<AuthSession?>> currentSession() => _remote.currentSession();

  @override
  Future<Result<AuthSession>> refreshSession() => _remote.refreshSession();

  @override
  Future<Result<AuthUser>> getAccountProfile() => _remote.fetchUserProfile();

  @override
  Future<Result<AuthUser>> updateAccountSettings({
    String? displayName,
    String? email,
  }) =>
      _remote.updateProfile(displayName: displayName, email: email);
}
