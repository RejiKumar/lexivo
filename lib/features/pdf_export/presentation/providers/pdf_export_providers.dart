import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/pdf_export/data/datasources/pdf_export_remote_datasource.dart';
import 'package:lexivo/features/pdf_export/data/repositories/pdf_export_repository_impl.dart';
import 'package:lexivo/features/pdf_export/domain/entities/export_job.dart';
import 'package:lexivo/features/pdf_export/domain/repositories/pdf_export_repository.dart';
import 'package:lexivo/features/pdf_export/domain/usecases/pdf_export_usecases.dart';
import 'package:lexivo/features/pdf_export/presentation/screens/pdf_export_screen.dart';

final pdfExportRemoteDatasourceProvider =
    Provider<PdfExportRemoteDatasource>((ref) {
  return PdfExportRemoteDatasource(ref.watch(apiClientProvider));
});

final pdfExportRepositoryProvider = Provider<PdfExportRepository>((ref) {
  return PdfExportRepositoryImpl(
    ref.watch(pdfExportRemoteDatasourceProvider),
  );
});

final requestPdfExportUseCaseProvider = Provider((ref) {
  return RequestPdfExport(ref.watch(pdfExportRepositoryProvider));
});

final getExportStatusUseCaseProvider = Provider((ref) {
  return GetExportStatus(ref.watch(pdfExportRepositoryProvider));
});

/// Override in tests for fast/cancelled polling.
final pdfExportJobPollerProvider = Provider<JobPoller>((ref) {
  return const JobPoller(
    interval: Duration(milliseconds: 50),
    timeout: Duration(seconds: 30),
  );
});

/// Export job state for a document id — polls via core [JobPoller] while processing.
final pdfExportProvider =
    AsyncNotifierProvider.family<PdfExportNotifier, ExportJob?, String>(
  PdfExportNotifier.new,
);

class PdfExportNotifier extends FamilyAsyncNotifier<ExportJob?, String> {
  var _generation = 0;
  ExportSectionToggles _lastToggles = const ExportSectionToggles(
    includeSummary: true,
  );

  ExportSectionToggles get lastToggles => _lastToggles;

  @override
  Future<ExportJob?> build(String documentId) async {
    ref.onDispose(() {
      _generation++;
    });
    return _loadExisting(documentId);
  }

  Future<void> requestExport(ExportSectionToggles toggles) async {
    _lastToggles = toggles;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _requestAndResolve(arg, toggles));
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _requestAndResolve(arg, _lastToggles),
    );
  }

  Future<ExportJob?> _loadExisting(String documentId) async {
    final generation = ++_generation;
    final result = await ref.read(getExportStatusUseCaseProvider)(documentId);
    return result.when(
      success: (job) async {
        _lastToggles = job.toggles;
        if (job.status == ExportJobStatus.processing) {
          return _pollUntilReady(documentId, generation);
        }
        if (job.status == ExportJobStatus.failed) {
          throw UnexpectedFailure(
            message: job.errorMessage?.trim().isNotEmpty == true
                ? job.errorMessage!
                : 'Export failed. Please try again.',
          );
        }
        return job;
      },
      onFailure: (f) {
        // No prior export is fine — idle UI with toggles.
        final msg = f.message.toLowerCase();
        if (msg.contains('not found') || msg.contains('404')) {
          return null;
        }
        throw f;
      },
    );
  }

  Future<ExportJob> _requestAndResolve(
    String documentId,
    ExportSectionToggles toggles,
  ) async {
    final generation = ++_generation;
    final requestResult =
        await ref.read(requestPdfExportUseCaseProvider)(documentId, toggles);
    final job = requestResult.when(
      success: (j) => j,
      onFailure: (f) => throw f,
    );

    if (job.status == ExportJobStatus.ready) {
      return job;
    }
    if (job.status == ExportJobStatus.failed) {
      throw UnexpectedFailure(
        message: job.errorMessage?.trim().isNotEmpty == true
            ? job.errorMessage!
            : 'Export failed. Please try again.',
      );
    }
    return _pollUntilReady(documentId, generation);
  }

  Future<ExportJob> _pollUntilReady(
    String documentId,
    int generation,
  ) async {
    final poller = ref.read(pdfExportJobPollerProvider);
    try {
      final terminal = await poller.poll<ExportJob>(
        fetch: () async {
          final result =
              await ref.read(getExportStatusUseCaseProvider)(documentId);
          return result.when(
            success: (j) => j,
            onFailure: (f) => throw f,
          );
        },
        isTerminal: (job) => isExportStatusTerminal(job.status),
        isCancelled: () => generation != _generation,
      );

      if (generation != _generation) {
        throw const JobPollerCancelled();
      }

      if (terminal.status == ExportJobStatus.failed) {
        throw UnexpectedFailure(
          message: terminal.errorMessage?.trim().isNotEmpty == true
              ? terminal.errorMessage!
              : 'Export failed. Please try again.',
        );
      }
      return terminal;
    } on JobPollerCancelled {
      rethrow;
    } on JobPollerTimeout {
      throw const UnexpectedFailure(
        message: 'Export is taking longer than expected. Please try again.',
      );
    }
  }
}

final pdfExportScreenBuildersBridgeProvider =
    Provider<PdfExportScreenBuilders>((ref) {
  return (
    result: (context, documentId) =>
        PdfExportScreen(documentId: documentId),
  );
});

/// Wire pdf_export routes into core GoRouter.
List<Override> pdfExportCoreOverrides() => [
      pdfExportScreenBuildersProvider.overrideWith(
        (ref) => ref.watch(pdfExportScreenBuildersBridgeProvider),
      ),
    ];
