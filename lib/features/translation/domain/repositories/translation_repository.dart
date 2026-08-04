import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';

/// Translation port — get document, status, and request translation.
abstract class TranslationRepository {
  Future<Result<Document>> getDocument(String id);

  Future<Result<TranslationStatus>> getTranslationStatus(String id);

  Future<Result<Document>> requestTranslation(
    String id, {
    required String sourceLang,
    required String targetLang,
  });
}
