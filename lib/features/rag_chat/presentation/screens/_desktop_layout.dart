import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/dialog.dart';
import 'package:lexivo/core/design_system/components/input.dart';
import 'package:lexivo/core/design_system/tokens/breakpoints.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/l10n/l10n.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';
import 'package:lexivo/features/rag_chat/presentation/providers/rag_chat_providers.dart';
import 'package:lexivo/features/rag_chat/presentation/screens/_rag_chat_shared.dart';

/// Desktop RAG chat — multi-pane conversation + context; Enter to send; dialogs.
class RagChatDesktopLayout extends ConsumerStatefulWidget {
  const RagChatDesktopLayout({
    super.key,
    required this.documentId,
    required this.controller,
    required this.onSend,
  });

  final String documentId;
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  ConsumerState<RagChatDesktopLayout> createState() =>
      _RagChatDesktopLayoutState();
}

class _RagChatDesktopLayoutState extends ConsumerState<RagChatDesktopLayout> {
  Citation? _highlighted;

  void _showCitationDialog(Citation citation) {
    final l10n = AppLocalizations.of(context);
    LexivoDialog.show(
      context,
      variant: LexivoDialogVariant.custom,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.chatCitationDetailsTitle,
            style: LexivoTypography.title,
          ),
          const SizedBox(height: LexivoSpacing.md),
          Text(
            citationLabel(citation, l10n),
            style: LexivoTypography.bodyStrong,
          ),
          if (citation.snippet != null && citation.snippet!.isNotEmpty) ...[
            const SizedBox(height: LexivoSpacing.sm),
            Text(citation.snippet!, style: LexivoTypography.body),
          ],
          const SizedBox(height: LexivoSpacing.md),
          LexivoButton(
            label: l10n.chatDoneAction,
            onPressed: () => Navigator.of(context).pop(),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncChat = ref.watch(ragChatProvider(widget.documentId));
    final padding = LexivoBreakpoints.pagePadding(LexivoBreakpoint.desktop);
    final sending = asyncChat.valueOrNull?.isSending ?? false;

    return Scaffold(
      key: RagChatLayoutKeys.desktop,
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
                      flex: 7,
                      child: RagChatConversationPane(
                        documentId: widget.documentId,
                        onCitationTap: (c) {
                          setState(() => _highlighted = c);
                          _showCitationDialog(c);
                        },
                      ),
                    ),
                    const SizedBox(width: LexivoSpacing.xl),
                    SizedBox(
                      width: 320,
                      child: RagChatContextPane(
                        documentId: widget.documentId,
                        highlighted: _highlighted,
                        onCitationTap: (c) {
                          setState(() => _highlighted = c);
                          _showCitationDialog(c);
                        },
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
