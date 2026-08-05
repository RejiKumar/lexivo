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

@freezed
abstract class ExportRequestDto with _$ExportRequestDto {
  const factory ExportRequestDto({
    @JsonKey(name: 'include_summary') @Default(false) bool includeSummary,
    @JsonKey(name: 'include_translation')
    @Default(false)
    bool includeTranslation,
    @JsonKey(name: 'include_chat') @Default(false) bool includeChat,
  }) = _ExportRequestDto;

  factory ExportRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ExportRequestDtoFromJson(json);
}

@freezed
abstract class ExportStatusDto with _$ExportStatusDto {
  const factory ExportStatusDto({
    required String id,
    @JsonKey(name: 'document_id') required String documentId,
    @JsonKey(name: 'include_summary') @Default(false) bool includeSummary,
    @JsonKey(name: 'include_translation')
    @Default(false)
    bool includeTranslation,
    @JsonKey(name: 'include_chat') @Default(false) bool includeChat,
    @JsonKey(name: 'export_status') required String exportStatus,
    @JsonKey(name: 'storage_key') String? storageKey,
    @JsonKey(name: 'signed_url') String? signedUrl,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ExportStatusDto;

  factory ExportStatusDto.fromJson(Map<String, dynamic> json) =>
      _$ExportStatusDtoFromJson(json);
}

@freezed
abstract class NotificationDto with _$NotificationDto {
  const factory NotificationDto({
    required String id,
    required String type,
    required String title,
    required String body,
    @Default(<String, dynamic>{}) Map<String, dynamic> payload,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _NotificationDto;

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);
}

@freezed
abstract class NotificationListDto with _$NotificationListDto {
  const factory NotificationListDto({
    @Default(<NotificationDto>[]) List<NotificationDto> items,
    @Default(0) int total,
  }) = _NotificationListDto;

  factory NotificationListDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationListDtoFromJson(json);
}

@freezed
abstract class UsageBucketDto with _$UsageBucketDto {
  const factory UsageBucketDto({
    required int used,
    required int limit,
    required String period,
  }) = _UsageBucketDto;

  factory UsageBucketDto.fromJson(Map<String, dynamic> json) =>
      _$UsageBucketDtoFromJson(json);
}

@freezed
abstract class UsageBreakdownDto with _$UsageBreakdownDto {
  const factory UsageBreakdownDto({
    required UsageBucketDto documents,
    @JsonKey(name: 'chat_messages') required UsageBucketDto chatMessages,
    @JsonKey(name: 'ocr_pages') required UsageBucketDto ocrPages,
  }) = _UsageBreakdownDto;

  factory UsageBreakdownDto.fromJson(Map<String, dynamic> json) =>
      _$UsageBreakdownDtoFromJson(json);
}

@freezed
abstract class SubscriptionMeDto with _$SubscriptionMeDto {
  const factory SubscriptionMeDto({
    required String tier,
    @Default('active') String status,
    @JsonKey(name: 'paywall_enabled') required bool paywallEnabled,
    required UsageBreakdownDto usage,
  }) = _SubscriptionMeDto;

  factory SubscriptionMeDto.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionMeDtoFromJson(json);
}

@freezed
abstract class SubscriptionUpgradeDto with _$SubscriptionUpgradeDto {
  const factory SubscriptionUpgradeDto({
    required String tier,
    @Default('active') String status,
    @JsonKey(name: 'paywall_enabled') @Default(true) bool paywallEnabled,
  }) = _SubscriptionUpgradeDto;

  factory SubscriptionUpgradeDto.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionUpgradeDtoFromJson(json);
}

@freezed
abstract class PlatformVersionInfoDto with _$PlatformVersionInfoDto {
  const factory PlatformVersionInfoDto({
    @JsonKey(name: 'latest_version') required String latestVersion,
    @JsonKey(name: 'min_supported_version') required String minSupportedVersion,
    @JsonKey(name: 'store_url') @Default('') String storeUrl,
  }) = _PlatformVersionInfoDto;

  factory PlatformVersionInfoDto.fromJson(Map<String, dynamic> json) =>
      _$PlatformVersionInfoDtoFromJson(json);
}

@freezed
abstract class WebVersionInfoDto with _$WebVersionInfoDto {
  const factory WebVersionInfoDto({
    @JsonKey(name: 'latest_version') required String latestVersion,
    @JsonKey(name: 'min_supported_version') required String minSupportedVersion,
  }) = _WebVersionInfoDto;

  factory WebVersionInfoDto.fromJson(Map<String, dynamic> json) =>
      _$WebVersionInfoDtoFromJson(json);
}

@freezed
abstract class AppVersionDto with _$AppVersionDto {
  const factory AppVersionDto({
    @JsonKey(name: 'latest_version') required String latestVersion,
    @JsonKey(name: 'min_supported_version') required String minSupportedVersion,
    @JsonKey(name: 'soft_update_message') required String softUpdateMessage,
    @JsonKey(name: 'force_update_message') required String forceUpdateMessage,
    required PlatformVersionInfoDto android,
    required PlatformVersionInfoDto ios,
    required WebVersionInfoDto web,
  }) = _AppVersionDto;

  factory AppVersionDto.fromJson(Map<String, dynamic> json) =>
      _$AppVersionDtoFromJson(json);
}
