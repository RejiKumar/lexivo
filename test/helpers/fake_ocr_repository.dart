import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/ocr/domain/repositories/ocr_repository.dart';

import 'fake_document_repository.dart';

class FakeOcrRepository implements OcrRepository {
  FakeOcrRepository({List<Document>? initial})
      : documents = List<Document>.from(initial ?? const []);

  final List<Document> documents;
  Failure? nextFailure;
  Failure? nextStatusFailure;
  final List<DocumentStatus> statusSequence = [];
  var statusCalls = 0;
  var getCalls = 0;

  @override
  Future<Result<Document>> getDocument(String id) async {
    getCalls++;
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return Result.failure(f);
    }
    final doc = documents.cast<Document?>().firstWhere(
          (d) => d?.id == id,
          orElse: () => null,
        );
    if (doc == null) {
      return Result.failure(const UnexpectedFailure(message: 'Not found'));
    }
    return Result.success(doc);
  }

  @override
  Future<Result<DocumentStatus>> getStatus(String id) async {
    statusCalls++;
    if (nextStatusFailure != null) {
      final f = nextStatusFailure!;
      nextStatusFailure = null;
      return Result.failure(f);
    }
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return Result.failure(f);
    }
    if (statusSequence.isNotEmpty) {
      final index = (statusCalls - 1).clamp(0, statusSequence.length - 1);
      return Result.success(statusSequence[index]);
    }
    final doc = documents.cast<Document?>().firstWhere(
          (d) => d?.id == id,
          orElse: () => null,
        );
    return Result.success(doc?.status ?? DocumentStatus.failed);
  }
}

Document sampleOcrDocument({
  String id = 'doc-1',
  DocumentStatus status = DocumentStatus.ready,
  String? title = 'Sample',
  String? extractedText = 'Extracted OCR body from the lease agreement.',
}) {
  return sampleDocument(
    id: id,
    status: status,
    title: title,
    extractedText: extractedText,
  );
}
