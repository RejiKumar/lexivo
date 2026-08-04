import 'package:lexivo/core/network/api_models.dart';
import 'package:lexivo/features/notifications/domain/entities/app_notification.dart';

AppNotification appNotificationFromDto(NotificationDto dto) {
  return AppNotification(
    id: dto.id,
    type: dto.type,
    title: dto.title,
    body: dto.body,
    payload: Map<String, dynamic>.from(dto.payload),
    readAt: dto.readAt,
    createdAt: dto.createdAt,
  );
}
