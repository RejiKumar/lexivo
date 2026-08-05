import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/components/bottom_sheet.dart';
import 'package:lexivo/core/design_system/tokens/breakpoints.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/l10n/l10n.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/features/document_scan/presentation/screens/_document_library_shared.dart';

/// Tablet document library — two-pane list | detail.
class DocumentLibraryTabletLayout extends StatefulWidget {
  const DocumentLibraryTabletLayout({super.key});

  @override
  State<DocumentLibraryTabletLayout> createState() =>
      _DocumentLibraryTabletLayoutState();
}

class _DocumentLibraryTabletLayoutState
    extends State<DocumentLibraryTabletLayout> {
  Document? _selected;

  void _showActions(Document doc) {
    final l10n = AppLocalizations.of(context);
    LexivoBottomSheet.show(
      context,
      variant: LexivoBottomSheetVariant.actionList,
      title: l10n.libraryDocumentActions,
      actions: [
        LexivoBottomSheetAction(
          label: l10n.libraryOpenDocument,
          icon: Icons.description_outlined,
          onTap: () {
            Navigator.of(context).pop();
            context.go(RouteGuards.documentOcr(doc.id));
          },
        ),
        LexivoBottomSheetAction(
          label: l10n.libraryScanAction,
          icon: Icons.document_scanner_outlined,
          onTap: () {
            Navigator.of(context).pop();
            context.go(RouteGuards.documentScan);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = LexivoBreakpoints.pagePadding(LexivoBreakpoint.tablet);

    return Scaffold(
      key: DocumentLibraryLayoutKeys.tablet,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: DocumentLibraryListPane(
                  selectedDocumentId: _selected?.id,
                  onDocumentTap: (doc) => setState(() => _selected = doc),
                ),
              ),
              const SizedBox(width: LexivoSpacing.lg),
              Expanded(
                flex: 6,
                child: DocumentLibraryDetailPane(
                  document: _selected,
                  onShowActions:
                      _selected == null ? null : () => _showActions(_selected!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
