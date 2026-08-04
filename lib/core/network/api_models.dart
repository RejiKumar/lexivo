import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_models.freezed.dart';
part 'api_models.g.dart';

@freezed
abstract class AuthSessionDto with _$AuthSessionDto {
  const factory AuthSessionDto({
    required String subject,
    String? email,
    @JsonKey(name: 'display_name') String? displayName,
  }) = _AuthSessionDto;

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionDtoFromJson(json);
}

@freezed
abstract class UserProfileDto with _$UserProfileDto {
  const factory UserProfileDto({
    required String id,
    @JsonKey(name: 'external_id') required String externalId,
    String? email,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserProfileDto;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);
}

@freezed
abstract class UserProfileUpdateDto with _$UserProfileUpdateDto {
  const factory UserProfileUpdateDto({
    @JsonKey(name: 'display_name') String? displayName,
    String? email,
  }) = _UserProfileUpdateDto;

  factory UserProfileUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileUpdateDtoFromJson(json);
}

@freezed
abstract class DocumentDto with _$DocumentDto {
  const factory DocumentDto({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    String? title,
    @JsonKey(name: 'storage_key') String? storageKey,
    required String status,
    @JsonKey(name: 'extracted_text') String? extractedText,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _DocumentDto;

  factory DocumentDto.fromJson(Map<String, dynamic> json) =>
      _$DocumentDtoFromJson(json);
}

@freezed
abstract class DocumentListDto with _$DocumentListDto {
  const factory DocumentListDto({
    @Default([]) List<DocumentDto> items,
  }) = _DocumentListDto;

  factory DocumentListDto.fromJson(Map<String, dynamic> json) =>
      _$DocumentListDtoFromJson(json);
}

@freezed
abstract class DocumentStatusDto with _$DocumentStatusDto {
  const factory DocumentStatusDto({
    required String id,
    required String status,
  }) = _DocumentStatusDto;

  factory DocumentStatusDto.fromJson(Map<String, dynamic> json) =>
      _$DocumentStatusDtoFromJson(json);
}
