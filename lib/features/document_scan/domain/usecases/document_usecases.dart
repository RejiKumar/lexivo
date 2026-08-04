import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/document_scan/domain/entities/document_input.dart';
import 'package:lexivo/features/document_scan/domain/repositories/document_repository.dart';

class ObtainDocumentInput {
  const ObtainDocumentInput(this._source);

  final DocumentInputSource _source;

  Future<Result<DocumentBytes>> call({
    DocumentInputPreference preference = DocumentInputPreference.auto,
  }) =>
      _source.captureOrPick(preference: preference);
}

class UploadDocument {
  const UploadDocument(this._repo);

  final DocumentRepository _repo;

  Future<Result<Document>> call({
    required List<int> bytes,
    required String filename,
    String? title,
  }) =>
      _repo.createWithUpload(
        bytes: bytes,
        filename: filename,
        title: title,
      );
}

class ListDocuments {
  const ListDocuments(this._repo);

  final DocumentRepository _repo;

  Future<Result<List<Document>>> call() => _repo.listDocuments();
}

class GetDocument {
  const GetDocument(this._repo);

  final DocumentRepository _repo;

  Future<Result<Document>> call(String id) => _repo.getDocument(id);
}

class GetDocumentStatus {
  const GetDocumentStatus(this._repo);

  final DocumentRepository _repo;

  Future<Result<DocumentStatus>> call(String id) => _repo.getStatus(id);
}
