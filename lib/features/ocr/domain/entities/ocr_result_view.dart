import 'package:lexivo/core/entities/document.dart';

/// Presentation-friendly OCR result backed by core [Document].
class OcrResultView {
  const OcrResultView({
    required this.documentId,
    required this.status,
    this.title,
    this.extractedText,
  });

  factory OcrResultView.fromDocument(Document document) {
    return OcrResultView(
      documentId: document.id,
      status: document.status,
      title: document.title,
      extractedText: document.extractedText,
    );
  }

  final String documentId;
  final DocumentStatus status;
  final String? title;
  final String? extractedText;

  bool get hasExtractedText =>
      extractedText != null && extractedText!.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrResultView &&
          documentId == other.documentId &&
          status == other.status &&
          title == other.title &&
          extractedText == other.extractedText;

  @override
  int get hashCode => Object.hash(documentId, status, title, extractedText);
}
