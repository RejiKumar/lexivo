import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/notifications/notifications.dart';

import '../../../helpers/fake_notifications_repository.dart';
import '../../../helpers/notifications_test_harness.dart';

void main() {
  test('inbox loads list; empty is valid data', () async {
    final empty = createNotificationsContainer(
      repository: FakeNotificationsRepository(initial: []),
    );
    addTearDown(empty.dispose);
    final items = await empty.read(notificationsInboxProvider.future);
    expect(items, isEmpty);

    final filled = createNotificationsContainer(
      repository: FakeNotificationsRepository(
        initial: [sampleNotification()],
      ),
    );
    addTearDown(filled.dispose);
    final listed = await filled.read(notificationsInboxProvider.future);
    expect(listed.single.title, 'OCR complete');
  });

  test('load failure → error; retry reloads', () async {
    final repo = FakeNotificationsRepository();
    repo.nextListFailure = const NetworkFailure(message: 'boom');
    final container = createNotificationsContainer(repository: repo);
    addTearDown(container.dispose);

    await expectLater(
      container.read(notificationsInboxProvider.future),
      throwsA(isA<NetworkFailure>()),
    );

    await container.read(notificationsInboxProvider.notifier).refresh();
    final recovered = await container.read(notificationsInboxProvider.future);
    expect(recovered, isEmpty);
  });

  test('mark-read updates unread → read; 404 keeps inbox', () async {
    final repo = FakeNotificationsRepository(
      initial: [
        sampleNotification(id: 'notif-1', unread: true),
        sampleNotification(id: 'notif-2', title: 'Other', unread: true),
      ],
    );
    final container = createNotificationsContainer(repository: repo);
    addTearDown(container.dispose);

    await container.read(notificationsInboxProvider.future);
    await container.read(notificationsInboxProvider.notifier).markRead('notif-1');
    final after = await container.read(notificationsInboxProvider.future);
    expect(after.firstWhere((n) => n.id == 'notif-1').isUnread, isFalse);
    expect(after.firstWhere((n) => n.id == 'notif-2').isUnread, isTrue);

    repo.nextMarkReadFailure = const NetworkFailure(message: 'not found');
    await container.read(notificationsInboxProvider.notifier).markRead('notif-2');
    final kept = await container.read(notificationsInboxProvider.future);
    expect(kept.length, 2);
    expect(
      container.read(notificationsInboxProvider.notifier).markReadFailure,
      isA<NetworkFailure>(),
    );
    // Unread restored after failed mark-read (optimistic rollback).
    expect(kept.firstWhere((n) => n.id == 'notif-2').isUnread, isTrue);
  });
}
