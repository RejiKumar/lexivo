import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/entities/document_mapper.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/utils/result.dart';

/// Remote translation — [ApiClient] only (no Dio imports).
class TranslationRemoteDatasource {
  TranslationRemoteDatasource(this._api);

  final ApiClient _api;

  Future<Result<Document>> getDocument(String id) async {
    final result = await _api.getDocument(id);
    return result.map(documentFromDto);
  }

  Future<Result<TranslationStatus>> getTranslationStatus(String id) async {
    final result = await _api.getTranslationStatus(id);
    return result.map(translationStatusFromDto);
  }

  Future<Result<Document>> requestTranslation(
    String id, {
    required String sourceLang,
    required String targetLang,
  }) async {
    final result = await _api.requestTranslation(
      id,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
    return result.map(documentFromDto);
  }
}
