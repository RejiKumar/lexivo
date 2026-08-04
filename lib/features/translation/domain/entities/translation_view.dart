import 'package:lexivo/core/entities/document.dart';

/// Presentation-friendly translation view backed by core [Document].
class TranslationView {
  const TranslationView({
    required this.documentId,
    required this.translationStatus,
    this.title,
    this.translatedText,
    this.sourceLang,
    this.targetLang,
  });

  factory TranslationView.fromDocument(Document document) {
    return TranslationView(
      documentId: document.id,
      translationStatus: document.translationStatus,
      title: document.title,
      translatedText: document.translatedText,
      sourceLang: document.sourceLang,
      targetLang: document.targetLang,
    );
  }

  final String documentId;
  final TranslationStatus translationStatus;
  final String? title;
  final String? translatedText;
  final String? sourceLang;
  final String? targetLang;

  bool get hasTranslation {
    final text = translatedText?.trim() ?? '';
    return text.isNotEmpty;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationView &&
          documentId == other.documentId &&
          translationStatus == other.translationStatus &&
          title == other.title &&
          translatedText == other.translatedText &&
          sourceLang == other.sourceLang &&
          targetLang == other.targetLang;

  @override
  int get hashCode => Object.hash(
        documentId,
        translationStatus,
        title,
        translatedText,
        sourceLang,
        targetLang,
      );
}
