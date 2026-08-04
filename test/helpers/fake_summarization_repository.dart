import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/summarization/domain/repositories/summarization_repository.dart';

import 'fake_document_repository.dart';

class FakeSummarizationRepository implements SummarizationRepository {
  FakeSummarizationRepository({List<Document>? initial})
      : documents = List<Document>.from(initial ?? const []);

  final List<Document> documents;
  Failure? nextFailure;
  Failure? nextStatusFailure;
  Failure? nextRequestFailure;
  final List<SummaryStatus> statusSequence = [];
  var statusCalls = 0;
  var getCalls = 0;
  var requestCalls = 0;

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
  Future<Result<SummaryStatus>> getSummaryStatus(String id) async {
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
    return Result.success(doc?.summaryStatus ?? SummaryStatus.failed);
  }

  @override
  Future<Result<Document>> requestSummary(String id) async {
    requestCalls++;
    if (nextRequestFailure != null) {
      final f = nextRequestFailure!;
      nextRequestFailure = null;
      return Result.failure(f);
    }
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return Result.failure(f);
    }
    final index = documents.indexWhere((d) => d.id == id);
    if (index < 0) {
      return Result.failure(const UnexpectedFailure(message: 'Not found'));
    }
    final current = documents[index];
    final updated = current.copyWith(
      summaryStatus: requestResultStatus,
      shortSummary: requestResultStatus == SummaryStatus.ready
          ? (current.shortSummary ?? 'Short')
          : current.shortSummary,
      detailedSummary: requestResultStatus == SummaryStatus.ready
          ? (current.detailedSummary ?? 'Detailed')
          : current.detailedSummary,
    );
    documents[index] = updated;
    return Result.success(updated);
  }

  /// Status applied after [requestSummary] (default processing for poll paths).
  SummaryStatus requestResultStatus = SummaryStatus.processing;
}

Document sampleSummaryDocument({
  String id = 'doc-1',
  DocumentStatus status = DocumentStatus.ready,
  SummaryStatus summaryStatus = SummaryStatus.ready,
  String? title = 'Sample',
  String? extractedText = 'Extracted OCR body from the lease agreement.',
  String? shortSummary = 'Lease covers term and rent.',
  String? detailedSummary =
      'This lease agreement outlines the rental term, payment schedule, and tenant obligations in detail.',
}) {
  return sampleDocument(
    id: id,
    status: status,
    title: title,
    extractedText: extractedText,
    shortSummary: shortSummary,
    detailedSummary: detailedSummary,
    summaryStatus: summaryStatus,
  );
}
