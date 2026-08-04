import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/translation/domain/repositories/translation_repository.dart';

import 'fake_document_repository.dart';

class FakeTranslationRepository implements TranslationRepository {
  FakeTranslationRepository({List<Document>? initial})
      : documents = List<Document>.from(initial ?? const []);

  final List<Document> documents;
  Failure? nextFailure;
  Failure? nextStatusFailure;
  Failure? nextRequestFailure;
  final List<TranslationStatus> statusSequence = [];
  var statusCalls = 0;
  var getCalls = 0;
  var requestCalls = 0;

  /// Status applied after [requestTranslation] (default processing for poll paths).
  TranslationStatus requestResultStatus = TranslationStatus.processing;

  @override
  Future<Result<Document>> getDocument(String id) async {
    getCalls++;
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return Result.failure(f);
    }
    final doc = documents.cast<Document?>().firstWhere(
          (d) => d?.id == id,
          orElse: () => null,
        );
    if (doc == null) {
      return Result.failure(const UnexpectedFailure(message: 'Not found'));
    }
    return Result.success(doc);
  }

  @override
  Future<Result<TranslationStatus>> getTranslationStatus(String id) async {
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
      if (status == TranslationStatus.ready) {
        final di = documents.indexWhere((d) => d.id == id);
        if (di >= 0) {
          final current = documents[di];
          documents[di] = current.copyWith(
            translationStatus: TranslationStatus.ready,
            translatedText: (current.translatedText?.trim().isNotEmpty ?? false)
                ? current.translatedText
                : 'Texto traducido del contrato de arrendamiento.',
          );
        }
      }
      return Result.success(status);
    }
    final doc = documents.cast<Document?>().firstWhere(
          (d) => d?.id == id,
          orElse: () => null,
        );
    return Result.success(doc?.translationStatus ?? TranslationStatus.failed);
  }

  @override
  Future<Result<Document>> requestTranslation(
    String id, {
    required String sourceLang,
    required String targetLang,
  }) async {
    requestCalls++;
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
    final index = documents.indexWhere((d) => d.id == id);
    if (index < 0) {
      return Result.failure(const UnexpectedFailure(message: 'Not found'));
    }
    final current = documents[index];
    final updated = current.copyWith(
      translationStatus: requestResultStatus,
      sourceLang: sourceLang,
      targetLang: targetLang,
      translatedText: requestResultStatus == TranslationStatus.ready
          ? (current.translatedText ??
              'Texto traducido del contrato de arrendamiento.')
          : current.translatedText,
    );
    documents[index] = updated;
    return Result.success(updated);
  }
}

Document sampleTranslationDocument({
  String id = 'doc-1',
  DocumentStatus status = DocumentStatus.ready,
  TranslationStatus translationStatus = TranslationStatus.ready,
  String? title = 'Sample',
  String? extractedText = 'Extracted OCR body from the lease agreement.',
  String? translatedText = 'Texto traducido del contrato de arrendamiento.',
  String? sourceLang = 'en',
  String? targetLang = 'es',
}) {
  return sampleDocument(
    id: id,
    status: status,
    title: title,
    extractedText: extractedText,
    translatedText: translatedText,
    sourceLang: sourceLang,
    targetLang: targetLang,
    translationStatus: translationStatus,
  );
}
