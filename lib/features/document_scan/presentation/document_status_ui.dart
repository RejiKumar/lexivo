import 'package:lexivo/core/design_system/components/document_card.dart';
import 'package:lexivo/core/entities/document.dart';

/// Maps domain status → design-system badge enum (presentation only).
LexivoDocumentStatus toLexivoDocumentStatus(DocumentStatus status) {
  switch (status) {
    case DocumentStatus.processing:
      return LexivoDocumentStatus.processing;
    case DocumentStatus.ready:
      return LexivoDocumentStatus.ready;
    case DocumentStatus.failed:
      return LexivoDocumentStatus.failed;
  }
}

String formatDocumentTimestamp(DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}
