import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_models.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_entities.dart';

/// Abstraction over Supabase Auth SDK for testability.
abstract class SupabaseAuthGateway {
  Stream<AuthSession?> authStateChanges();
  Future<AuthSession?> currentSession();
  Future<AuthSession> signUp({
    required String email,
    required String password,
    String? displayName,
  });
  Future<AuthSession> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<AuthSession> refreshSession();
}

/// Maps Supabase session + backend profile endpoints.
class AuthRemoteDatasource {
  AuthRemoteDatasource({
    required SupabaseAuthGateway supabase,
    required ApiClient apiClient,
  })  : _supabase = supabase,
        _api = apiClient;

  final SupabaseAuthGateway _supabase;
  final ApiClient _api;

  Stream<AuthSession?> authStateChanges() => _supabase.authStateChanges();

  Future<Result<AuthSession>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final session = await _supabase.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Result.success(session);
    } catch (e) {
      return Result.failure(_mapAuthError(e));
    }
  }

  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _supabase.signIn(
        email: email,
        password: password,
      );
      return Result.success(session);
    } catch (e) {
      return Result.failure(_mapAuthError(e));
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await _supabase.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapAuthError(e));
    }
  }

  Future<Result<AuthSession?>> currentSession() async {
    try {
      return Result.success(await _supabase.currentSession());
    } catch (e) {
      return Result.failure(_mapAuthError(e));
    }
  }

  Future<Result<AuthSession>> refreshSession() async {
    try {
      return Result.success(await _supabase.refreshSession());
    } catch (e) {
      return Result.failure(_mapAuthError(e));
    }
  }

  Future<Result<AuthUser>> fetchProfile() async {
    final me = await _api.getAuthMe();
    return me.when(
      success: (dto) => Result.success(_userFromAuthMe(dto)),
      onFailure: Result.failure,
    );
  }

  Future<Result<AuthUser>> fetchUserProfile() async {
    final profile = await _api.getUserMe();
    return profile.when(
      success: (dto) => Result.success(_userFromProfile(dto)),
      onFailure: Result.failure,
    );
  }

  Future<Result<AuthUser>> updateProfile({
    String? displayName,
    String? email,
  }) async {
    final updated = await _api.patchUserMe(
      UserProfileUpdateDto(displayName: displayName, email: email),
    );
    return updated.when(
      success: (dto) => Result.success(_userFromProfile(dto)),
      onFailure: Result.failure,
    );
  }

  AuthUser _userFromAuthMe(AuthSessionDto dto) => AuthUser(
        id: dto.subject,
        email: dto.email ?? '',
        displayName: dto.displayName,
      );

  AuthUser _userFromProfile(UserProfileDto dto) => AuthUser(
        id: dto.externalId,
        email: dto.email ?? '',
        displayName: dto.displayName,
      );

  Failure _mapAuthError(Object e) {
    if (e is Failure) return e;
    final message = e.toString().toLowerCase();
    if (message.contains('invalid') ||
        message.contains('credentials') ||
        message.contains('auth')) {
      return UnauthorizedFailure(message: e.toString(), cause: e);
    }
    return UnexpectedFailure(message: e.toString(), cause: e);
  }
}
