import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/features/rag_chat/presentation/providers/rag_chat_providers.dart';
import 'package:lexivo/features/rag_chat/presentation/screens/_rag_chat_shared.dart';
import 'package:lexivo/features/rag_chat/presentation/screens/rag_chat_screen.dart';

import '../../../helpers/fake_rag_chat_repository.dart';
import '../../../helpers/rag_chat_test_harness.dart';

void main() {
  testWidgets('chat uses mobile single-pane layout at ≤599', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    expect(find.byKey(RagChatLayoutKeys.mobile), findsOneWidget);
    expect(find.byKey(RagChatLayoutKeys.conversationPane), findsOneWidget);
    expect(find.byKey(RagChatLayoutKeys.contextPane), findsNothing);
    expect(find.byKey(RagChatLayoutKeys.desktop), findsNothing);
  });

  testWidgets('chat uses desktop multi-pane layout at ≥1024', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    expect(find.byKey(RagChatLayoutKeys.desktop), findsOneWidget);
    expect(find.byKey(RagChatLayoutKeys.conversationPane), findsOneWidget);
    expect(find.byKey(RagChatLayoutKeys.contextPane), findsOneWidget);
    expect(find.byKey(RagChatLayoutKeys.mobile), findsNothing);
  });
}
