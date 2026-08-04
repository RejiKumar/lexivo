import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';

/// Summarization port — get document, status, and request summary.
abstract class SummarizationRepository {
  Future<Result<Document>> getDocument(String id);

  Future<Result<SummaryStatus>> getSummaryStatus(String id);

  Future<Result<Document>> requestSummary(String id);
}
