import 'dart:async';

import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/auth/domain/entities/auth_entities.dart';
import 'package:lexivo/features/auth/domain/repositories/auth_repository.dart';

/// Shared fake [AuthRepository] for provider / widget tests.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthSession? initialSession})
      : _session = initialSession;

  AuthSession? _session;
  final _controller = StreamController<AuthSession?>.broadcast();
  Failure? nextFailure;
  AuthUser? profileOverride;

  void seedSession(AuthSession? session) {
    _session = session;
    _controller.add(session);
  }

  @override
  Stream<AuthSession?> authStateChanges() async* {
    yield _session;
    yield* _controller.stream;
  }

  @override
  Future<Result<AuthSession?>> currentSession() async {
    if (nextFailure != null) return Result.failure(nextFailure!);
    return Result.success(_session);
  }

  @override
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) async {
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return Result.failure(f);
    }
    final session = AuthSession(
      accessToken: 'token-$email',
      user: AuthUser(id: 'id-$email', email: email, displayName: 'User'),
    );
    seedSession(session);
    return Result.success(session);
  }

  @override
  Future<Result<AuthSession>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return Result.failure(f);
    }
    final session = AuthSession(
      accessToken: 'token-$email',
      user: AuthUser(
        id: 'id-$email',
        email: email,
        displayName: displayName,
      ),
    );
    seedSession(session);
    return Result.success(session);
  }

  @override
  Future<Result<void>> signOut() async {
    seedSession(null);
    return Result.success(null);
  }

  @override
  Future<Result<AuthSession>> refreshSession() async {
    if (_session == null) {
      return Result.failure(
        const UnauthorizedFailure(message: 'No session'),
      );
    }
    return Result.success(_session!);
  }

  @override
  Future<Result<AuthUser>> getAccountProfile() async {
    if (nextFailure != null) return Result.failure(nextFailure!);
    if (profileOverride != null) return Result.success(profileOverride!);
    final session = _session;
    if (session == null) {
      return Result.failure(const UnauthorizedFailure());
    }
    return Result.success(session.user);
  }

  @override
  Future<Result<AuthUser>> updateAccountSettings({
    String? displayName,
    String? email,
  }) async {
    if (nextFailure != null) return Result.failure(nextFailure!);
    final session = _session;
    if (session == null) {
      return Result.failure(const UnauthorizedFailure());
    }
    final updated = session.user.copyWith(
      displayName: displayName ?? session.user.displayName,
      email: email ?? session.user.email,
    );
    seedSession(session.copyWith(user: updated));
    profileOverride = updated;
    return Result.success(updated);
  }

  void dispose() => _controller.close();
}

AuthSession sampleSession({
  String email = 'alex@lexivo.app',
  String token = 'test-access-token',
}) {
  return AuthSession(
    accessToken: token,
    user: AuthUser(id: 'user-123', email: email, displayName: 'Alex'),
  );
}
