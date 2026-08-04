import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/pdf_export/domain/entities/export_job.dart';
import 'package:lexivo/features/pdf_export/domain/repositories/pdf_export_repository.dart';

class RequestPdfExport {
  const RequestPdfExport(this._repo);

  final PdfExportRepository _repo;

  Future<Result<ExportJob>> call(
    String documentId,
    ExportSectionToggles toggles,
  ) {
    if (!toggles.anySelected) {
      return Future.value(
        Result.failure(
          const ValidationFailure(
            message:
                'Select at least one section (summary, translation, or chat)',
          ),
        ),
      );
    }
    return _repo.requestExport(documentId, toggles);
  }
}

class GetExportStatus {
  const GetExportStatus(this._repo);

  final PdfExportRepository _repo;

  Future<Result<ExportJob>> call(String documentId) =>
      _repo.getExportStatus(documentId);
}

class GetExport {
  const GetExport(this._repo);

  final PdfExportRepository _repo;

  Future<Result<ExportJob>> call(String exportId) => _repo.getExport(exportId);
}

bool isExportStatusTerminal(ExportJobStatus status) =>
    status == ExportJobStatus.ready || status == ExportJobStatus.failed;
