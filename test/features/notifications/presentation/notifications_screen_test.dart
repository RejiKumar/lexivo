import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/notifications/presentation/screens/notifications_screen.dart';

import '../../../helpers/fake_notifications_repository.dart';
import '../../../helpers/notifications_test_harness.dart';

void main() {
  testWidgets('empty → LexivoEmptyState', (tester) async {
    await tester.pumpWidget(
      wrapNotificationsScreen(
        const NotificationsScreen(),
        repository: FakeNotificationsRepository(initial: []),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LexivoEmptyState), findsOneWidget);
    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('failed → LexivoErrorBanner + retry recovers', (tester) async {
    final repo = FakeNotificationsRepository();
    repo.nextListFailure = const NetworkFailure(message: 'offline');
    await tester.pumpWidget(
      wrapNotificationsScreen(
        const NotificationsScreen(),
        repository: repo,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LexivoErrorBanner), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(LexivoEmptyState), findsOneWidget);
  });

  testWidgets('data list shows processing-complete + unread badge',
      (tester) async {
    await tester.pumpWidget(
      wrapNotificationsScreen(
        const NotificationsScreen(),
        repository: FakeNotificationsRepository(
          initial: [
            sampleNotification(
              title: 'OCR complete',
              body: 'Your document text is ready.',
              unread: true,
            ),
            sampleNotification(
              id: 'notif-2',
              title: 'PDF export ready',
              unread: false,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('OCR complete'), findsOneWidget);
    expect(find.text('Your document text is ready.'), findsWidgets);
    expect(find.text('PDF export ready'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('tap mark-read clears unread badge', (tester) async {
    final repo = FakeNotificationsRepository(
      initial: [
        sampleNotification(unread: true, documentId: null),
      ],
    );
    await tester.pumpWidget(
      wrapNotificationsScreen(
        const NotificationsScreen(),
        repository: repo,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('New'), findsOneWidget);

    await tester.tap(find.text('OCR complete'));
    await tester.pumpAndSettle();
    expect(find.text('New'), findsNothing);
    expect(repo.markReadCalls, 1);
  });
}
