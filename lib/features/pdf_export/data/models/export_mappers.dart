import 'package:lexivo/core/network/api_models.dart';
import 'package:lexivo/features/pdf_export/domain/entities/export_job.dart';

ExportJobStatus exportStatusFromString(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'idle':
      return ExportJobStatus.idle;
    case 'processing':
      return ExportJobStatus.processing;
    case 'ready':
      return ExportJobStatus.ready;
    case 'failed':
      return ExportJobStatus.failed;
    default:
      return ExportJobStatus.idle;
  }
}

ExportJob exportJobFromDto(ExportStatusDto dto) {
  return ExportJob(
    id: dto.id,
    documentId: dto.documentId,
    toggles: ExportSectionToggles(
      includeSummary: dto.includeSummary,
      includeTranslation: dto.includeTranslation,
      includeChat: dto.includeChat,
    ),
    status: exportStatusFromString(dto.exportStatus),
    storageKey: dto.storageKey,
    signedUrl: dto.signedUrl,
    errorMessage: dto.errorMessage,
  );
}
