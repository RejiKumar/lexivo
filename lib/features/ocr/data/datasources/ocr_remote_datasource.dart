import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/entities/document_mapper.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/utils/result.dart';

/// Remote OCR reads — [ApiClient] only (no Dio imports).
class OcrRemoteDatasource {
  OcrRemoteDatasource(this._api);

  final ApiClient _api;

  Future<Result<Document>> getDocument(String id) async {
    final result = await _api.getDocument(id);
    return result.map(documentFromDto);
  }

  Future<Result<DocumentStatus>> getStatus(String id) async {
    final result = await _api.getDocumentStatus(id);
    return result.map(documentStatusFromDto);
  }
}
