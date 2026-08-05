import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/tokens/breakpoints.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/features/document_scan/presentation/screens/_document_library_shared.dart';

/// Mobile document library — single-column list.
class DocumentLibraryMobileLayout extends StatelessWidget {
  const DocumentLibraryMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = LexivoBreakpoints.pagePadding(LexivoBreakpoint.mobile);

    return Scaffold(
      key: DocumentLibraryLayoutKeys.mobile,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: DocumentLibraryListPane(
            onDocumentTap: (Document doc) =>
                context.go(RouteGuards.documentOcr(doc.id)),
          ),
        ),
      ),
    );
  }
}
