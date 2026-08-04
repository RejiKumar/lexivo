import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/ocr/domain/repositories/ocr_repository.dart';

class GetOcrDocument {
  const GetOcrDocument(this._repo);

  final OcrRepository _repo;

  Future<Result<Document>> call(String id) => _repo.getDocument(id);
}

class GetOcrStatus {
  const GetOcrStatus(this._repo);

  final OcrRepository _repo;

  Future<Result<DocumentStatus>> call(String id) => _repo.getStatus(id);
}

/// Whether a document status is terminal for OCR polling.
bool isOcrStatusTerminal(DocumentStatus status) =>
    status == DocumentStatus.ready || status == DocumentStatus.failed;
