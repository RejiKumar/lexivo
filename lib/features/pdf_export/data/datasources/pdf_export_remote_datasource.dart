import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/pdf_export/data/models/export_mappers.dart';
import 'package:lexivo/features/pdf_export/domain/entities/export_job.dart';

/// Remote PDF export — [ApiClient] only (no Dio imports).
class PdfExportRemoteDatasource {
  PdfExportRemoteDatasource(this._api);

  final ApiClient _api;

  Future<Result<ExportJob>> requestExport(
    String documentId,
    ExportSectionToggles toggles,
  ) async {
    final result = await _api.requestExport(
      documentId,
      includeSummary: toggles.includeSummary,
      includeTranslation: toggles.includeTranslation,
      includeChat: toggles.includeChat,
    );
    return result.map(exportJobFromDto);
  }

  Future<Result<ExportJob>> getExportStatus(String documentId) async {
    final result = await _api.getExportStatus(documentId);
    return result.map(exportJobFromDto);
  }

  Future<Result<ExportJob>> getExport(String exportId) async {
    final result = await _api.getExport(exportId);
    return result.map(exportJobFromDto);
  }
}
