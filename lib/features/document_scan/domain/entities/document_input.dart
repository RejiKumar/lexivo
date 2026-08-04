import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lexivo/core/utils/result.dart';

part 'document_input.freezed.dart';

/// How the caller prefers to obtain document bytes.
enum DocumentInputPreference { auto, camera, file }

/// Provenance of obtained bytes.
enum DocumentInputKind { camera, file }

/// Confirmed document bytes ready for upload.
@freezed
abstract class DocumentBytes with _$DocumentBytes {
  const factory DocumentBytes({
    required List<int> bytes,
    required String filename,
    required String mimeType,
    required DocumentInputKind source,
  }) = _DocumentBytes;
}

/// Unified camera + file input — screens must not fork on platform.
abstract class DocumentInputSource {
  Future<bool> get isCameraAvailable;

  Future<Result<DocumentBytes>> captureOrPick({
    DocumentInputPreference preference = DocumentInputPreference.auto,
  });
}
