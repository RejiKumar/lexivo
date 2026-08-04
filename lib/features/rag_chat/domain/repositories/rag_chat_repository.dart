import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';

/// Port for document chat — ensure / list / send (sync ask).
abstract class RagChatRepository {
  Future<Result<Chat>> ensureChat(String documentId);

  Future<Result<List<ChatMessage>>> listMessages(String documentId);

  Future<Result<ChatMessage>> sendMessage(String documentId, String content);
}
