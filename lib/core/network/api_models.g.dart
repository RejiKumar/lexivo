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
