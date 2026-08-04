import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/summarization/data/datasources/summarization_remote_datasource.dart';
import 'package:lexivo/features/summarization/domain/repositories/summarization_repository.dart';

class SummarizationRepositoryImpl implements SummarizationRepository {
  SummarizationRepositoryImpl(this._remote);

  final SummarizationRemoteDatasource _remote;

  @override
  Future<Result<Document>> getDocument(String id) => _remote.getDocument(id);

  @override
  Future<Result<SummaryStatus>> getSummaryStatus(String id) =>
      _remote.getSummaryStatus(id);

  @override
  Future<Result<Document>> requestSummary(String id) =>
      _remote.requestSummary(id);
}
