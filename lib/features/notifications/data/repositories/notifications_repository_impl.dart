import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:lexivo/features/notifications/domain/entities/app_notification.dart';
import 'package:lexivo/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDatasource _remote;

  @override
  Future<Result<List<AppNotification>>> listNotifications({
    bool unreadOnly = false,
  }) =>
      _remote.listNotifications(unreadOnly: unreadOnly);

  @override
  Future<Result<AppNotification>> markRead(String id) => _remote.markRead(id);
}
