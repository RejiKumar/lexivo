import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/rag_chat/data/datasources/rag_chat_remote_datasource.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';
import 'package:lexivo/features/rag_chat/domain/repositories/rag_chat_repository.dart';

class RagChatRepositoryImpl implements RagChatRepository {
  RagChatRepositoryImpl(this._remote);

  final RagChatRemoteDatasource _remote;

  @override
  Future<Result<Chat>> ensureChat(String documentId) =>
      _remote.ensureChat(documentId);

  @override
  Future<Result<List<ChatMessage>>> listMessages(String documentId) =>
      _remote.listMessages(documentId);

  @override
  Future<Result<ChatMessage>> sendMessage(String documentId, String content) =>
      _remote.sendMessage(documentId, content);
}
