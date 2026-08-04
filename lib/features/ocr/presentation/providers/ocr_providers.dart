import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/ocr/data/datasources/ocr_remote_datasource.dart';
import 'package:lexivo/features/ocr/data/repositories/ocr_repository_impl.dart';
import 'package:lexivo/features/ocr/domain/entities/ocr_result_view.dart';
import 'package:lexivo/features/ocr/domain/repositories/ocr_repository.dart';
import 'package:lexivo/features/ocr/domain/usecases/ocr_usecases.dart';
import 'package:lexivo/features/ocr/presentation/screens/ocr_result_screen.dart';

final ocrRemoteDatasourceProvider = Provider<OcrRemoteDatasource>((ref) {
  return OcrRemoteDatasource(ref.watch(apiClientProvider));
});

final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  return OcrRepositoryImpl(ref.watch(ocrRemoteDatasourceProvider));
});

final getOcrDocumentUseCaseProvider = Provider((ref) {
  return GetOcrDocument(ref.watch(ocrRepositoryProvider));
});

final getOcrStatusUseCaseProvider = Provider((ref) {
  return GetOcrStatus(ref.watch(ocrRepositoryProvider));
});

/// Override in tests for fast/cancelled polling.
final ocrJobPollerProvider = Provider<JobPoller>((ref) {
  return const JobPoller(
    interval: Duration(milliseconds: 50),
    timeout: Duration(seconds: 30),
  );
});

/// OCR result for a document id — polls via core [JobPoller] while processing.
final ocrResultProvider =
    AsyncNotifierProvider.family<OcrResultNotifier, OcrResultView, String>(
  OcrResultNotifier.new,
);

class OcrResultNotifier
    extends FamilyAsyncNotifier<OcrResultView, String> {
  var _generation = 0;

  @override
  Future<OcrResultView> build(String documentId) async {
    ref.onDispose(() {
      _generation++;
    });
    return _load(documentId);
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(arg));
  }

  Future<OcrResultView> _load(String documentId) async {
    final generation = ++_generation;

    final statusResult =
        await ref.read(getOcrStatusUseCaseProvider)(documentId);
    final initialStatus = statusResult.when(
      success: (s) => s,
      onFailure: (f) => throw f,
    );

    if (initialStatus == DocumentStatus.ready) {
      return _fetchReadyView(documentId);
    }
    if (initialStatus == DocumentStatus.failed) {
      throw const UnexpectedFailure(
        message: 'OCR failed. Please try again.',
      );
    }

    // processing — shared JobPoller only (no feature-local loop).
    final poller = ref.read(ocrJobPollerProvider);
    try {
      final terminal = await poller.poll<DocumentStatus>(
        fetch: () async {
          final result =
              await ref.read(getOcrStatusUseCaseProvider)(documentId);
          return result.when(
            success: (s) => s,
            onFailure: (f) => throw f,
          );
        },
        isTerminal: isOcrStatusTerminal,
        isCancelled: () => generation != _generation,
      );

      if (generation != _generation) {
        throw const JobPollerCancelled();
      }

      if (terminal == DocumentStatus.failed) {
        throw const UnexpectedFailure(
          message: 'OCR failed. Please try again.',
        );
      }
      return _fetchReadyView(documentId);
    } on JobPollerCancelled {
      rethrow;
    } on JobPollerTimeout {
      throw const UnexpectedFailure(
        message: 'OCR is taking longer than expected. Please try again.',
      );
    }
  }

  Future<OcrResultView> _fetchReadyView(String documentId) async {
    final docResult =
        await ref.read(getOcrDocumentUseCaseProvider)(documentId);
    return docResult.when(
      success: (doc) => OcrResultView.fromDocument(
        doc.copyWith(status: DocumentStatus.ready),
      ),
      onFailure: (f) => throw f,
    );
  }
}

final ocrScreenBuildersBridgeProvider = Provider<OcrScreenBuilders>((ref) {
  return (
    result: (context, documentId) => OcrResultScreen(documentId: documentId),
  );
});

/// Wire OCR routes into core GoRouter.
List<Override> ocrCoreOverrides() => [
      ocrScreenBuildersProvider.overrideWith(
        (ref) => ref.watch(ocrScreenBuildersBridgeProvider),
      ),
    ];
