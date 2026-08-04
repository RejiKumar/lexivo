import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/notifications/domain/usecases/notifications_usecases.dart';

import '../../../helpers/fake_notifications_repository.dart';

void main() {
  test('ListNotifications success and empty', () async {
    final empty = FakeNotificationsRepository(initial: []);
    final listEmpty = await ListNotifications(empty)();
    expect(listEmpty.isSuccess, isTrue);
    expect(listEmpty.valueOrNull, isEmpty);

    final filled = FakeNotificationsRepository(
      initial: [sampleNotification()],
    );
    final list = await ListNotifications(filled)();
    expect(list.valueOrNull?.single.id, 'notif-1');
  });

  test('ListNotifications failure', () async {
    final repo = FakeNotificationsRepository();
    repo.nextListFailure = const NetworkFailure(message: 'offline');
    final result = await ListNotifications(repo)();
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message, 'offline');
  });

  test('MarkNotificationRead unread → read', () async {
    final repo = FakeNotificationsRepository(
      initial: [sampleNotification(unread: true)],
    );
    final result = await MarkNotificationRead(repo)('notif-1');
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.isUnread, isFalse);
    expect(repo.items.single.isUnread, isFalse);
  });

  test('MarkNotificationRead failure', () async {
    final repo = FakeNotificationsRepository(
      initial: [sampleNotification()],
    );
    repo.nextMarkReadFailure = const NetworkFailure(message: 'not found');
    final result = await MarkNotificationRead(repo)('notif-1');
    expect(result.isFailure, isTrue);
  });
}
