import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/dialog.dart';
import 'package:lexivo/core/design_system/tokens/breakpoints.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/l10n/l10n.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/features/document_scan/presentation/screens/_document_library_shared.dart';

/// Desktop document library — multi-pane list + detail with hover + dialogs.
class DocumentLibraryDesktopLayout extends StatefulWidget {
  const DocumentLibraryDesktopLayout({super.key});

  @override
  State<DocumentLibraryDesktopLayout> createState() =>
      _DocumentLibraryDesktopLayoutState();
}

class _DocumentLibraryDesktopLayoutState
    extends State<DocumentLibraryDesktopLayout> {
  Document? _selected;

  void _showActions(Document doc) {
    final l10n = AppLocalizations.of(context);
    LexivoDialog.show(
      context,
      variant: LexivoDialogVariant.custom,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.libraryDocumentActions),
          const SizedBox(height: LexivoSpacing.md),
          LexivoButton(
            label: l10n.libraryOpenDocument,
            onPressed: () {
              Navigator.of(context).pop();
              context.go(RouteGuards.documentOcr(doc.id));
            },
            fullWidth: true,
          ),
          const SizedBox(height: LexivoSpacing.sm),
          LexivoButton(
            label: l10n.libraryScanAction,
            variant: LexivoButtonVariant.secondary,
            onPressed: () {
              Navigator.of(context).pop();
              context.go(RouteGuards.documentScan);
            },
            fullWidth: true,
          ),
          const SizedBox(height: LexivoSpacing.sm),
          LexivoButton(
            label: l10n.libraryCloseAction,
            variant: LexivoButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = LexivoBreakpoints.pagePadding(LexivoBreakpoint.desktop);

    return Scaffold(
      key: DocumentLibraryLayoutKeys.desktop,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 360,
                child: DocumentLibraryListPane(
                  selectedDocumentId: _selected?.id,
                  enableHoverHighlight: true,
                  onDocumentTap: (doc) => setState(() => _selected = doc),
                ),
              ),
              const SizedBox(width: LexivoSpacing.xl),
              Expanded(
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
