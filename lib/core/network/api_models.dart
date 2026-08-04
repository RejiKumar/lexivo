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
    @JsonKey(name: 'short_summary') String? shortSummary,
    @JsonKey(name: 'detailed_summary') String? detailedSummary,
    @JsonKey(name: 'summary_status') @Default('idle') String summaryStatus,
    @JsonKey(name: 'translated_text') String? translatedText,
    @JsonKey(name: 'source_lang') String? sourceLang,
    @JsonKey(name: 'target_lang') String? targetLang,
    @JsonKey(name: 'translation_status')
    @Default('idle')
    String translationStatus,
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

@freezed
abstract class SummaryStatusDto with _$SummaryStatusDto {
  const factory SummaryStatusDto({
    required String id,
    @JsonKey(name: 'summary_status') required String summaryStatus,
  }) = _SummaryStatusDto;

  factory SummaryStatusDto.fromJson(Map<String, dynamic> json) =>
      _$SummaryStatusDtoFromJson(json);
}

@freezed
abstract class TranslationRequestDto with _$TranslationRequestDto {
  const factory TranslationRequestDto({
    @JsonKey(name: 'source_lang') required String sourceLang,
    @JsonKey(name: 'target_lang') required String targetLang,
  }) = _TranslationRequestDto;

  factory TranslationRequestDto.fromJson(Map<String, dynamic> json) =>
      _$TranslationRequestDtoFromJson(json);
}

@freezed
abstract class TranslationStatusDto with _$TranslationStatusDto {
  const factory TranslationStatusDto({
    required String id,
    @JsonKey(name: 'translation_status') required String translationStatus,
    @JsonKey(name: 'source_lang') String? sourceLang,
    @JsonKey(name: 'target_lang') String? targetLang,
  }) = _TranslationStatusDto;

  factory TranslationStatusDto.fromJson(Map<String, dynamic> json) =>
      _$TranslationStatusDtoFromJson(json);
}

@freezed
abstract class CitationDto with _$CitationDto {
  const factory CitationDto({
    @JsonKey(name: 'chunk_id') String? chunkId,
    int? index,
    String? snippet,
    int? page,
    String? label,
  }) = _CitationDto;

  factory CitationDto.fromJson(Map<String, dynamic> json) =>
      _$CitationDtoFromJson(json);
}

@freezed
abstract class ChatDto with _$ChatDto {
  const factory ChatDto({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'document_id') required String documentId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ChatDto;

  factory ChatDto.fromJson(Map<String, dynamic> json) =>
      _$ChatDtoFromJson(json);
}

@freezed
abstract class ChatMessageDto with _$ChatMessageDto {
  const factory ChatMessageDto({
    required String id,
    @JsonKey(name: 'chat_id') required String chatId,
    required String role,
    required String content,
    List<CitationDto>? citations,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ChatMessageDto;

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageDtoFromJson(json);
}

@freezed
abstract class ChatMessageListDto with _$ChatMessageListDto {
  const factory ChatMessageListDto({
    @Default([]) List<ChatMessageDto> items,
  }) = _ChatMessageListDto;

  factory ChatMessageListDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageListDtoFromJson(json);
}

@freezed
abstract class ChatMessageCreateDto with _$ChatMessageCreateDto {
  const factory ChatMessageCreateDto({
    required String content,
  }) = _ChatMessageCreateDto;

  factory ChatMessageCreateDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageCreateDtoFromJson(json);
}
