import 'package:lexivo/core/network/api_models.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';

Citation citationFromDto(CitationDto dto) => Citation(
      chunkId: dto.chunkId,
      index: dto.index,
      snippet: dto.snippet,
      page: dto.page,
      label: dto.label,
    );

Chat chatFromDto(ChatDto dto) => Chat(
      id: dto.id,
      userId: dto.userId,
      documentId: dto.documentId,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );

ChatMessageRole chatMessageRoleFromApi(String role) {
  switch (role) {
    case 'user':
      return ChatMessageRole.user;
    case 'assistant':
      return ChatMessageRole.assistant;
    default:
      return ChatMessageRole.assistant;
  }
}

ChatMessage chatMessageFromDto(ChatMessageDto dto) => ChatMessage(
      id: dto.id,
      chatId: dto.chatId,
      role: chatMessageRoleFromApi(dto.role),
      content: dto.content,
      citations: (dto.citations ?? const [])
          .map(citationFromDto)
          .toList(growable: false),
      createdAt: dto.createdAt,
    );
