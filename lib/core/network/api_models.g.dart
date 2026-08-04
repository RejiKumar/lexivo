// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthSessionDto _$AuthSessionDtoFromJson(Map<String, dynamic> json) =>
    _AuthSessionDto(
      subject: json['subject'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
    );

Map<String, dynamic> _$AuthSessionDtoToJson(_AuthSessionDto instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'email': instance.email,
      'display_name': instance.displayName,
    };

_UserProfileDto _$UserProfileDtoFromJson(Map<String, dynamic> json) =>
    _UserProfileDto(
      id: json['id'] as String,
      externalId: json['external_id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserProfileDtoToJson(_UserProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'external_id': instance.externalId,
      'email': instance.email,
      'display_name': instance.displayName,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_UserProfileUpdateDto _$UserProfileUpdateDtoFromJson(
  Map<String, dynamic> json,
) => _UserProfileUpdateDto(
  displayName: json['display_name'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$UserProfileUpdateDtoToJson(
  _UserProfileUpdateDto instance,
) => <String, dynamic>{
  'display_name': instance.displayName,
  'email': instance.email,
};

_DocumentDto _$DocumentDtoFromJson(Map<String, dynamic> json) => _DocumentDto(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String?,
  storageKey: json['storage_key'] as String?,
  status: json['status'] as String,
  extractedText: json['extracted_text'] as String?,
  shortSummary: json['short_summary'] as String?,
  detailedSummary: json['detailed_summary'] as String?,
  summaryStatus: json['summary_status'] as String? ?? 'idle',
  translatedText: json['translated_text'] as String?,
  sourceLang: json['source_lang'] as String?,
  targetLang: json['target_lang'] as String?,
  translationStatus: json['translation_status'] as String? ?? 'idle',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$DocumentDtoToJson(_DocumentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'storage_key': instance.storageKey,
      'status': instance.status,
      'extracted_text': instance.extractedText,
      'short_summary': instance.shortSummary,
      'detailed_summary': instance.detailedSummary,
      'summary_status': instance.summaryStatus,
      'translated_text': instance.translatedText,
      'source_lang': instance.sourceLang,
      'target_lang': instance.targetLang,
      'translation_status': instance.translationStatus,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_DocumentListDto _$DocumentListDtoFromJson(Map<String, dynamic> json) =>
    _DocumentListDto(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => DocumentDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DocumentListDtoToJson(_DocumentListDto instance) =>
    <String, dynamic>{'items': instance.items};

_DocumentStatusDto _$DocumentStatusDtoFromJson(Map<String, dynamic> json) =>
    _DocumentStatusDto(
      id: json['id'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$DocumentStatusDtoToJson(_DocumentStatusDto instance) =>
    <String, dynamic>{'id': instance.id, 'status': instance.status};

_SummaryStatusDto _$SummaryStatusDtoFromJson(Map<String, dynamic> json) =>
    _SummaryStatusDto(
      id: json['id'] as String,
      summaryStatus: json['summary_status'] as String,
    );

Map<String, dynamic> _$SummaryStatusDtoToJson(_SummaryStatusDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'summary_status': instance.summaryStatus,
    };

_TranslationRequestDto _$TranslationRequestDtoFromJson(
  Map<String, dynamic> json,
) => _TranslationRequestDto(
  sourceLang: json['source_lang'] as String,
  targetLang: json['target_lang'] as String,
);

Map<String, dynamic> _$TranslationRequestDtoToJson(
  _TranslationRequestDto instance,
) => <String, dynamic>{
  'source_lang': instance.sourceLang,
  'target_lang': instance.targetLang,
};

_TranslationStatusDto _$TranslationStatusDtoFromJson(
  Map<String, dynamic> json,
) => _TranslationStatusDto(
  id: json['id'] as String,
  translationStatus: json['translation_status'] as String,
  sourceLang: json['source_lang'] as String?,
  targetLang: json['target_lang'] as String?,
);

Map<String, dynamic> _$TranslationStatusDtoToJson(
  _TranslationStatusDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'translation_status': instance.translationStatus,
  'source_lang': instance.sourceLang,
  'target_lang': instance.targetLang,
};

_CitationDto _$CitationDtoFromJson(Map<String, dynamic> json) => _CitationDto(
  chunkId: json['chunk_id'] as String?,
  index: (json['index'] as num?)?.toInt(),
  snippet: json['snippet'] as String?,
  page: (json['page'] as num?)?.toInt(),
  label: json['label'] as String?,
);

Map<String, dynamic> _$CitationDtoToJson(_CitationDto instance) =>
    <String, dynamic>{
      'chunk_id': instance.chunkId,
      'index': instance.index,
      'snippet': instance.snippet,
      'page': instance.page,
      'label': instance.label,
    };

_ChatDto _$ChatDtoFromJson(Map<String, dynamic> json) => _ChatDto(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  documentId: json['document_id'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ChatDtoToJson(_ChatDto instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'document_id': instance.documentId,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

_ChatMessageDto _$ChatMessageDtoFromJson(Map<String, dynamic> json) =>
    _ChatMessageDto(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      citations: (json['citations'] as List<dynamic>?)
          ?.map((e) => CitationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ChatMessageDtoToJson(_ChatMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_id': instance.chatId,
      'role': instance.role,
      'content': instance.content,
      'citations': instance.citations,
      'created_at': instance.createdAt?.toIso8601String(),
    };

_ChatMessageListDto _$ChatMessageListDtoFromJson(Map<String, dynamic> json) =>
    _ChatMessageListDto(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ChatMessageDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ChatMessageListDtoToJson(_ChatMessageListDto instance) =>
    <String, dynamic>{'items': instance.items};

_ChatMessageCreateDto _$ChatMessageCreateDtoFromJson(
  Map<String, dynamic> json,
) => _ChatMessageCreateDto(content: json['content'] as String);

Map<String, dynamic> _$ChatMessageCreateDtoToJson(
  _ChatMessageCreateDto instance,
) => <String, dynamic>{'content': instance.content};

_ExportRequestDto _$ExportRequestDtoFromJson(Map<String, dynamic> json) =>
    _ExportRequestDto(
      includeSummary: json['include_summary'] as bool? ?? false,
      includeTranslation: json['include_translation'] as bool? ?? false,
      includeChat: json['include_chat'] as bool? ?? false,
    );

Map<String, dynamic> _$ExportRequestDtoToJson(_ExportRequestDto instance) =>
    <String, dynamic>{
      'include_summary': instance.includeSummary,
      'include_translation': instance.includeTranslation,
      'include_chat': instance.includeChat,
    };

_ExportStatusDto _$ExportStatusDtoFromJson(Map<String, dynamic> json) =>
    _ExportStatusDto(
      id: json['id'] as String,
      documentId: json['document_id'] as String,
      includeSummary: json['include_summary'] as bool? ?? false,
      includeTranslation: json['include_translation'] as bool? ?? false,
      includeChat: json['include_chat'] as bool? ?? false,
      exportStatus: json['export_status'] as String,
      storageKey: json['storage_key'] as String?,
      signedUrl: json['signed_url'] as String?,
      errorMessage: json['error_message'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ExportStatusDtoToJson(_ExportStatusDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'document_id': instance.documentId,
      'include_summary': instance.includeSummary,
      'include_translation': instance.includeTranslation,
      'include_chat': instance.includeChat,
      'export_status': instance.exportStatus,
      'storage_key': instance.storageKey,
      'signed_url': instance.signedUrl,
      'error_message': instance.errorMessage,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_NotificationDto _$NotificationDtoFromJson(Map<String, dynamic> json) =>
    _NotificationDto(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      payload:
          json['payload'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$NotificationDtoToJson(_NotificationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'payload': instance.payload,
      'read_at': instance.readAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };

_NotificationListDto _$NotificationListDtoFromJson(Map<String, dynamic> json) =>
    _NotificationListDto(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => NotificationDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <NotificationDto>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$NotificationListDtoToJson(
  _NotificationListDto instance,
) => <String, dynamic>{'items': instance.items, 'total': instance.total};
