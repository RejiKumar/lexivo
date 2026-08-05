import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/design_system/tokens/breakpoints.dart';
import 'package:lexivo/features/rag_chat/presentation/screens/_desktop_layout.dart';
import 'package:lexivo/features/rag_chat/presentation/screens/_mobile_layout.dart';
import 'package:lexivo/features/rag_chat/presentation/screens/_rag_chat_shared.dart';
import 'package:lexivo/features/rag_chat/presentation/screens/_tablet_layout.dart';

/// Ask-the-document chat entry — selects layout by [LexivoBreakpoints].
///
/// All layouts share [ragChatProvider]; composer state lives on the entry.
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

  Future<void> _send() => sendRagChatMessage(
        context: context,
        ref: ref,
        documentId: widget.documentId,
        controller: _controller,
      );

  @override
  Widget build(BuildContext context) {
    final breakpoint =
        LexivoBreakpoints.resolve(MediaQuery.sizeOf(context).width);

    return switch (breakpoint) {
      LexivoBreakpoint.mobile => RagChatMobileLayout(
          documentId: widget.documentId,
          controller: _controller,
          onSend: _send,
        ),
      LexivoBreakpoint.tablet => RagChatTabletLayout(
          documentId: widget.documentId,
          controller: _controller,
          onSend: _send,
        ),
      LexivoBreakpoint.desktop => RagChatDesktopLayout(
          documentId: widget.documentId,
          controller: _controller,
          onSend: _send,
        ),
    };
  }
}
