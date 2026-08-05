import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/tokens/breakpoints.dart';

/// Shell-level prompt convention: sheet on mobile, dialog on tablet/desktop/web.
///
/// Callers supply the concrete presenters (e.g. [LexivoBottomSheet.show] /
/// [LexivoDialog.show]); this helper only chooses which path to take.
Future<T?> showLexivoAdaptiveOverlay<T>({
  required BuildContext context,
  required Future<T?> Function() showSheet,
  required Future<T?> Function() showDialog,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final useSheet =
      LexivoBreakpoints.resolve(width) == LexivoBreakpoint.mobile;
  return useSheet ? showSheet() : showDialog();
}
