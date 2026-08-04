import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_models.dart';
import 'dio_provider.dart';
import 'error_mapper.dart';
import '../utils/result.dart';

/// Typed Lexivo API client for `/api/v1` paths.
///
/// TODO(openapi-codegen): replace body with thin wrap of generated dart-dio
/// client from `openapi/lexivo.openapi.json`. Do not hand-edit generated files.
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

  /// Multipart create + server-side StorageProvider upload + enqueue.
  ///
  /// TODO(openapi-codegen): swap to generated multipart client when regen lands.
  Future<Result<DocumentDto>> createDocument({
    required List<int> bytes,
    required String filename,
    String? title,
  }) async {
    try {
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        if (title != null) 'title': title,
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
