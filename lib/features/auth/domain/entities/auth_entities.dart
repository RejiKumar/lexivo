import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_entities.freezed.dart';

@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    String? displayName,
  }) = _AuthUser;
}

@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required AuthUser user,
    required String accessToken,
  }) = _AuthSession;
}
