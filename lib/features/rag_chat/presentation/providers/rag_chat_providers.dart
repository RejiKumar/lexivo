import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/rag_chat/data/datasources/rag_chat_remote_datasource.dart';
import 'package:lexivo/features/rag_chat/data/repositories/rag_chat_repository_impl.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';
import 'package:lexivo/features/rag_chat/domain/repositories/rag_chat_repository.dart';
import 'package:lexivo/features/rag_chat/domain/usecases/rag_chat_usecases.dart';
import 'package:lexivo/features/rag_chat/presentation/screens/rag_chat_screen.dart';

final ragChatRemoteDatasourceProvider = Provider<RagChatRemoteDatasource>((ref) {
  return RagChatRemoteDatasource(ref.watch(apiClientProvider));
});

final ragChatRepositoryProvider = Provider<RagChatRepository>((ref) {
  return RagChatRepositoryImpl(ref.watch(ragChatRemoteDatasourceProvider));
});

final ensureChatUseCaseProvider = Provider((ref) {
  return EnsureChat(ref.watch(ragChatRepositoryProvider));
});

final loadChatMessagesUseCaseProvider = Provider((ref) {
  return LoadChatMessages(ref.watch(ragChatRepositoryProvider));
});

final sendChatMessageUseCaseProvider = Provider((ref) {
  return SendChatMessage(ref.watch(ragChatRepositoryProvider));
});

/// Thread state for a document chat (messages + optional in-flight send).
@immutable
class RagChatState {
  const RagChatState({
    required this.messages,
    this.isSending = false,
    this.sendError,
    this.pendingUserContent,
  });

  final List<ChatMessage> messages;
  final bool isSending;
  final Failure? sendError;
  final String? pendingUserContent;

  RagChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    Failure? sendError,
    bool clearSendError = false,
    String? pendingUserContent,
    bool clearPending = false,
  }) {
    return RagChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      sendError: clearSendError ? null : (sendError ?? this.sendError),
      pendingUserContent:
          clearPending ? null : (pendingUserContent ?? this.pendingUserContent),
    );
  }
}

final ragChatProvider =
    AsyncNotifierProvider.family<RagChatNotifier, RagChatState, String>(
  RagChatNotifier.new,
);

class RagChatNotifier extends FamilyAsyncNotifier<RagChatState, String> {
  String? _lastFailedContent;

  @override
  Future<RagChatState> build(String documentId) async {
    await ref.read(ensureChatUseCaseProvider)(documentId);
    final result = await ref.read(loadChatMessagesUseCaseProvider)(documentId);
    return result.when(
      success: (messages) => RagChatState(messages: messages),
      onFailure: (f) => throw f,
    );
  }

  Future<void> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      final current = state.valueOrNull ?? const RagChatState(messages: []);
      state = AsyncData(
        current.copyWith(
          sendError: const ValidationFailure(
            message: 'Message content must not be empty',
          ),
        ),
      );
      return;
    }

    final previous = state.valueOrNull ?? const RagChatState(messages: []);
    _lastFailedContent = trimmed;
    state = AsyncData(
      previous.copyWith(
        isSending: true,
        pendingUserContent: trimmed,
        clearSendError: true,
      ),
    );

    final result =
        await ref.read(sendChatMessageUseCaseProvider)(arg, trimmed);

    await result.when(
      success: (assistant) async {
        _lastFailedContent = null;
        final listResult =
            await ref.read(loadChatMessagesUseCaseProvider)(arg);
        listResult.when(
          success: (messages) {
            state = AsyncData(RagChatState(messages: messages));
          },
          onFailure: (_) {
            final optimisticUser = ChatMessage(
              id: 'local-user-${DateTime.now().millisecondsSinceEpoch}',
              chatId: assistant.chatId,
              role: ChatMessageRole.user,
              content: trimmed,
            );
            state = AsyncData(
              RagChatState(messages: [...previous.messages, optimisticUser, assistant]),
            );
          },
        );
      },
      onFailure: (failure) async {
        state = AsyncData(
          previous.copyWith(
            isSending: false,
            clearPending: true,
            sendError: failure,
          ),
        );
      },
    );
  }

  Future<void> retrySend() async {
    final content = _lastFailedContent;
    if (content == null) return;
    await sendMessage(content);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

final ragChatScreenBuildersBridgeProvider =
    Provider<RagChatScreenBuilders>((ref) {
  return (
    result: (context, documentId) => RagChatScreen(documentId: documentId),
  );
});

/// Wire rag chat routes into core GoRouter.
List<Override> ragChatCoreOverrides() => [
      ragChatScreenBuildersProvider.overrideWith(
        (ref) => ref.watch(ragChatScreenBuildersBridgeProvider),
      ),
    ];
