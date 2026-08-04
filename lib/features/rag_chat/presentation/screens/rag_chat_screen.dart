import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/chat_bubble.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/design_system/components/input.dart';
import 'package:lexivo/core/design_system/components/skeleton_loader.dart';
import 'package:lexivo/core/design_system/components/snackbar.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/widgets/async_value_view.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';
import 'package:lexivo/features/rag_chat/presentation/providers/rag_chat_providers.dart';

/// Ask-the-document chat — LexivoChatBubble + citationChips + AsyncValueView.
class RagChatScreen extends ConsumerStatefulWidget {
  const RagChatScreen({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<RagChatScreen> createState() => _RagChatScreenState();
}

class _RagChatScreenState extends ConsumerState<RagChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    _controller.clear();
    await ref.read(ragChatProvider(widget.documentId).notifier).sendMessage(text);
    final err = ref.read(ragChatProvider(widget.documentId)).valueOrNull?.sendError;
    if (err != null && mounted) {
      LexivoSnackbar.show(
        context,
        message: err.message,
        variant: LexivoSnackbarVariant.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncChat = ref.watch(ragChatProvider(widget.documentId));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LexivoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(
                      RouteGuards.documentTranslation(widget.documentId),
                    ),
                    tooltip: 'Back',
                  ),
                  Expanded(
                    child: Text('Ask the document', style: LexivoTypography.headline),
                  ),
                  LexivoButton(
                    label: 'Export',
                    variant: LexivoButtonVariant.secondary,
                    onPressed: () => context.go(
                      RouteGuards.documentExport(widget.documentId),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LexivoSpacing.md),
              Expanded(
                child: AsyncValueView<RagChatState>(
                  value: asyncChat,
                  onRetry: () => ref
                      .read(ragChatProvider(widget.documentId).notifier)
                      .refresh(),
                  loading: const Padding(
                    padding: EdgeInsets.all(LexivoSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LexivoSkeleton(
                          variant: LexivoSkeletonVariant.line,
                          width: 180,
                        ),
                        SizedBox(height: LexivoSpacing.sm),
                        LexivoSkeleton(
                          variant: LexivoSkeletonVariant.line,
                          width: double.infinity,
                        ),
                        SizedBox(height: LexivoSpacing.sm),
                        LexivoSkeleton(
                          variant: LexivoSkeletonVariant.line,
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                  builder: (context, chat) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (chat.sendError != null) ...[
                          LexivoErrorBanner(
                            message: chat.sendError!.message,
                            onRetry: () => ref
                                .read(
                                  ragChatProvider(widget.documentId).notifier,
                                )
                                .retrySend(),
                          ),
                          const SizedBox(height: LexivoSpacing.sm),
                        ],
                        Expanded(
                          child: chat.messages.isEmpty && !chat.isSending
                              ? const LexivoEmptyState(
                                  title: 'Ask anything',
                                  description:
                                      'Send a question about this document to get a grounded answer with citations.',
                                )
                              : ListView.builder(
                                  itemCount: chat.messages.length +
                                      (chat.isSending ? 2 : 0),
                                  itemBuilder: (context, index) {
                                    if (chat.isSending &&
                                        index >= chat.messages.length) {
                                      final offset =
                                          index - chat.messages.length;
                                      if (offset == 0) {
                                        return LexivoChatBubble(
                                          message:
                                              chat.pendingUserContent ?? '',
                                          variant: LexivoChatBubbleVariant.user,
                                        );
                                      }
                                      return const LexivoChatBubble(
                                        message: '',
                                        variant: LexivoChatBubbleVariant
                                            .assistantStreaming,
                                        animateStreaming: false,
                                      );
                                    }
                                    final message = chat.messages[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: LexivoSpacing.sm,
                                      ),
                                      child: LexivoChatBubble(
                                        message: message.content,
                                        variant: message.role ==
                                                ChatMessageRole.user
                                            ? LexivoChatBubbleVariant.user
                                            : LexivoChatBubbleVariant.assistant,
                                        citationChips:
                                            message.citations.isEmpty
                                                ? null
                                                : Wrap(
                                                    spacing: LexivoSpacing.xs,
                                                    runSpacing:
                                                        LexivoSpacing.xs,
                                                    children: message.citations
                                                        .map(
                                                          (c) => Chip(
                                                            label: Text(
                                                              c.label ??
                                                                  c.snippet ??
                                                                  'cite ${c.index ?? ''}',
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: LexivoSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: LexivoTextField(
                      controller: _controller,
                      variant: LexivoTextFieldVariant.multiline,
                      hintText: 'Ask a question…',
                      enabled: !asyncChat.isLoading &&
                          !(asyncChat.valueOrNull?.isSending ?? false),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: LexivoSpacing.sm),
                  LexivoButton(
                    label: 'Send',
                    loading: asyncChat.valueOrNull?.isSending ?? false,
                    onPressed: () => _send(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
