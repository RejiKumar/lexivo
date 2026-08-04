import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/notifications/domain/entities/app_notification.dart';
import 'package:lexivo/features/notifications/domain/repositories/notifications_repository.dart';

class FakeNotificationsRepository implements NotificationsRepository {
  FakeNotificationsRepository({List<AppNotification>? initial})
      : items = List<AppNotification>.from(initial ?? const []);

  final List<AppNotification> items;
  Failure? nextListFailure;
  Failure? nextMarkReadFailure;
  var listCalls = 0;
  var markReadCalls = 0;
  String? lastMarkReadId;

  @override
  Future<Result<List<AppNotification>>> listNotifications({
    bool unreadOnly = false,
  }) async {
    listCalls++;
    if (nextListFailure != null) {
      final f = nextListFailure!;
      nextListFailure = null;
      return Result.failure(f);
    }
    final filtered = unreadOnly
        ? items.where((n) => n.isUnread).toList(growable: false)
        : List<AppNotification>.from(items);
    return Result.success(filtered);
  }

  @override
  Future<Result<AppNotification>> markRead(String id) async {
    markReadCalls++;
    lastMarkReadId = id;
    if (nextMarkReadFailure != null) {
      final f = nextMarkReadFailure!;
      nextMarkReadFailure = null;
      return Result.failure(f);
    }
    final index = items.indexWhere((n) => n.id == id);
    if (index < 0) {
      return Result.failure(
        const NetworkFailure(message: 'Notification not found'),
      );
    }
    final updated = items[index].copyWith(readAt: DateTime.utc(2026, 8, 4, 12));
    items[index] = updated;
    return Result.success(updated);
  }
}

AppNotification sampleNotification({
  String id = 'notif-1',
  String title = 'OCR complete',
  String body = 'Your document text is ready.',
  bool unread = true,
  String? documentId = 'doc-1',
}) {
  return AppNotification(
    id: id,
    type: 'processing_complete',
    title: title,
    body: body,
    payload: {
      if (documentId != null) 'document_id': documentId,
      'job_type': 'ocr',
    },
    readAt: unread ? null : DateTime.utc(2026, 8, 4, 11),
    createdAt: DateTime.utc(2026, 8, 4, 10),
  );
}
