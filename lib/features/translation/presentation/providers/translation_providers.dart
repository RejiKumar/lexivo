import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/translation/data/datasources/translation_remote_datasource.dart';
import 'package:lexivo/features/translation/data/repositories/translation_repository_impl.dart';
import 'package:lexivo/features/translation/domain/entities/translation_view.dart';
import 'package:lexivo/features/translation/domain/repositories/translation_repository.dart';
import 'package:lexivo/features/translation/domain/usecases/translation_usecases.dart';
import 'package:lexivo/features/translation/presentation/screens/translation_screen.dart';

final translationRemoteDatasourceProvider =
    Provider<TranslationRemoteDatasource>((ref) {
  return TranslationRemoteDatasource(ref.watch(apiClientProvider));
});

final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  return TranslationRepositoryImpl(
    ref.watch(translationRemoteDatasourceProvider),
  );
});

final loadTranslationUseCaseProvider = Provider((ref) {
  return LoadTranslation(ref.watch(translationRepositoryProvider));
});

final getTranslationStatusUseCaseProvider = Provider((ref) {
  return GetTranslationStatus(ref.watch(translationRepositoryProvider));
});

final requestTranslationUseCaseProvider = Provider((ref) {
  return RequestTranslation(ref.watch(translationRepositoryProvider));
});

/// Override in tests for fast/cancelled polling.
final translationJobPollerProvider = Provider<JobPoller>((ref) {
  return const JobPoller(
    interval: Duration(milliseconds: 50),
    timeout: Duration(seconds: 30),
  );
});

/// Translation result for a document id — polls via core [JobPoller] while processing.
final translationResultProvider = AsyncNotifierProvider.family<
    TranslationResultNotifier, TranslationView, String>(
  TranslationResultNotifier.new,
);

class TranslationResultNotifier
    extends FamilyAsyncNotifier<TranslationView, String> {
  var _generation = 0;

  @override
  Future<TranslationView> build(String documentId) async {
    ref.onDispose(() {
      _generation++;
    });
    return _load(documentId);
  }

  /// User-triggered translation after language selection.
  Future<void> requestTranslation({
    required String sourceLang,
    required String targetLang,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _requestAndResolve(
        arg,
        sourceLang: sourceLang,
        targetLang: targetLang,
      ),
    );
  }

  Future<void> retry({
    String? sourceLang,
    String? targetLang,
  }) async {
    final previous = state.valueOrNull;
    final source = sourceLang ?? previous?.sourceLang ?? 'en';
    final target = targetLang ?? previous?.targetLang;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (target == null || target.isEmpty) {
        return _load(arg, forceRequest: false);
      }
      return _requestAndResolve(arg, sourceLang: source, targetLang: target);
    });
  }

  Future<TranslationView> _load(
    String documentId, {
    bool forceRequest = false,
  }) async {
    final generation = ++_generation;

    final statusResult =
        await ref.read(getTranslationStatusUseCaseProvider)(documentId);
    var status = statusResult.when(
      success: (s) => s,
      onFailure: (f) => throw f,
    );

    if (status == TranslationStatus.idle && !forceRequest) {
      return _fetchView(documentId);
    }

    if (status == TranslationStatus.ready) {
      return _fetchReadyView(documentId);
    }
    if (status == TranslationStatus.failed) {
      throw const UnexpectedFailure(
        message: 'Translation failed. Please try again.',
      );
    }

    return _pollUntilReady(documentId, generation);
  }

  Future<TranslationView> _requestAndResolve(
    String documentId, {
    required String sourceLang,
    required String targetLang,
  }) async {
    final generation = ++_generation;

    final requestResult = await ref.read(requestTranslationUseCaseProvider)(
      documentId,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
    final doc = requestResult.when(
      success: (d) => d,
      onFailure: (f) => throw f,
    );

    var status = doc.translationStatus;
    if (status == TranslationStatus.ready) {
      return TranslationView.fromDocument(doc);
    }
    if (status == TranslationStatus.failed) {
      throw const UnexpectedFailure(
        message: 'Translation failed. Please try again.',
      );
    }

    return _pollUntilReady(documentId, generation);
  }

  Future<TranslationView> _pollUntilReady(
    String documentId,
    int generation,
  ) async {
    final poller = ref.read(translationJobPollerProvider);
    try {
      final terminal = await poller.poll<TranslationStatus>(
        fetch: () async {
          final result =
              await ref.read(getTranslationStatusUseCaseProvider)(documentId);
          return result.when(
            success: (s) => s,
            onFailure: (f) => throw f,
          );
        },
        isTerminal: isTranslationStatusTerminal,
        isCancelled: () => generation != _generation,
      );

      if (generation != _generation) {
        throw const JobPollerCancelled();
      }

      if (terminal == TranslationStatus.failed) {
        throw const UnexpectedFailure(
          message: 'Translation failed. Please try again.',
        );
      }
      return _fetchReadyView(documentId);
    } on JobPollerCancelled {
      rethrow;
    } on JobPollerTimeout {
      throw const UnexpectedFailure(
        message:
            'Translation is taking longer than expected. Please try again.',
      );
    }
  }

  Future<TranslationView> _fetchView(String documentId) async {
    final docResult =
        await ref.read(loadTranslationUseCaseProvider)(documentId);
    return docResult.when(
      success: TranslationView.fromDocument,
      onFailure: (f) => throw f,
    );
  }

  Future<TranslationView> _fetchReadyView(String documentId) async {
    final docResult =
        await ref.read(loadTranslationUseCaseProvider)(documentId);
    return docResult.when(
      success: (doc) => TranslationView.fromDocument(
        doc.copyWith(translationStatus: TranslationStatus.ready),
      ),
      onFailure: (f) => throw f,
    );
  }
}

final translationScreenBuildersBridgeProvider =
    Provider<TranslationScreenBuilders>((ref) {
  return (
    result: (context, documentId) =>
        TranslationScreen(documentId: documentId),
  );
});

/// Wire translation routes into core GoRouter.
List<Override> translationCoreOverrides() => [
      translationScreenBuildersProvider.overrideWith(
        (ref) => ref.watch(translationScreenBuildersBridgeProvider),
      ),
    ];
