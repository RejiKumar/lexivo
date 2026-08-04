import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/document_scan/data/datasources/document_remote_datasource.dart';
import 'package:lexivo/features/document_scan/domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._remote);

  final DocumentRemoteDatasource _remote;

  @override
  Future<Result<List<Document>>> listDocuments() => _remote.listDocuments();

  @override
  Future<Result<Document>> getDocument(String id) => _remote.getDocument(id);

  @override
  Future<Result<DocumentStatus>> getStatus(String id) => _remote.getStatus(id);

  @override
  Future<Result<Document>> createWithUpload({
    required List<int> bytes,
    required String filename,
    String? title,
  }) =>
      _remote.createWithUpload(
        bytes: bytes,
        filename: filename,
        title: title,
      );
}
