import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';
import 'package:lexivo/features/rag_chat/domain/repositories/rag_chat_repository.dart';

class EnsureChat {
  const EnsureChat(this._repo);

  final RagChatRepository _repo;

  Future<Result<Chat>> call(String documentId) => _repo.ensureChat(documentId);
}

class LoadChatMessages {
  const LoadChatMessages(this._repo);

  final RagChatRepository _repo;

  Future<Result<List<ChatMessage>>> call(String documentId) =>
      _repo.listMessages(documentId);
}

class SendChatMessage {
  const SendChatMessage(this._repo);

  final RagChatRepository _repo;

  Future<Result<ChatMessage>> call(String documentId, String content) {
    if (content.trim().isEmpty) {
      return Future.value(
        Result.failure(
          const ValidationFailure(message: 'Message content must not be empty'),
        ),
      );
    }
    return _repo.sendMessage(documentId, content.trim());
  }
}
