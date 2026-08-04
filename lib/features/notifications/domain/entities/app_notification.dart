import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';

@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String type,
    required String title,
    required String body,
    @Default(<String, dynamic>{}) Map<String, dynamic> payload,
    DateTime? readAt,
    DateTime? createdAt,
  }) = _AppNotification;

  const AppNotification._();

  bool get isUnread => readAt == null;

  /// Prefer explicit document_id from payload when present.
  String? get documentId {
    final raw = payload['document_id'];
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return null;
  }
}
