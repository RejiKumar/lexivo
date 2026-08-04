import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/route_guards.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/supabase_auth_gateway.dart';
import '../../data/datasources/unconfigured_auth_gateway.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../screens/account_settings_screen.dart';
import '../screens/auth_home_shell.dart';
import '../screens/sign_in_screen.dart';
import '../screens/sign_up_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

final supabaseAuthGatewayProvider = Provider<SupabaseAuthGateway>((ref) {
  try {
    // Throws if Supabase.initialize was not called.
    // ignore: unnecessary_statements
    Supabase.instance.client;
    return SupabaseAuthGatewayImpl();
  } catch (_) {
    return UnconfiguredAuthGateway();
  }
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    supabase: ref.watch(supabaseAuthGatewayProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider));
});

final signUpUseCaseProvider = Provider((ref) {
  return SignUp(ref.watch(authRepositoryProvider));
});

final signInUseCaseProvider = Provider((ref) {
  return SignIn(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});

final getCurrentSessionUseCaseProvider = Provider((ref) {
  return GetCurrentSession(ref.watch(authRepositoryProvider));
});

final updateAccountSettingsUseCaseProvider = Provider((ref) {
  return UpdateAccountSettings(ref.watch(authRepositoryProvider));
});

final getAccountProfileUseCaseProvider = Provider((ref) {
  return GetAccountProfile(ref.watch(authRepositoryProvider));
});

/// Public auth state — exposed via barrel for routing / Dio token.
class AuthState {
  const AuthState({
    this.session,
    this.isLoading = false,
    this.failure,
  });

  final AuthSession? session;
  final bool isLoading;
  final Failure? failure;

  bool get isAuthenticated => session != null;

  AuthState copyWith({
    AuthSession? session,
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
    bool clearSession = false,
  }) {
    return AuthState(
      session: clearSession ? null : (session ?? this.session),
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState(isLoading: true)) {
    _init();
  }

  final Ref _ref;
  var _listening = false;

  AuthRepository get _repo => _ref.read(authRepositoryProvider);

  Future<void> _init() async {
    final result = await _repo.currentSession();
    result.when(
      success: (session) => state = AuthState(session: session),
      onFailure: (f) => state = AuthState(failure: f),
    );
    if (!_listening) {
      _listening = true;
      _repo.authStateChanges().listen((session) {
        state = AuthState(session: session);
      });
    }
  }

  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _ref.read(signInUseCaseProvider)(
      email: email,
      password: password,
    );
    result.when(
      success: (session) => state = AuthState(session: session),
      onFailure: (f) => state = AuthState(failure: f, isLoading: false),
    );
    return result;
  }

  Future<Result<AuthSession>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _ref.read(signUpUseCaseProvider)(
      email: email,
      password: password,
      displayName: displayName,
    );
    result.when(
      success: (session) => state = AuthState(session: session),
      onFailure: (f) => state = AuthState(failure: f, isLoading: false),
    );
    return result;
  }

  Future<Result<void>> signOut() async {
    final result = await _ref.read(signOutUseCaseProvider)();
    result.when(
      success: (_) => state = const AuthState(),
      onFailure: (f) => state = state.copyWith(failure: f),
    );
    return result;
  }

  Future<Result<AuthUser>> updateAccount({
    String? displayName,
    String? email,
  }) {
    return _ref.read(updateAccountSettingsUseCaseProvider)(
      displayName: displayName,
      email: email,
    );
  }

  Future<Result<AuthUser>> loadProfile() {
    return _ref.read(getAccountProfileUseCaseProvider)();
  }
}

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

/// Domain-level token reader for Dio — no data-layer imports in core.
final authAccessTokenProvider = Provider<AccessTokenReader>((ref) {
  return () async => ref.read(authStateProvider).session?.accessToken;
});

final authGuardBridgeProvider = Provider<AuthGuardState>((ref) {
  final auth = ref.watch(authStateProvider);
  return AuthGuardState(isAuthenticated: auth.isAuthenticated);
});

final authScreenBuildersBridgeProvider = Provider<AuthScreenBuilders>((ref) {
  return (
    signIn: (_) => const SignInScreen(),
    signUp: (_) => const SignUpScreen(),
    account: (_) => const AccountSettingsScreen(),
    home: (_) => const AuthHomeShell(),
  );
});

/// Profile async load for account settings.
final accountProfileProvider =
    FutureProvider.autoDispose<AuthUser>((ref) async {
  final result = await ref.watch(authStateProvider.notifier).loadProfile();
  return result.when(
    success: (user) => user,
    onFailure: (f) => throw f,
  );
});

/// Overrides to wire auth into core routing + Dio.
List<Override> authCoreOverrides() => [
      accessTokenReaderProvider.overrideWith(
        (ref) => ref.watch(authAccessTokenProvider),
      ),
      authGuardStateProvider.overrideWith(
        (ref) => ref.watch(authGuardBridgeProvider),
      ),
      authScreenBuildersProvider.overrideWith(
        (ref) => ref.watch(authScreenBuildersBridgeProvider),
      ),
    ];
