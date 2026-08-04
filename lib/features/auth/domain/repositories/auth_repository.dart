import '../../../../core/utils/result.dart';
import '../entities/auth_entities.dart';

/// Auth repository contract — implemented in data layer.
abstract class AuthRepository {
  Stream<AuthSession?> authStateChanges();

  Future<Result<AuthSession>> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<AuthSession?>> currentSession();

  Future<Result<AuthSession>> refreshSession();

  Future<Result<AuthUser>> updateAccountSettings({
    String? displayName,
    String? email,
  });

  Future<Result<AuthUser>> getAccountProfile();
}
