import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/design_system/components/bottom_sheet.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/input.dart';
import 'package:lexivo/core/design_system/tokens/breakpoints.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/l10n/l10n.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';
import 'package:lexivo/features/rag_chat/presentation/providers/rag_chat_providers.dart';
import 'package:lexivo/features/rag_chat/presentation/screens/_rag_chat_shared.dart';

/// Mobile RAG chat — single-column conversation; citation details via sheet.
class RagChatMobileLayout extends ConsumerWidget {
  const RagChatMobileLayout({
    super.key,
    required this.documentId,
    required this.controller,
    required this.onSend,
  });

  final String documentId;
  final TextEditingController controller;
  final VoidCallback onSend;

  void _showCitation(BuildContext context, Citation citation) {
    final l10n = AppLocalizations.of(context);
    LexivoBottomSheet.show(
      context,
      variant: LexivoBottomSheetVariant.scrollable,
      title: l10n.chatCitationDetailsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(citationLabel(citation, l10n), style: LexivoTypography.bodyStrong),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChat = ref.watch(ragChatProvider(documentId));
    final padding = LexivoBreakpoints.pagePadding(LexivoBreakpoint.mobile);
    final sending = asyncChat.valueOrNull?.isSending ?? false;

    return Scaffold(
      key: RagChatLayoutKeys.mobile,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RagChatHeader(documentId: documentId),
              const SizedBox(height: LexivoSpacing.md),
              Expanded(
                child: RagChatConversationPane(
                  documentId: documentId,
                  onCitationTap: (c) => _showCitation(context, c),
                ),
              ),
              const SizedBox(height: LexivoSpacing.md),
              RagChatComposer(
                controller: controller,
                onSend: onSend,
                enabled: !asyncChat.isLoading && !sending,
                loading: sending,
                variant: LexivoTextFieldVariant.multiline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
