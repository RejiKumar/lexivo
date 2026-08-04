import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/notifications/data/models/notification_mappers.dart';
import 'package:lexivo/features/notifications/domain/entities/app_notification.dart';

/// Remote notifications — [ApiClient] only (no Dio imports).
class NotificationsRemoteDatasource {
  NotificationsRemoteDatasource(this._api);

  final ApiClient _api;

  Future<Result<List<AppNotification>>> listNotifications({
    bool unreadOnly = false,
  }) async {
    final result = await _api.listNotifications(unreadOnly: unreadOnly);
    return result.map(
      (dto) => dto.items.map(appNotificationFromDto).toList(growable: false),
    );
  }

  Future<Result<AppNotification>> markRead(String id) async {
    final result = await _api.markNotificationRead(id);
    return result.map(appNotificationFromDto);
  }
}
