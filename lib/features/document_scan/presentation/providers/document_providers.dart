import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/document_scan/data/datasources/document_remote_datasource.dart';
import 'package:lexivo/features/document_scan/data/input/document_input_source_impl.dart';
import 'package:lexivo/features/document_scan/data/input/plugin_gateways.dart';
import 'package:lexivo/features/document_scan/data/repositories/document_repository_impl.dart';
import 'package:lexivo/features/document_scan/domain/entities/document_input.dart';
import 'package:lexivo/features/document_scan/domain/repositories/document_repository.dart';
import 'package:lexivo/features/document_scan/domain/usecases/document_usecases.dart';
import 'package:lexivo/features/document_scan/presentation/screens/document_library_screen.dart';
import 'package:lexivo/features/document_scan/presentation/screens/document_scan_screen.dart';

final documentRemoteDatasourceProvider =
    Provider<DocumentRemoteDatasource>((ref) {
  return DocumentRemoteDatasource(ref.watch(apiClientProvider));
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl(ref.watch(documentRemoteDatasourceProvider));
});

final documentInputSourceProvider = Provider<DocumentInputSource>((ref) {
  return DocumentInputSourceImpl(
    camera: ImagePickerCameraGateway(),
    gallery: ImagePickerGalleryGateway(),
    files: FilePickerGatewayImpl(),
    cropper: ImageCropperDocumentCropper(),
  );
});

final listDocumentsUseCaseProvider = Provider((ref) {
  return ListDocuments(ref.watch(documentRepositoryProvider));
});

final uploadDocumentUseCaseProvider = Provider((ref) {
  return UploadDocument(ref.watch(documentRepositoryProvider));
});

final obtainDocumentInputUseCaseProvider = Provider((ref) {
  return ObtainDocumentInput(ref.watch(documentInputSourceProvider));
});

final getDocumentStatusUseCaseProvider = Provider((ref) {
  return GetDocumentStatus(ref.watch(documentRepositoryProvider));
});

/// Override in tests for fast/cancelled polling.
final documentJobPollerProvider = Provider<JobPoller>((ref) {
  return const JobPoller(
    interval: Duration(milliseconds: 50),
    timeout: Duration(seconds: 30),
  );
});

/// Library list — empty list is valid data.
final documentLibraryProvider =
    AsyncNotifierProvider<DocumentLibraryNotifier, List<Document>>(
  DocumentLibraryNotifier.new,
);

class DocumentLibraryNotifier extends AsyncNotifier<List<Document>> {
  @override
  Future<List<Document>> build() => _load();

  Future<List<Document>> _load() async {
    final result = await ref.read(listDocumentsUseCaseProvider)();
    return result.when(
      success: (docs) => docs,
      onFailure: (f) => throw f,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  void upsert(Document document) {
    final current = state.valueOrNull ?? const <Document>[];
    final without = current.where((d) => d.id != document.id).toList();
    state = AsyncData([document, ...without]);
  }

  void updateStatus(String id, DocumentStatus status) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData([
      for (final d in current)
        if (d.id == id) d.copyWith(status: status) else d,
    ]);
  }
}

/// Scan / upload flow controller.
class DocumentScanState {
  const DocumentScanState({
    this.isLoading = false,
    this.failure,
    this.lastUploaded,
  });

  final bool isLoading;
  final Failure? failure;
  final Document? lastUploaded;

  DocumentScanState copyWith({
    bool? isLoading,
    Failure? failure,
    Document? lastUploaded,
    bool clearFailure = false,
    bool clearUploaded = false,
  }) {
    return DocumentScanState(
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      lastUploaded:
          clearUploaded ? null : (lastUploaded ?? this.lastUploaded),
    );
  }
}

class DocumentScanController extends StateNotifier<DocumentScanState> {
  DocumentScanController(this._ref) : super(const DocumentScanState());

  final Ref _ref;
  var _pollGeneration = 0;

  Future<Result<Document>> startScan({
    DocumentInputPreference preference = DocumentInputPreference.auto,
    String? title,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final input = await _ref.read(obtainDocumentInputUseCaseProvider)(
      preference: preference,
    );
    final inputFailure = input.failureOrNull;
    if (inputFailure != null) {
      state = DocumentScanState(failure: inputFailure);
      return Result.failure(inputFailure);
    }
    final bytes = input.valueOrNull!;
    final upload = await _ref.read(uploadDocumentUseCaseProvider)(
      bytes: bytes.bytes,
      filename: bytes.filename,
      title: title,
    );
    return upload.when(
      success: (doc) {
        state = DocumentScanState(lastUploaded: doc);
        _ref.read(documentLibraryProvider.notifier).upsert(doc);
        if (doc.status == DocumentStatus.processing) {
          _startPolling(doc.id);
        }
        return Result.success(doc);
      },
      onFailure: (f) {
        state = DocumentScanState(failure: f);
        return Result.failure(f);
      },
    );
  }

  void _startPolling(String documentId) {
    final generation = ++_pollGeneration;
    final poller = _ref.read(documentJobPollerProvider);
    poller
        .poll<DocumentStatus>(
      fetch: () async {
        final result =
            await _ref.read(getDocumentStatusUseCaseProvider)(documentId);
        return result.when(
          success: (s) => s,
          onFailure: (f) => throw f,
        );
      },
      isTerminal: (s) =>
          s == DocumentStatus.ready || s == DocumentStatus.failed,
      isCancelled: () => generation != _pollGeneration,
      onTick: (s) {
        if (generation != _pollGeneration) return;
        _ref.read(documentLibraryProvider.notifier).updateStatus(documentId, s);
      },
    )
        .then((s) {
      if (generation != _pollGeneration) return;
      _ref.read(documentLibraryProvider.notifier).updateStatus(documentId, s);
    }).catchError((_) {
      // Timeout / cancel — leave last known status.
    });
  }

  void cancelPolling() {
    _pollGeneration++;
  }

  @override
  void dispose() {
    cancelPolling();
    super.dispose();
  }
}

final documentScanControllerProvider =
    StateNotifierProvider<DocumentScanController, DocumentScanState>((ref) {
  return DocumentScanController(ref);
});

final documentScreenBuildersBridgeProvider =
    Provider<DocumentScreenBuilders>((ref) {
  return (
    library: (_) => const DocumentLibraryScreen(),
    scan: (_) => const DocumentScanScreen(),
  );
});

/// Wire document routes into core GoRouter.
List<Override> documentScanCoreOverrides() => [
      documentScreenBuildersProvider.overrideWith(
        (ref) => ref.watch(documentScreenBuildersBridgeProvider),
      ),
    ];
