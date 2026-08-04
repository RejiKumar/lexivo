import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/network/api_models.dart';

/// Maps network DTOs → shared [Document] entity.
Document documentFromDto(DocumentDto dto) {
  return Document(
    id: dto.id,
    userId: dto.userId,
    title: dto.title,
    storageKey: dto.storageKey,
    status: DocumentStatusApiX.fromApi(dto.status),
    extractedText: dto.extractedText,
    shortSummary: dto.shortSummary,
    detailedSummary: dto.detailedSummary,
    summaryStatus: SummaryStatusApiX.fromApi(dto.summaryStatus),
    translatedText: dto.translatedText,
    sourceLang: dto.sourceLang,
    targetLang: dto.targetLang,
    translationStatus: TranslationStatusApiX.fromApi(dto.translationStatus),
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
  );
}

DocumentStatus documentStatusFromDto(DocumentStatusDto dto) {
  return DocumentStatusApiX.fromApi(dto.status);
}

SummaryStatus summaryStatusFromDto(SummaryStatusDto dto) {
  return SummaryStatusApiX.fromApi(dto.summaryStatus);
}

TranslationStatus translationStatusFromDto(TranslationStatusDto dto) {
  return TranslationStatusApiX.fromApi(dto.translationStatus);
}
