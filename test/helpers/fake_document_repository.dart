import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/document_scan/domain/repositories/document_repository.dart';

Document sampleDocument({
  String id = 'doc-1',
  DocumentStatus status = DocumentStatus.ready,
  String? title = 'Sample',
  String? extractedText,
}) {
  return Document(
    id: id,
    userId: 'db-user-1',
    title: title,
    storageKey: 'uploads/$id.pdf',
    status: status,
    extractedText: extractedText,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}

class FakeDocumentRepository implements DocumentRepository {
  FakeDocumentRepository({List<Document>? initial})
      : documents = List<Document>.from(initial ?? const []);

  final List<Document> documents;
  Failure? nextFailure;
  final List<DocumentStatus> statusSequence = [];
  var statusCalls = 0;

  @override
  Future<Result<List<Document>>> listDocuments() async {
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return Result.failure(f);
    }
    return Result.success(List.unmodifiable(documents));
  }

  @override
  Future<Result<Document>> getDocument(String id) async {
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
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return Result.failure(f);
    }
    if (statusSequence.isNotEmpty) {
      final index = statusCalls.clamp(0, statusSequence.length - 1);
      statusCalls++;
      return Result.success(statusSequence[index]);
    }
    final doc = documents.cast<Document?>().firstWhere(
          (d) => d?.id == id,
          orElse: () => null,
        );
    return Result.success(doc?.status ?? DocumentStatus.failed);
  }

  @override
  Future<Result<Document>> createWithUpload({
    required List<int> bytes,
    required String filename,
    String? title,
  }) async {
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return Result.failure(f);
    }
    final doc = sampleDocument(
      id: 'doc-${documents.length + 1}',
      status: createdStatus,
      title: title ?? filename,
    );
    documents.insert(0, doc);
    return Result.success(doc);
  }

  /// Status applied to newly uploaded docs (default ready to avoid stray polls).
  DocumentStatus createdStatus = DocumentStatus.ready;
}
