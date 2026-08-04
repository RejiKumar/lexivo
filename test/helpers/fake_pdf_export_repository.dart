import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/pdf_export/domain/entities/export_job.dart';
import 'package:lexivo/features/pdf_export/domain/repositories/pdf_export_repository.dart';

class FakePdfExportRepository implements PdfExportRepository {
  FakePdfExportRepository({ExportJob? initial}) : latest = initial;

  ExportJob? latest;
  Failure? nextFailure;
  Failure? nextRequestFailure;
  Failure? nextStatusFailure;
  final List<ExportJobStatus> statusSequence = [];
  var statusCalls = 0;
  var requestCalls = 0;
  ExportSectionToggles? lastRequestToggles;

  ExportJobStatus requestResultStatus = ExportJobStatus.processing;
  String? readySignedUrl = 'https://signed.test/exports/doc-1/exp-1.pdf';

  @override
  Future<Result<ExportJob>> requestExport(
    String documentId,
    ExportSectionToggles toggles,
  ) async {
    requestCalls++;
    lastRequestToggles = toggles;
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
    final job = ExportJob(
      id: 'exp-${requestCalls}',
      documentId: documentId,
      toggles: toggles,
      status: requestResultStatus,
      signedUrl: requestResultStatus == ExportJobStatus.ready
          ? readySignedUrl
          : null,
      storageKey: requestResultStatus == ExportJobStatus.ready
          ? 'exports/$documentId/exp-$requestCalls.pdf'
          : null,
    );
    latest = job;
    return Result.success(job);
  }

  @override
  Future<Result<ExportJob>> getExportStatus(String documentId) async {
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
      final status = statusSequence[index];
      final base = latest ??
          ExportJob(
            id: 'exp-1',
            documentId: documentId,
            toggles: const ExportSectionToggles(includeSummary: true),
          );
      final job = base.copyWith(
        status: status,
        signedUrl:
            status == ExportJobStatus.ready ? readySignedUrl : base.signedUrl,
        storageKey: status == ExportJobStatus.ready
            ? (base.storageKey ?? 'exports/$documentId/exp-1.pdf')
            : base.storageKey,
        errorMessage:
            status == ExportJobStatus.failed ? 'PDF generation failed' : null,
      );
      latest = job;
      return Result.success(job);
    }
    if (latest == null) {
      return Result.failure(
        const NetworkFailure(message: 'Export not found'),
      );
    }
    return Result.success(latest!);
  }

  @override
  Future<Result<ExportJob>> getExport(String exportId) async {
    if (latest == null || latest!.id != exportId) {
      return Result.failure(
        const NetworkFailure(message: 'Export not found'),
      );
    }
    return Result.success(latest!);
  }
}

ExportJob sampleExportJob({
  String id = 'exp-1',
  String documentId = 'doc-1',
  ExportJobStatus status = ExportJobStatus.ready,
  bool includeSummary = true,
  bool includeTranslation = false,
  bool includeChat = false,
  String? signedUrl = 'https://signed.test/exports/doc-1/exp-1.pdf',
}) {
  return ExportJob(
    id: id,
    documentId: documentId,
    toggles: ExportSectionToggles(
      includeSummary: includeSummary,
      includeTranslation: includeTranslation,
      includeChat: includeChat,
    ),
    status: status,
    signedUrl: status == ExportJobStatus.ready ? signedUrl : null,
    storageKey:
        status == ExportJobStatus.ready ? 'exports/$documentId/$id.pdf' : null,
  );
}
