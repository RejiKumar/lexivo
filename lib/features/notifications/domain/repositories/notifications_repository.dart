import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<Result<List<AppNotification>>> listNotifications({
    bool unreadOnly = false,
  });

  Future<Result<AppNotification>> markRead(String id);
}
