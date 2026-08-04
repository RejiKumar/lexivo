import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';
import 'package:lexivo/features/rag_chat/domain/repositories/rag_chat_repository.dart';

class FakeRagChatRepository implements RagChatRepository {
  FakeRagChatRepository({
    List<ChatMessage>? initialMessages,
    this.chat = const Chat(
      id: 'chat-1',
      userId: 'user-1',
      documentId: 'doc-1',
    ),
  }) : messages = List<ChatMessage>.from(initialMessages ?? const []);

  Chat chat;
  final List<ChatMessage> messages;
  Failure? nextEnsureFailure;
  Failure? nextListFailure;
  Failure? nextSendFailure;
  ChatMessage? nextAssistant;
  Duration? sendDelay;
  var ensureCalls = 0;
  var listCalls = 0;
  var sendCalls = 0;
  final List<String> sentContents = [];

  @override
  Future<Result<Chat>> ensureChat(String documentId) async {
    ensureCalls++;
    if (nextEnsureFailure != null) {
      final f = nextEnsureFailure!;
      nextEnsureFailure = null;
      return Result.failure(f);
    }
    chat = chat.copyWith(documentId: documentId);
    return Result.success(chat);
  }

  @override
  Future<Result<List<ChatMessage>>> listMessages(String documentId) async {
    listCalls++;
    if (nextListFailure != null) {
      final f = nextListFailure!;
      nextListFailure = null;
      return Result.failure(f);
    }
    return Result.success(List<ChatMessage>.from(messages));
  }

  @override
  Future<Result<ChatMessage>> sendMessage(
    String documentId,
    String content,
  ) async {
    sendCalls++;
    sentContents.add(content);
    if (sendDelay != null) {
      await Future<void>.delayed(sendDelay!);
    }
    if (nextSendFailure != null) {
      final f = nextSendFailure!;
      nextSendFailure = null;
      return Result.failure(f);
    }
    final user = ChatMessage(
      id: 'msg-u-${messages.length + 1}',
      chatId: chat.id,
      role: ChatMessageRole.user,
      content: content,
    );
    messages.add(user);
    final assistant = nextAssistant ??
        ChatMessage(
          id: 'msg-a-${messages.length + 1}',
          chatId: chat.id,
          role: ChatMessageRole.assistant,
          content: 'Answer for: $content',
          citations: const [
            Citation(index: 0, snippet: 'source snippet', label: '§1'),
          ],
        );
    nextAssistant = null;
    messages.add(assistant);
    return Result.success(assistant);
  }
}

ChatMessage sampleUserMessage({
  String id = 'msg-u1',
  String content = 'When is rent due?',
}) {
  return ChatMessage(
    id: id,
    chatId: 'chat-1',
    role: ChatMessageRole.user,
    content: content,
  );
}

ChatMessage sampleAssistantMessage({
  String id = 'msg-a1',
  String content = 'Rent is due on the first of each month.',
  List<Citation> citations = const [
    Citation(
      chunkId: 'chunk-1',
      index: 0,
      snippet: 'rent is due on the first',
      label: '§1',
    ),
  ],
}) {
  return ChatMessage(
    id: id,
    chatId: 'chat-1',
    role: ChatMessageRole.assistant,
    content: content,
    citations: citations,
  );
}
