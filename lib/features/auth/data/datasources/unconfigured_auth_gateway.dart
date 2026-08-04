import '../../domain/entities/auth_entities.dart';
import 'auth_remote_datasource.dart';
import '../../../../core/utils/result.dart';

/// Used when Supabase is not configured (local UI / tests without SDK).
class UnconfiguredAuthGateway implements SupabaseAuthGateway {
  @override
  Stream<AuthSession?> authStateChanges() async* {
    yield null;
  }

  @override
  Future<AuthSession?> currentSession() async => null;

  @override
  Future<AuthSession> signUp({
    required String email,
    required String password,
    String? displayName,
  }) {
    throw const UnexpectedFailure(
      message: 'Supabase is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY.',
    );
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) {
    throw const UnexpectedFailure(
      message: 'Supabase is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY.',
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthSession> refreshSession() {
    throw const UnauthorizedFailure(message: 'No session');
  }
}
