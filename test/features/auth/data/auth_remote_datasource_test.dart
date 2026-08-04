import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lexivo/features/auth/domain/entities/auth_entities.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_harness.dart';

class _FakeGateway implements SupabaseAuthGateway {
  AuthSession? session;
  Failure? error;

  @override
  Stream<AuthSession?> authStateChanges() async* {
    yield session;
  }

  @override
  Future<AuthSession?> currentSession() async => session;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    if (error != null) throw error!;
    session = AuthSession(
      accessToken: 'tok',
      user: AuthUser(id: '1', email: email),
    );
    return session!;
  }

  @override
  Future<AuthSession> signUp({
    required String email,
    required String password,
    String? displayName,
  }) =>
      signIn(email: email, password: password);

  @override
  Future<void> signOut() async => session = null;

  @override
  Future<AuthSession> refreshSession() async {
    if (session == null) {
      throw const UnauthorizedFailure(message: 'none');
    }
    return session!;
  }
}

void main() {
  late _FakeGateway gateway;
  late Dio dio;
  late DioAdapter adapter;
  late AuthRemoteDatasource ds;

  setUp(() {
    gateway = _FakeGateway();
    dio = createTestDio(baseUrl: 'http://api.test');
    adapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = adapter;
    ds = AuthRemoteDatasource(
      supabase: gateway,
      apiClient: ApiClient(dio),
    );
  });

  test('signIn maps SDK errors to Failure', () async {
    gateway.error = const UnauthorizedFailure(message: 'Invalid credentials');
    final result = await ds.signIn(email: 'a', password: 'b');
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<UnauthorizedFailure>());
  });

  test('profile via ApiClient get/patch users/me', () async {
    gateway.session = const AuthSession(
      accessToken: 'tok',
      user: AuthUser(id: 'user-123', email: 'alex@lexivo.app'),
    );
    adapter.onGet(
      '/api/v1/users/me',
      (server) => server.reply(200, readFixtureSync('user_profile.json')),
    );
    adapter.onPatch(
      '/api/v1/users/me',
      (server) => server.reply(200, {
        ...readFixtureSync('user_profile.json'),
        'display_name': 'Alex2',
      }),
      data: Matchers.any,
    );

    final profile = await ds.fetchUserProfile();
    expect(profile.valueOrNull?.displayName, 'Alex');

    final updated = await ds.updateProfile(displayName: 'Alex2');
    expect(updated.valueOrNull?.displayName, 'Alex2');
  });
}
