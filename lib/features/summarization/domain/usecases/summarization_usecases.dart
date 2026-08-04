import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/summarization/domain/repositories/summarization_repository.dart';

class LoadSummary {
  const LoadSummary(this._repo);

  final SummarizationRepository _repo;

  Future<Result<Document>> call(String id) => _repo.getDocument(id);
}

class GetSummaryStatus {
  const GetSummaryStatus(this._repo);

  final SummarizationRepository _repo;

  Future<Result<SummaryStatus>> call(String id) => _repo.getSummaryStatus(id);
}

class RequestSummary {
  const RequestSummary(this._repo);

  final SummarizationRepository _repo;

  Future<Result<Document>> call(String id) => _repo.requestSummary(id);
}

/// Whether a summary status is terminal for polling.
bool isSummaryStatusTerminal(SummaryStatus status) =>
    status == SummaryStatus.ready || status == SummaryStatus.failed;
