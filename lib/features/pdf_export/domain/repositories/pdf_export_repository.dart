import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/pdf_export/domain/entities/export_job.dart';

abstract class PdfExportRepository {
  Future<Result<ExportJob>> requestExport(
    String documentId,
    ExportSectionToggles toggles,
  );

  Future<Result<ExportJob>> getExportStatus(String documentId);

  Future<Result<ExportJob>> getExport(String exportId);
}
