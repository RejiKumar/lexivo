import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/rag_chat/data/models/chat_mappers.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';

/// Remote rag chat — [ApiClient] only (no Dio imports).
class RagChatRemoteDatasource {
  RagChatRemoteDatasource(this._api);

  final ApiClient _api;

  Future<Result<Chat>> ensureChat(String documentId) async {
    final result = await _api.createChat(documentId);
    return result.map(chatFromDto);
  }

  Future<Result<List<ChatMessage>>> listMessages(String documentId) async {
    final result = await _api.listChatMessages(documentId);
    return result.map(
      (list) => list.items.map(chatMessageFromDto).toList(growable: false),
    );
  }

  Future<Result<ChatMessage>> sendMessage(
    String documentId,
    String content,
  ) async {
    final result = await _api.postChatMessage(documentId, content: content);
    return result.map(chatMessageFromDto);
  }
}
