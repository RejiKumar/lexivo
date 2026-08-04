import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/chat_bubble.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/design_system/components/input.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/rag_chat/presentation/providers/rag_chat_providers.dart';
import 'package:lexivo/features/rag_chat/rag_chat.dart';

import '../../../helpers/fake_rag_chat_repository.dart';
import '../../../helpers/rag_chat_test_harness.dart';

void main() {
  testWidgets('empty → LexivoEmptyState', (tester) async {
    final repo = FakeRagChatRepository();
    await tester.pumpWidget(
      wrapRagChatScreen(
        const RagChatScreen(documentId: 'doc-1'),
        overrides: [
          ragChatRepositoryProvider.overrideWithValue(repo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LexivoEmptyState), findsOneWidget);
    expect(find.byType(LexivoTextField), findsOneWidget);
  });

  testWidgets('messages → LexivoChatBubble user/assistant + chips',
      (tester) async {
    final repo = FakeRagChatRepository(
      initialMessages: [sampleUserMessage(), sampleAssistantMessage()],
    );
    await tester.pumpWidget(
      wrapRagChatScreen(
        const RagChatScreen(documentId: 'doc-1'),
        overrides: [
          ragChatRepositoryProvider.overrideWithValue(repo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LexivoChatBubble), findsNWidgets(2));
    expect(find.textContaining('Rent is due'), findsOneWidget);
    expect(find.byType(Chip), findsWidgets);
  });

  testWidgets('failed load → LexivoErrorBanner', (tester) async {
    final repo = FakeRagChatRepository()
      ..nextListFailure = const UnexpectedFailure(message: 'load failed');
    await tester.pumpWidget(
      wrapRagChatScreen(
        const RagChatScreen(documentId: 'doc-1'),
        overrides: [
          ragChatRepositoryProvider.overrideWithValue(repo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LexivoErrorBanner), findsOneWidget);
  });

  testWidgets('sending → assistantStreaming bubble', (tester) async {
    final repo = FakeRagChatRepository()
      ..sendDelay = const Duration(milliseconds: 200);
    await tester.pumpWidget(
      wrapRagChatScreen(
        const RagChatScreen(documentId: 'doc-1'),
        overrides: [
          ragChatRepositoryProvider.overrideWithValue(repo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hello?');
    await tester.tap(find.text('Send'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is LexivoChatBubble &&
            w.variant == LexivoChatBubbleVariant.assistantStreaming,
      ),
      findsOneWidget,
    );

    await tester.pumpAndSettle();
    expect(find.textContaining('Answer for'), findsOneWidget);
  });
}
