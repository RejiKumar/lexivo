import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';
import 'package:lexivo/features/rag_chat/domain/usecases/rag_chat_usecases.dart';

import '../../../helpers/fake_rag_chat_repository.dart';

void main() {
  late FakeRagChatRepository repo;

  setUp(() {
    repo = FakeRagChatRepository();
  });

  test('EnsureChat success', () async {
    final result = await EnsureChat(repo)('doc-1');
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.documentId, 'doc-1');
    expect(repo.ensureCalls, 1);
  });

  test('LoadChatMessages empty / with history', () async {
    final empty = await LoadChatMessages(repo)('doc-1');
    expect(empty.valueOrNull, isEmpty);

    repo.messages.addAll([
      sampleUserMessage(),
      sampleAssistantMessage(),
    ]);
    final loaded = await LoadChatMessages(repo)('doc-1');
    expect(loaded.valueOrNull?.length, 2);
  });

  test('SendChatMessage success with citations', () async {
    final result = await SendChatMessage(repo)('doc-1', 'When is rent due?');
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.role, ChatMessageRole.assistant);
    expect(result.valueOrNull?.citations, isNotEmpty);
    expect(repo.sendCalls, 1);
  });

  test('SendChatMessage empty content → ValidationFailure', () async {
    final result = await SendChatMessage(repo)('doc-1', '   ');
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
    expect(repo.sendCalls, 0);
  });

  test('SendChatMessage not-ready maps Failure', () async {
    repo.nextSendFailure = const ValidationFailure(
      message: 'Document OCR is not ready',
    );
    final result = await SendChatMessage(repo)('doc-1', 'Q?');
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message, contains('not ready'));
  });

  test('ungrounded assistant still success Result', () async {
    repo.nextAssistant = sampleAssistantMessage(
      content: 'I cannot answer from the document.',
      citations: const [],
    );
    final result = await SendChatMessage(repo)('doc-1', 'Secret?');
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.content, contains('cannot answer'));
    expect(result.valueOrNull?.citations, isEmpty);
  });
}
