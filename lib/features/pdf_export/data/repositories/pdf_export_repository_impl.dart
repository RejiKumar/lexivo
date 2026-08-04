import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/pdf_export/data/datasources/pdf_export_remote_datasource.dart';
import 'package:lexivo/features/pdf_export/domain/entities/export_job.dart';
import 'package:lexivo/features/pdf_export/domain/repositories/pdf_export_repository.dart';

class PdfExportRepositoryImpl implements PdfExportRepository {
  PdfExportRepositoryImpl(this._remote);

  final PdfExportRemoteDatasource _remote;

  @override
  Future<Result<ExportJob>> requestExport(
    String documentId,
    ExportSectionToggles toggles,
  ) =>
      _remote.requestExport(documentId, toggles);

  @override
  Future<Result<ExportJob>> getExportStatus(String documentId) =>
      _remote.getExportStatus(documentId);

  @override
  Future<Result<ExportJob>> getExport(String exportId) =>
      _remote.getExport(exportId);
}
