import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/translation/domain/repositories/translation_repository.dart';

/// v1 supported language codes: EN↔ES, FR, DE, HI, PT.
const supportedTranslationLangs = ['en', 'es', 'fr', 'de', 'hi', 'pt'];

bool isSupportedTranslationPair(String sourceLang, String targetLang) {
  final source = sourceLang.trim().toLowerCase();
  final target = targetLang.trim().toLowerCase();
  if (!supportedTranslationLangs.contains(source) ||
      !supportedTranslationLangs.contains(target)) {
    return false;
  }
  if (source == target) return false;
  return source == 'en' || target == 'en';
}

class LoadTranslation {
  const LoadTranslation(this._repo);

  final TranslationRepository _repo;

  Future<Result<Document>> call(String id) => _repo.getDocument(id);
}

class GetTranslationStatus {
  const GetTranslationStatus(this._repo);

  final TranslationRepository _repo;

  Future<Result<TranslationStatus>> call(String id) =>
      _repo.getTranslationStatus(id);
}

class RequestTranslation {
  const RequestTranslation(this._repo);

  final TranslationRepository _repo;

  Future<Result<Document>> call(
    String id, {
    required String sourceLang,
    required String targetLang,
  }) {
    if (!isSupportedTranslationPair(sourceLang, targetLang)) {
      return Future.value(
        Result.failure(
          const ValidationFailure(
            message:
                'Unsupported language pair; v1 requires EN↔ES,FR,DE,HI,PT',
          ),
        ),
      );
    }
    return _repo.requestTranslation(
      id,
      sourceLang: sourceLang.trim().toLowerCase(),
      targetLang: targetLang.trim().toLowerCase(),
    );
  }
}

/// Whether a translation status is terminal for polling.
bool isTranslationStatusTerminal(TranslationStatus status) =>
    status == TranslationStatus.ready || status == TranslationStatus.failed;
