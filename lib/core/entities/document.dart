import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';

/// Shared document processing status — API string aligned (OCR lifecycle).
enum DocumentStatus { processing, ready, failed }

/// Summarization lifecycle — separate from OCR [DocumentStatus].
enum SummaryStatus { idle, processing, ready, failed }

/// Shared document identity for scan, OCR, RAG, export, etc.
///
/// Lives in `core/entities` so features never import `document_scan` internals
/// (architecture §2.3).
@freezed
abstract class Document with _$Document {
  const factory Document({
    required String id,
    required String userId,
    String? title,
    String? storageKey,
    required DocumentStatus status,
    String? extractedText,
    String? shortSummary,
    String? detailedSummary,
    @Default(SummaryStatus.idle) SummaryStatus summaryStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Document;
}

extension DocumentStatusApiX on DocumentStatus {
  String get apiValue => name;

  static DocumentStatus fromApi(String value) {
    switch (value.toLowerCase()) {
      case 'processing':
        return DocumentStatus.processing;
      case 'ready':
        return DocumentStatus.ready;
      case 'failed':
        return DocumentStatus.failed;
      default:
        return DocumentStatus.failed;
    }
  }
}

extension SummaryStatusApiX on SummaryStatus {
  String get apiValue => name;

  static SummaryStatus fromApi(String value) {
    switch (value.toLowerCase()) {
      case 'idle':
        return SummaryStatus.idle;
      case 'processing':
        return SummaryStatus.processing;
      case 'ready':
        return SummaryStatus.ready;
      case 'failed':
        return SummaryStatus.failed;
      default:
        return SummaryStatus.idle;
    }
  }
}
