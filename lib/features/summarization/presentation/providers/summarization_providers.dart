import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/summarization/data/datasources/summarization_remote_datasource.dart';
import 'package:lexivo/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:lexivo/features/summarization/domain/entities/summary_view.dart';
import 'package:lexivo/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:lexivo/features/summarization/domain/usecases/summarization_usecases.dart';
import 'package:lexivo/features/summarization/presentation/screens/summary_screen.dart';

final summarizationRemoteDatasourceProvider =
    Provider<SummarizationRemoteDatasource>((ref) {
  return SummarizationRemoteDatasource(ref.watch(apiClientProvider));
});

final summarizationRepositoryProvider = Provider<SummarizationRepository>((ref) {
  return SummarizationRepositoryImpl(
    ref.watch(summarizationRemoteDatasourceProvider),
  );
});

final loadSummaryUseCaseProvider = Provider((ref) {
  return LoadSummary(ref.watch(summarizationRepositoryProvider));
});

final getSummaryStatusUseCaseProvider = Provider((ref) {
  return GetSummaryStatus(ref.watch(summarizationRepositoryProvider));
});

final requestSummaryUseCaseProvider = Provider((ref) {
  return RequestSummary(ref.watch(summarizationRepositoryProvider));
});

/// Override in tests for fast/cancelled polling.
final summaryJobPollerProvider = Provider<JobPoller>((ref) {
  return const JobPoller(
    interval: Duration(milliseconds: 50),
    timeout: Duration(seconds: 30),
  );
});

/// Summary result for a document id — polls via core [JobPoller] while processing.
final summaryResultProvider =
    AsyncNotifierProvider.family<SummaryResultNotifier, SummaryView, String>(
  SummaryResultNotifier.new,
);

class SummaryResultNotifier
    extends FamilyAsyncNotifier<SummaryView, String> {
  var _generation = 0;

  @override
  Future<SummaryView> build(String documentId) async {
    ref.onDispose(() {
      _generation++;
    });
    return _load(documentId);
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(arg, forceRequest: true));
  }

  Future<SummaryView> _load(
    String documentId, {
    bool forceRequest = false,
  }) async {
    final generation = ++_generation;

    final statusResult =
        await ref.read(getSummaryStatusUseCaseProvider)(documentId);
    var status = statusResult.when(
      success: (s) => s,
      onFailure: (f) => throw f,
    );

    if (forceRequest || status == SummaryStatus.idle) {
      final requestResult =
          await ref.read(requestSummaryUseCaseProvider)(documentId);
      final doc = requestResult.when(
        success: (d) => d,
        onFailure: (f) => throw f,
      );
      status = doc.summaryStatus;
      if (status == SummaryStatus.ready) {
        return SummaryView.fromDocument(doc);
      }
      if (status == SummaryStatus.failed) {
        throw const UnexpectedFailure(
          message: 'Summarization failed. Please try again.',
        );
      }
    }

    if (status == SummaryStatus.ready) {
      return _fetchReadyView(documentId);
    }
    if (status == SummaryStatus.failed) {
      throw const UnexpectedFailure(
        message: 'Summarization failed. Please try again.',
      );
    }

    // processing — shared JobPoller only (no feature-local loop).
    final poller = ref.read(summaryJobPollerProvider);
    try {
      final terminal = await poller.poll<SummaryStatus>(
        fetch: () async {
          final result =
              await ref.read(getSummaryStatusUseCaseProvider)(documentId);
          return result.when(
            success: (s) => s,
            onFailure: (f) => throw f,
          );
        },
        isTerminal: isSummaryStatusTerminal,
        isCancelled: () => generation != _generation,
      );

      if (generation != _generation) {
        throw const JobPollerCancelled();
      }

      if (terminal == SummaryStatus.failed) {
        throw const UnexpectedFailure(
          message: 'Summarization failed. Please try again.',
        );
      }
      return _fetchReadyView(documentId);
    } on JobPollerCancelled {
      rethrow;
    } on JobPollerTimeout {
      throw const UnexpectedFailure(
        message:
            'Summarization is taking longer than expected. Please try again.',
      );
    }
  }

  Future<SummaryView> _fetchReadyView(String documentId) async {
    final docResult =
        await ref.read(loadSummaryUseCaseProvider)(documentId);
    return docResult.when(
      success: (doc) => SummaryView.fromDocument(
        doc.copyWith(summaryStatus: SummaryStatus.ready),
      ),
      onFailure: (f) => throw f,
    );
  }
}

final summaryScreenBuildersBridgeProvider =
    Provider<SummaryScreenBuilders>((ref) {
  return (
    result: (context, documentId) =>
        SummaryScreen(documentId: documentId),
  );
});

/// Wire summary routes into core GoRouter.
List<Override> summarizationCoreOverrides() => [
      summaryScreenBuildersProvider.overrideWith(
        (ref) => ref.watch(summaryScreenBuildersBridgeProvider),
      ),
    ];
