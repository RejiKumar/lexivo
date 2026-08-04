import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/components/chat_bubble.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/rag_chat/rag_chat.dart';

import '../../helpers/fake_rag_chat_repository.dart';

void main() {
  testWidgets('empty → send → assistant + citation chips', (tester) async {
    final repo = FakeRagChatRepository();
    final router = GoRouter(
      initialLocation: RouteGuards.documentChat('doc-1'),
      routes: [
        GoRoute(
          path: '/documents/:documentId/chat',
          builder: (context, state) => RagChatScreen(
            documentId: state.pathParameters['documentId']!,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ragChatRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LexivoEmptyState), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'When is rent due?');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(find.byType(LexivoChatBubble), findsWidgets);
    expect(find.byType(Chip), findsWidgets);
    expect(repo.sendCalls, 1);
  });

  testWidgets('resume shows prior history without re-ask', (tester) async {
    final repo = FakeRagChatRepository(
      initialMessages: [sampleUserMessage(), sampleAssistantMessage()],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ragChatRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RagChatScreen(documentId: 'doc-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('When is rent due?'), findsOneWidget);
    expect(find.textContaining('Rent is due'), findsOneWidget);
    expect(repo.sendCalls, 0);
  });

  testWidgets('not-ready → error banner, no grounded answer', (tester) async {
    final repo = FakeRagChatRepository()
      ..nextSendFailure = const ValidationFailure(
        message: 'Document OCR is not ready',
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ragChatRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RagChatScreen(documentId: 'doc-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Q?');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(find.byType(LexivoErrorBanner), findsOneWidget);
    expect(find.textContaining('not ready'), findsWidgets);
    expect(find.textContaining('Answer for'), findsNothing);
  });

  testWidgets('ungrounded cannot-answer renders; retry after failure',
      (tester) async {
    final repo = FakeRagChatRepository();
    repo.nextAssistant = sampleAssistantMessage(
      content: 'I cannot answer from the document.',
      citations: const [],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ragChatRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RagChatScreen(documentId: 'doc-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Secret?');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.textContaining('cannot answer'), findsOneWidget);

    repo.nextSendFailure = const UnexpectedFailure(message: 'network down');
    await tester.enterText(find.byType(TextField), 'Again?');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.byType(LexivoErrorBanner), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(repo.sendCalls, greaterThanOrEqualTo(2));
  });
}
