import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';

/// Shared document processing status — API string aligned.
enum DocumentStatus { processing, ready, failed }

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
