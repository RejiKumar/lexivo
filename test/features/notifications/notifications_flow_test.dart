import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/notifications/presentation/screens/notifications_screen.dart';

import '../../helpers/fake_notifications_repository.dart';
import '../../helpers/notifications_test_harness.dart';

void main() {
  testWidgets('flow: open inbox → processing-complete → mark read',
      (tester) async {
    final repo = FakeNotificationsRepository(
      initial: [
        sampleNotification(
          title: 'OCR complete',
          body: 'Your document text is ready.',
          unread: true,
          documentId: null,
        ),
      ],
    );
    await tester.pumpWidget(
      wrapNotificationsScreen(
        const NotificationsScreen(),
        repository: repo,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('OCR complete'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);

    await tester.tap(find.text('OCR complete'));
    await tester.pumpAndSettle();
    expect(find.text('New'), findsNothing);
    expect(repo.items.single.isUnread, isFalse);
  });

  testWidgets('flow: empty inbox → LexivoEmptyState', (tester) async {
    await tester.pumpWidget(
      wrapNotificationsScreen(
        const NotificationsScreen(),
        repository: FakeNotificationsRepository(initial: []),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LexivoEmptyState), findsOneWidget);
  });

  testWidgets('flow: list error → LexivoErrorBanner + retry recovers',
      (tester) async {
    final repo = FakeNotificationsRepository(
      initial: [sampleNotification()],
    );
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
    expect(find.text('OCR complete'), findsOneWidget);
  });
}
