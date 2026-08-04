import 'package:freezed_annotation/freezed_annotation.dart';

part 'export_job.freezed.dart';

enum ExportJobStatus {
  idle,
  processing,
  ready,
  failed,
}

@freezed
abstract class ExportSectionToggles with _$ExportSectionToggles {
  const factory ExportSectionToggles({
    @Default(false) bool includeSummary,
    @Default(false) bool includeTranslation,
    @Default(false) bool includeChat,
  }) = _ExportSectionToggles;

  const ExportSectionToggles._();

  bool get anySelected =>
      includeSummary || includeTranslation || includeChat;
}

@freezed
abstract class ExportJob with _$ExportJob {
  const factory ExportJob({
    required String id,
    required String documentId,
    @Default(ExportSectionToggles()) ExportSectionToggles toggles,
    @Default(ExportJobStatus.idle) ExportJobStatus status,
    String? storageKey,
    String? signedUrl,
    String? errorMessage,
  }) = _ExportJob;

  const ExportJob._();

  bool get isReady =>
      status == ExportJobStatus.ready &&
      (signedUrl != null && signedUrl!.trim().isNotEmpty);

  bool get isFailed => status == ExportJobStatus.failed;
}
