import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/design_system/components/input.dart';
import 'package:lexivo/core/design_system/tokens/breakpoints.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';
import 'package:lexivo/features/rag_chat/presentation/providers/rag_chat_providers.dart';
import 'package:lexivo/features/rag_chat/presentation/screens/_rag_chat_shared.dart';

/// Tablet RAG chat — conversation + context side panel.
class RagChatTabletLayout extends ConsumerStatefulWidget {
  const RagChatTabletLayout({
    super.key,
    required this.documentId,
    required this.controller,
    required this.onSend,
  });

  final String documentId;
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  ConsumerState<RagChatTabletLayout> createState() =>
      _RagChatTabletLayoutState();
}

class _RagChatTabletLayoutState extends ConsumerState<RagChatTabletLayout> {
  Citation? _highlighted;

  @override
  Widget build(BuildContext context) {
    final asyncChat = ref.watch(ragChatProvider(widget.documentId));
    final padding = LexivoBreakpoints.pagePadding(LexivoBreakpoint.tablet);
    final sending = asyncChat.valueOrNull?.isSending ?? false;

    return Scaffold(
      key: RagChatLayoutKeys.tablet,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RagChatHeader(documentId: widget.documentId),
              const SizedBox(height: LexivoSpacing.md),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 6,
                      child: RagChatConversationPane(
                        documentId: widget.documentId,
                        onCitationTap: (c) =>
                            setState(() => _highlighted = c),
                      ),
                    ),
                    const SizedBox(width: LexivoSpacing.lg),
                    Expanded(
                      flex: 4,
                      child: RagChatContextPane(
                        documentId: widget.documentId,
                        highlighted: _highlighted,
                        onCitationTap: (c) =>
                            setState(() => _highlighted = c),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LexivoSpacing.md),
              RagChatComposer(
                controller: widget.controller,
                onSend: widget.onSend,
                enabled: !asyncChat.isLoading && !sending,
                loading: sending,
                variant: LexivoTextFieldVariant.text,
                submitOnEnter: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
