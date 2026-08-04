import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/features/notifications/notifications.dart';

void main() {
  test('barrel exports inbox screen + providers (not data-layer types)', () {
    expect(NotificationsScreen, isNotNull);
    expect(notificationsInboxProvider, isNotNull);
    expect(notificationsCoreOverrides, isNotNull);
    expect(AppNotification, isNotNull);
  });
}
