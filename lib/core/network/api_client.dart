import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_models.dart';
import 'dio_provider.dart';
import 'error_mapper.dart';
import '../utils/result.dart';

/// Typed Lexivo API client for `/api/v1` paths.
///
/// When OpenAPI dart-dio codegen lands, replace this body with a thin wrap of
/// the generated client from `openapi/lexivo.openapi.json` (do not hand-edit
/// generated files).
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  static const _prefix = '/api/v1';

  Future<Result<AuthSessionDto>> getAuthMe() => _get(
        '$_prefix/auth/me',
        (json) => AuthSessionDto.fromJson(json),
      );

  Future<Result<UserProfileDto>> getUserMe() => _get(
        '$_prefix/users/me',
        (json) => UserProfileDto.fromJson(json),
      );

  Future<Result<UserProfileDto>> patchUserMe(UserProfileUpdateDto update) =>
      _patch(
        '$_prefix/users/me',
        update.toJson(),
        (json) => UserProfileDto.fromJson(json),
      );

  Future<Result<DocumentListDto>> listDocuments() => _get(
        '$_prefix/documents',
        (json) => DocumentListDto.fromJson(json),
      );

  Future<Result<DocumentDto>> getDocument(String id) => _get(
        '$_prefix/documents/$id',
        (json) => DocumentDto.fromJson(json),
      );

  Future<Result<DocumentStatusDto>> getDocumentStatus(String id) => _get(
        '$_prefix/documents/$id/status',
        (json) => DocumentStatusDto.fromJson(json),
      );

  /// Enqueue summarization (Master → Summary Agent). 202 when accepted.
  Future<Result<DocumentDto>> requestSummary(String id) => _post(
        '$_prefix/documents/$id/summary',
        (json) => DocumentDto.fromJson(json),
      );

  Future<Result<SummaryStatusDto>> getSummaryStatus(String id) => _get(
        '$_prefix/documents/$id/summary/status',
        (json) => SummaryStatusDto.fromJson(json),
      );

  /// Enqueue translation (Master → Translation Agent). 202 when accepted.
  Future<Result<DocumentDto>> requestTranslation(
    String id, {
    required String sourceLang,
    required String targetLang,
  }) =>
      _post(
        '$_prefix/documents/$id/translation',
        (json) => DocumentDto.fromJson(json),
        data: TranslationRequestDto(
          sourceLang: sourceLang,
          targetLang: targetLang,
        ).toJson(),
      );

  Future<Result<TranslationStatusDto>> getTranslationStatus(String id) => _get(
        '$_prefix/documents/$id/translation/status',
        (json) => TranslationStatusDto.fromJson(json),
      );

  /// Get-or-create chat thread for a document (idempotent).
  Future<Result<ChatDto>> createChat(String docId) => _post(
        '$_prefix/chats/$docId',
        (json) => ChatDto.fromJson(json),
      );

  /// Ordered messages for resume / sync.
  Future<Result<ChatMessageListDto>> listChatMessages(String docId) => _get(
        '$_prefix/chats/$docId/messages',
        (json) => ChatMessageListDto.fromJson(json),
      );

  /// Synchronous ask — Master `ask` / `rag_chat` (Search→Citation).
  ///
  /// 200 with assistant message + citations; **409** not-ready / not-ingested;
  /// **422** empty content.
  Future<Result<ChatMessageDto>> postChatMessage(
    String docId, {
    required String content,
  }) =>
      _post(
        '$_prefix/chats/$docId/messages',
        (json) => ChatMessageDto.fromJson(json),
        data: ChatMessageCreateDto(content: content).toJson(),
      );

  /// Enqueue PDF export (Master → Export Agent). 202 when accepted.
  ///
  /// **422** when no section toggles; **409** when a selected section is not ready.
  Future<Result<ExportStatusDto>> requestExport(
    String id, {
    bool includeSummary = false,
    bool includeTranslation = false,
    bool includeChat = false,
  }) =>
      _post(
        '$_prefix/documents/$id/export',
        (json) => ExportStatusDto.fromJson(json),
        data: ExportRequestDto(
          includeSummary: includeSummary,
          includeTranslation: includeTranslation,
          includeChat: includeChat,
        ).toJson(),
      );

  Future<Result<ExportStatusDto>> getExportStatus(String id) => _get(
        '$_prefix/documents/$id/export/status',
        (json) => ExportStatusDto.fromJson(json),
      );

  Future<Result<ExportStatusDto>> getExport(String exportId) => _get(
        '$_prefix/exports/$exportId',
        (json) => ExportStatusDto.fromJson(json),
      );

  /// In-app notification inbox (newest-first). Optional unread filter.
  Future<Result<NotificationListDto>> listNotifications({
    bool unreadOnly = false,
  }) =>
      _get(
        unreadOnly
            ? '$_prefix/notifications?unread_only=true'
            : '$_prefix/notifications',
        (json) => NotificationListDto.fromJson(json),
      );

  /// Mark a notification as read (idempotent). 404 → mapped failure.
  Future<Result<NotificationDto>> markNotificationRead(String id) => _post(
        '$_prefix/notifications/$id/read',
        (json) => NotificationDto.fromJson(json),
      );

  /// Current subscription tier + usage buckets (always available).
  Future<Result<SubscriptionMeDto>> getSubscriptionMe() => _get(
        '$_prefix/subscriptions/me',
        (json) => SubscriptionMeDto.fromJson(json),
      );

  /// Stub upgrade → paid when paywall flag is on; 403 when flag off.
  Future<Result<SubscriptionUpgradeDto>> upgradeSubscription() => _post(
        '$_prefix/subscriptions/upgrade',
        (json) => SubscriptionUpgradeDto.fromJson(json),
      );

  /// Public soft/force upgrade policy (no auth). See docs/app-versioning.md.
  Future<Result<AppVersionDto>> getAppVersion() => _get(
        '$_prefix/app/version',
        (json) => AppVersionDto.fromJson(json),
      );

  /// Multipart create + server-side StorageProvider upload + enqueue.
  ///
  /// Multipart path stays hand-written until generated multipart client exists.
  Future<Result<DocumentDto>> createDocument({
    required List<int> bytes,
    required String filename,
    String? title,
  }) async {
    try {
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        'title': ?title,
      });
      final response = await _dio.post<dynamic>(
        '$_prefix/documents',
        data: form,
      );
      return Result.success(DocumentDto.fromJson(_asMap(response.data)));
    } catch (e, st) {
      return Result.failure(ErrorMapper.map(e, st));
    }
  }

  Future<Result<T>> _get<T>(
    String path,
    T Function(Map<String, dynamic> json) parse,
  ) async {
    try {
      final response = await _dio.get<dynamic>(path);
      return Result.success(parse(_asMap(response.data)));
    } catch (e, st) {
      return Result.failure(ErrorMapper.map(e, st));
    }
  }

  Future<Result<T>> _post<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    Object? data,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data);
      return Result.success(parse(_asMap(response.data)));
    } catch (e, st) {
      return Result.failure(ErrorMapper.map(e, st));
    }
  }

  Future<Result<T>> _patch<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic> json) parse,
  ) async {
    try {
      final response = await _dio.patch<dynamic>(path, data: body);
      return Result.success(parse(_asMap(response.data)));
    } catch (e, st) {
      return Result.failure(ErrorMapper.map(e, st));
    }
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw UnexpectedFailure(message: 'Expected JSON object response');
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
