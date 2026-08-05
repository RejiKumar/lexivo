import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/document_card.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/design_system/tokens/radius.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/l10n/l10n.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/widgets/async_value_view.dart';
import 'package:lexivo/features/document_scan/presentation/document_status_ui.dart';
import 'package:lexivo/features/document_scan/presentation/providers/document_providers.dart';

/// Keys used by adaptive layout widget tests (nav-independent).
abstract final class DocumentLibraryLayoutKeys {
  static const mobile = Key('document_library_mobile');
  static const tablet = Key('document_library_tablet');
  static const desktop = Key('document_library_desktop');
  static const listPane = Key('document_library_list_pane');
  static const detailPane = Key('document_library_detail_pane');
}

String documentDisplayName(Document doc, AppLocalizations l10n) {
  return doc.title?.isNotEmpty == true ? doc.title! : l10n.untitledDocument;
}

/// Shared document list pane — same [documentLibraryProvider] for all breakpoints.
class DocumentLibraryListPane extends ConsumerWidget {
  const DocumentLibraryListPane({
    super.key,
    required this.onDocumentTap,
    this.selectedDocumentId,
    this.showScanButton = true,
    this.enableHoverHighlight = false,
  });

  final ValueChanged<Document> onDocumentTap;
  final String? selectedDocumentId;
  final bool showScanButton;
  final bool enableHoverHighlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final library = ref.watch(documentLibraryProvider);

    return Column(
      key: DocumentLibraryLayoutKeys.listPane,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.navDocuments, style: LexivoTypography.headline),
        const SizedBox(height: LexivoSpacing.md),
        Expanded(
          child: AsyncValueView<List<Document>>(
            value: library,
            onRetry: () =>
                ref.read(documentLibraryProvider.notifier).refresh(),
            builder: (context, docs) {
              if (docs.isEmpty) {
                return LexivoEmptyState(
                  title: l10n.libraryEmptyTitle,
                  description: l10n.libraryEmptyDescription,
                  icon: Icons.description_outlined,
                  ctaLabel: l10n.libraryScanAction,
                  onCtaPressed: () => context.go(RouteGuards.documentScan),
                );
              }
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: LexivoSpacing.sm),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final selected = doc.id == selectedDocumentId;
                  final card = LexivoDocumentCard(
                    name: documentDisplayName(doc, l10n),
                    status: toLexivoDocumentStatus(doc.status),
                    timestamp: formatDocumentTimestamp(doc.createdAt),
                    onTap: () => onDocumentTap(doc),
                  );
                  if (!enableHoverHighlight && !selected) return card;
                  return _SelectableDocumentTile(
                    selected: selected,
                    enableHover: enableHoverHighlight,
                    child: card,
                  );
                },
              );
            },
          ),
        ),
        if (showScanButton) ...[
          const SizedBox(height: LexivoSpacing.md),
          LexivoButton(
            label: l10n.libraryScanAction,
            onPressed: () => context.go(RouteGuards.documentScan),
            fullWidth: true,
          ),
        ],
      ],
    );
  }
}

/// Detail / actions pane for tablet & desktop two-pane layouts.
class DocumentLibraryDetailPane extends StatelessWidget {
  const DocumentLibraryDetailPane({
    super.key,
    required this.document,
    this.onOpenDocument,
    this.onShowActions,
  });

  final Document? document;
  final VoidCallback? onOpenDocument;
  final VoidCallback? onShowActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<LexivoColors>()!;

    return DecoratedBox(
      key: DocumentLibraryLayoutKeys.detailPane,
      decoration: BoxDecoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(LexivoRadius.lg),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(LexivoSpacing.lg),
        child: document == null
            ? LexivoEmptyState(
                title: l10n.librarySelectDocumentTitle,
                description: l10n.librarySelectDocumentDescription,
                icon: Icons.folder_open_outlined,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    documentDisplayName(document!, l10n),
                    style: LexivoTypography.headline,
                  ),
                  const SizedBox(height: LexivoSpacing.sm),
                  Text(
                    formatDocumentTimestamp(document!.createdAt),
                    style: LexivoTypography.caption.copyWith(
                      color: colors.contentSecondary,
                    ),
                  ),
                  const SizedBox(height: LexivoSpacing.md),
                  LexivoDocumentCard(
                    name: documentDisplayName(document!, l10n),
                    status: toLexivoDocumentStatus(document!.status),
                    timestamp: formatDocumentTimestamp(document!.createdAt),
                  ),
                  const Spacer(),
                  LexivoButton(
                    label: l10n.libraryOpenDocument,
                    onPressed: onOpenDocument ??
                        () => context.go(
                              RouteGuards.documentOcr(document!.id),
                            ),
                    fullWidth: true,
                  ),
                  if (onShowActions != null) ...[
                    const SizedBox(height: LexivoSpacing.sm),
                    LexivoButton(
                      label: l10n.libraryDocumentActions,
                      variant: LexivoButtonVariant.secondary,
                      onPressed: onShowActions,
                      fullWidth: true,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _SelectableDocumentTile extends StatefulWidget {
  const _SelectableDocumentTile({
    required this.child,
    required this.selected,
    required this.enableHover,
  });

  final Widget child;
  final bool selected;
  final bool enableHover;

  @override
  State<_SelectableDocumentTile> createState() =>
      _SelectableDocumentTileState();
}

class _SelectableDocumentTileState extends State<_SelectableDocumentTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    final highlight = widget.selected || (widget.enableHover && _hovered);

    Widget tile = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LexivoRadius.lg),
        border: Border.all(
          color: highlight ? colors.borderFocus : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: widget.child,
    );

    if (widget.enableHover) {
      tile = MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: tile,
      );
    }
    return tile;
  }
}
