import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/notifications/domain/entities/app_notification.dart';
import 'package:lexivo/features/notifications/domain/repositories/notifications_repository.dart';

class ListNotifications {
  const ListNotifications(this._repo);

  final NotificationsRepository _repo;

  Future<Result<List<AppNotification>>> call({bool unreadOnly = false}) =>
      _repo.listNotifications(unreadOnly: unreadOnly);
}

class MarkNotificationRead {
  const MarkNotificationRead(this._repo);

  final NotificationsRepository _repo;

  Future<Result<AppNotification>> call(String id) => _repo.markRead(id);
}
