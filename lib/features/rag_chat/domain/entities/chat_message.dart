import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

enum ChatMessageRole { user, assistant }

@freezed
abstract class Citation with _$Citation {
  const factory Citation({
    String? chunkId,
    int? index,
    String? snippet,
    int? page,
    String? label,
  }) = _Citation;
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String chatId,
    required ChatMessageRole role,
    required String content,
    @Default([]) List<Citation> citations,
    DateTime? createdAt,
  }) = _ChatMessage;
}

@freezed
abstract class Chat with _$Chat {
  const factory Chat({
    required String id,
    required String userId,
    required String documentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Chat;
}
