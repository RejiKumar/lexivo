import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/rag_chat/presentation/providers/rag_chat_providers.dart';

import '../../../helpers/fake_rag_chat_repository.dart';
import '../../../helpers/rag_chat_test_harness.dart';

void main() {
  test('open chat → empty messages AsyncData', () async {
    final repo = FakeRagChatRepository();
    final container = createRagChatContainer(repository: repo);
    addTearDown(container.dispose);

    final state = await container.read(ragChatProvider('doc-1').future);
    expect(state.messages, isEmpty);
    expect(repo.ensureCalls, 1);
    expect(repo.listCalls, 1);
  });

  test('open chat → prior messages loaded', () async {
    final repo = FakeRagChatRepository(
      initialMessages: [sampleUserMessage(), sampleAssistantMessage()],
    );
    final container = createRagChatContainer(repository: repo);
    addTearDown(container.dispose);

    final state = await container.read(ragChatProvider('doc-1').future);
    expect(state.messages.length, 2);
  });

  test('send → streaming then assistant + citations', () async {
    final repo = FakeRagChatRepository();
    final container = createRagChatContainer(repository: repo);
    addTearDown(container.dispose);
    await container.read(ragChatProvider('doc-1').future);

    final future =
        container.read(ragChatProvider('doc-1').notifier).sendMessage('Q?');
    final mid = container.read(ragChatProvider('doc-1')).valueOrNull;
    expect(mid?.isSending, isTrue);
    expect(mid?.pendingUserContent, 'Q?');

    await future;
    final done = container.read(ragChatProvider('doc-1')).valueOrNull;
    expect(done?.isSending, isFalse);
    expect(done?.messages.length, 2);
    expect(done?.messages.last.citations, isNotEmpty);
  });

  test('409 not-ready → sendError without fabricating assistant', () async {
    final repo = FakeRagChatRepository();
    repo.nextSendFailure = const ValidationFailure(
      message: 'Document OCR is not ready',
    );
    final container = createRagChatContainer(repository: repo);
    addTearDown(container.dispose);
    await container.read(ragChatProvider('doc-1').future);

    await container
        .read(ragChatProvider('doc-1').notifier)
        .sendMessage('Q?');
    final state = container.read(ragChatProvider('doc-1')).valueOrNull;
    expect(state?.sendError?.message, contains('not ready'));
    expect(state?.messages, isEmpty);
  });

  test('422 empty → validation sendError', () async {
    final repo = FakeRagChatRepository();
    final container = createRagChatContainer(repository: repo);
    addTearDown(container.dispose);
    await container.read(ragChatProvider('doc-1').future);

    await container.read(ragChatProvider('doc-1').notifier).sendMessage('  ');
    final state = container.read(ragChatProvider('doc-1')).valueOrNull;
    expect(state?.sendError, isA<ValidationFailure>());
    expect(repo.sendCalls, 0);
  });

  test('ungrounded assistant shown normally', () async {
    final repo = FakeRagChatRepository();
    repo.nextAssistant = sampleAssistantMessage(
      content: 'I cannot answer from the document.',
      citations: const [],
    );
    final container = createRagChatContainer(repository: repo);
    addTearDown(container.dispose);
    await container.read(ragChatProvider('doc-1').future);

    await container
        .read(ragChatProvider('doc-1').notifier)
        .sendMessage('Unknown?');
    final state = container.read(ragChatProvider('doc-1')).valueOrNull;
    expect(state?.messages.last.content, contains('cannot answer'));
    expect(state?.messages.last.citations, isEmpty);
  });
}
