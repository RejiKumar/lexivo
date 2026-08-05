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
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/design_system/tokens/radius.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/l10n/l10n.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/widgets/async_value_view.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';
import 'package:lexivo/features/rag_chat/presentation/providers/rag_chat_providers.dart';

/// Keys used by adaptive layout widget tests (nav-independent).
abstract final class RagChatLayoutKeys {
  static const mobile = Key('rag_chat_mobile');
  static const tablet = Key('rag_chat_tablet');
  static const desktop = Key('rag_chat_desktop');
  static const conversationPane = Key('rag_chat_conversation_pane');
  static const contextPane = Key('rag_chat_context_pane');
}

String citationLabel(Citation citation, AppLocalizations l10n) {
  return citation.label ??
      citation.snippet ??
      l10n.chatCitationFallback('${citation.index ?? ''}');
}

List<Citation> citationsFromChat(RagChatState chat) {
  final seen = <String>{};
  final out = <Citation>[];
  for (final message in chat.messages) {
    for (final citation in message.citations) {
      final key =
          '${citation.chunkId ?? ''}|${citation.index ?? ''}|${citation.snippet ?? ''}|${citation.label ?? ''}';
      if (seen.add(key)) out.add(citation);
    }
  }
  return out;
}

Future<void> sendRagChatMessage({
  required BuildContext context,
  required WidgetRef ref,
  required String documentId,
  required TextEditingController controller,
}) async {
  final text = controller.text;
  controller.clear();
  await ref.read(ragChatProvider(documentId).notifier).sendMessage(text);
  final err = ref.read(ragChatProvider(documentId)).valueOrNull?.sendError;
  if (err != null && context.mounted) {
    LexivoSnackbar.show(
      context,
      message: err.message,
      variant: LexivoSnackbarVariant.error,
    );
  }
}

class RagChatHeader extends StatelessWidget {
  const RagChatHeader({
    super.key,
    required this.documentId,
    this.compact = false,
  });

  final String documentId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go(RouteGuards.documentTranslation(documentId)),
          tooltip: l10n.backAction,
        ),
        Expanded(
          child: Text(
            l10n.chatTitle,
            style: compact ? LexivoTypography.title : LexivoTypography.headline,
          ),
        ),
        LexivoButton(
          label: l10n.exportAction,
          variant: LexivoButtonVariant.secondary,
          onPressed: () => context.go(RouteGuards.documentExport(documentId)),
        ),
      ],
    );
  }
}

class RagChatComposer extends StatelessWidget {
  const RagChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.enabled,
    required this.loading,
    this.variant = LexivoTextFieldVariant.multiline,
    this.submitOnEnter = false,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  final bool loading;
  final LexivoTextFieldVariant variant;
  final bool submitOnEnter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: LexivoTextField(
            controller: controller,
            variant: variant,
            hintText: l10n.chatInputHint,
            enabled: enabled,
            onSubmitted: submitOnEnter ? (_) => onSend() : null,
          ),
        ),
        const SizedBox(width: LexivoSpacing.sm),
        LexivoButton(
          label: l10n.sendAction,
          loading: loading,
          onPressed: onSend,
        ),
      ],
    );
  }
}

class RagChatConversationPane extends ConsumerWidget {
  const RagChatConversationPane({
    super.key,
    required this.documentId,
    required this.onCitationTap,
  });

  final String documentId;
  final ValueChanged<Citation> onCitationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncChat = ref.watch(ragChatProvider(documentId));

    return Column(
      key: RagChatLayoutKeys.conversationPane,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: AsyncValueView<RagChatState>(
            value: asyncChat,
            onRetry: () =>
                ref.read(ragChatProvider(documentId).notifier).refresh(),
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
                          .read(ragChatProvider(documentId).notifier)
                          .retrySend(),
                    ),
                    const SizedBox(height: LexivoSpacing.sm),
                  ],
                  Expanded(
                    child: chat.messages.isEmpty && !chat.isSending
                        ? LexivoEmptyState(
                            title: l10n.chatEmptyTitle,
                            description: l10n.chatEmptyDescription,
                          )
                        : ListView.builder(
                            itemCount: chat.messages.length +
                                (chat.isSending ? 2 : 0),
                            itemBuilder: (context, index) {
                              if (chat.isSending &&
                                  index >= chat.messages.length) {
                                final offset = index - chat.messages.length;
                                if (offset == 0) {
                                  return LexivoChatBubble(
                                    message: chat.pendingUserContent ?? '',
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
                                  variant: message.role == ChatMessageRole.user
                                      ? LexivoChatBubbleVariant.user
                                      : LexivoChatBubbleVariant.assistant,
                                  citationChips: message.citations.isEmpty
                                      ? null
                                      : Wrap(
                                          spacing: LexivoSpacing.xs,
                                          runSpacing: LexivoSpacing.xs,
                                          children: message.citations
                                              .map(
                                                (c) => InkWell(
                                                  onTap: () =>
                                                      onCitationTap(c),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    LexivoRadius.md,
                                                  ),
                                                  child: Chip(
                                                    label: Text(
                                                      citationLabel(c, l10n),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                    ),
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
      ],
    );
  }
}

class RagChatContextPane extends ConsumerWidget {
  const RagChatContextPane({
    super.key,
    required this.documentId,
    this.highlighted,
    this.onCitationTap,
  });

  final String documentId;
  final Citation? highlighted;
  final ValueChanged<Citation>? onCitationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<LexivoColors>()!;
    final asyncChat = ref.watch(ragChatProvider(documentId));
    final citations = asyncChat.valueOrNull == null
        ? const <Citation>[]
        : citationsFromChat(asyncChat.valueOrNull!);

    return DecoratedBox(
      key: RagChatLayoutKeys.contextPane,
      decoration: BoxDecoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(LexivoRadius.lg),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(LexivoSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.chatContextTitle, style: LexivoTypography.title),
            const SizedBox(height: LexivoSpacing.md),
            Expanded(
              child: citations.isEmpty
                  ? _CompactContextEmpty(
                      title: l10n.chatContextEmptyTitle,
                      description: l10n.chatContextEmptyDescription,
                    )
                  : ListView.separated(
                      itemCount: citations.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: LexivoSpacing.sm),
                      itemBuilder: (context, index) {
                        final citation = citations[index];
                        final isHighlighted = highlighted != null &&
                            citationLabel(citation, l10n) ==
                                citationLabel(highlighted!, l10n) &&
                            citation.snippet == highlighted!.snippet;
                        return Material(
                          color: isHighlighted
                              ? colors.brandPrimary.withValues(alpha: 0.08)
                              : colors.backgroundDefault,
                          borderRadius: BorderRadius.circular(LexivoRadius.md),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(LexivoRadius.md),
                            onTap: onCitationTap == null
                                ? null
                                : () => onCitationTap!(citation),
                            child: Padding(
                              padding: const EdgeInsets.all(LexivoSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    citationLabel(citation, l10n),
                                    style: LexivoTypography.bodyStrong,
                                  ),
                                  if (citation.snippet != null &&
                                      citation.snippet!.isNotEmpty) ...[
                                    const SizedBox(height: LexivoSpacing.xs),
                                    Text(
                                      citation.snippet!,
                                      style: LexivoTypography.caption.copyWith(
                                        color: colors.contentSecondary,
                                      ),
                                    ),
                                  ],
                                  if (citation.page != null) ...[
                                    const SizedBox(height: LexivoSpacing.xs),
                                    Text(
                                      'p. ${citation.page}',
                                      style: LexivoTypography.caption.copyWith(
                                        color: colors.contentSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactContextEmpty extends StatelessWidget {
  const _CompactContextEmpty({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(LexivoSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.format_quote_outlined,
                size: 32,
                color: colors.contentSecondary,
              ),
              const SizedBox(height: LexivoSpacing.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: LexivoTypography.bodyStrong.copyWith(
                  color: colors.contentPrimary,
                ),
              ),
              const SizedBox(height: LexivoSpacing.xs),
              Text(
                description,
                textAlign: TextAlign.center,
                style: LexivoTypography.caption.copyWith(
                  color: colors.contentSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
