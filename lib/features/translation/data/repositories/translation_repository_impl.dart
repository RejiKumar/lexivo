import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/translation/data/datasources/translation_remote_datasource.dart';
import 'package:lexivo/features/translation/domain/repositories/translation_repository.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  TranslationRepositoryImpl(this._remote);

  final TranslationRemoteDatasource _remote;

  @override
  Future<Result<Document>> getDocument(String id) => _remote.getDocument(id);

  @override
  Future<Result<TranslationStatus>> getTranslationStatus(String id) =>
      _remote.getTranslationStatus(id);

  @override
  Future<Result<Document>> requestTranslation(
    String id, {
    required String sourceLang,
    required String targetLang,
  }) =>
      _remote.requestTranslation(
        id,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
}
