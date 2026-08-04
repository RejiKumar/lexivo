import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/entities/document_mapper.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/utils/result.dart';

/// Remote documents API — [ApiClient] only (no Dio imports).
class DocumentRemoteDatasource {
  DocumentRemoteDatasource(this._api);

  final ApiClient _api;

  Future<Result<List<Document>>> listDocuments() async {
    final result = await _api.listDocuments();
    return result.map(
      (dto) => dto.items.map(documentFromDto).toList(),
    );
  }

  Future<Result<Document>> getDocument(String id) async {
    final result = await _api.getDocument(id);
    return result.map(documentFromDto);
  }

  Future<Result<DocumentStatus>> getStatus(String id) async {
    final result = await _api.getDocumentStatus(id);
    return result.map(documentStatusFromDto);
  }

  Future<Result<Document>> createWithUpload({
    required List<int> bytes,
    required String filename,
    String? title,
  }) async {
    final result = await _api.createDocument(
      bytes: bytes,
      filename: filename,
      title: title,
    );
    return result.map(documentFromDto);
  }
}
