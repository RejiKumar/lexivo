import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/entities/document_mapper.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/utils/result.dart';

/// Remote summarization — [ApiClient] only (no Dio imports).
class SummarizationRemoteDatasource {
  SummarizationRemoteDatasource(this._api);

  final ApiClient _api;

  Future<Result<Document>> getDocument(String id) async {
    final result = await _api.getDocument(id);
    return result.map(documentFromDto);
  }

  Future<Result<SummaryStatus>> getSummaryStatus(String id) async {
    final result = await _api.getSummaryStatus(id);
    return result.map(summaryStatusFromDto);
  }

  Future<Result<Document>> requestSummary(String id) async {
    final result = await _api.requestSummary(id);
    return result.map(documentFromDto);
  }
}
