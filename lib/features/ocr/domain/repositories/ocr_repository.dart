import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';

/// OCR result port — get document + status only (no scan/upload).
abstract class OcrRepository {
  Future<Result<Document>> getDocument(String id);

  Future<Result<DocumentStatus>> getStatus(String id);
}
