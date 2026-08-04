import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../domain/entities/auth_entities.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/utils/result.dart';

/// Real Supabase Auth gateway.
class SupabaseAuthGatewayImpl implements SupabaseAuthGateway {
  SupabaseAuthGatewayImpl([sb.SupabaseClient? client])
      : _client = client ?? sb.Supabase.instance.client;

  final sb.SupabaseClient _client;

  @override
  Stream<AuthSession?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((event) {
      return _mapSession(event.session);
    });
  }

  @override
  Future<AuthSession?> currentSession() async {
    return _mapSession(_client.auth.currentSession);
  }

  @override
  Future<AuthSession> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: displayName == null ? null : {'display_name': displayName},
    );
    final session = _mapSession(response.session);
    if (session == null) {
      throw const UnauthorizedFailure(
        message: 'Sign-up did not establish a session',
      );
    }
    return session;
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final session = _mapSession(response.session);
    if (session == null) {
      throw const UnauthorizedFailure(message: 'Invalid credentials');
    }
    return session;
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<AuthSession> refreshSession() async {
    final response = await _client.auth.refreshSession();
    final session = _mapSession(response.session);
    if (session == null) {
      throw const UnauthorizedFailure(message: 'Unable to refresh session');
    }
    return session;
  }

  AuthSession? _mapSession(sb.Session? session) {
    if (session == null) return null;
    final user = session.user;
    final meta = user.userMetadata ?? {};
    final displayName = meta['display_name'] as String? ??
        meta['full_name'] as String?;
    return AuthSession(
      accessToken: session.accessToken,
      user: AuthUser(
        id: user.id,
        email: user.email ?? '',
        displayName: displayName,
      ),
    );
  }
}
