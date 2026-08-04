import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';

/// Document library + upload port.
abstract class DocumentRepository {
  Future<Result<List<Document>>> listDocuments();

  Future<Result<Document>> getDocument(String id);

  Future<Result<DocumentStatus>> getStatus(String id);

  Future<Result<Document>> createWithUpload({
    required List<int> bytes,
    required String filename,
    String? title,
  });
}
