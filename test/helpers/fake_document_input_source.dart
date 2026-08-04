import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/document_scan/domain/entities/document_input.dart';

class FakeDocumentInputSource implements DocumentInputSource {
  FakeDocumentInputSource({
    this.cameraAvailable = true,
    this.cameraBytes,
    this.fileBytes,
    this.forceCropInvoked = false,
  });

  bool cameraAvailable;
  DocumentBytes? cameraBytes;
  DocumentBytes? fileBytes;
  bool forceCropInvoked;

  var captureCalls = 0;
  var cropInvocations = 0;
  DocumentInputPreference? lastPreference;

  @override
  Future<bool> get isCameraAvailable async => cameraAvailable;

  @override
  Future<Result<DocumentBytes>> captureOrPick({
    DocumentInputPreference preference = DocumentInputPreference.auto,
  }) async {
    lastPreference = preference;
    captureCalls++;
    final useCamera = switch (preference) {
      DocumentInputPreference.camera => true,
      DocumentInputPreference.file => false,
      DocumentInputPreference.auto => cameraAvailable,
    };

    if (useCamera) {
      if (!cameraAvailable && preference == DocumentInputPreference.camera) {
        return Result.failure(
          const UnexpectedFailure(message: 'Camera unavailable'),
        );
      }
      cropInvocations++;
      forceCropInvoked = true;
      return Result.success(
        cameraBytes ??
            const DocumentBytes(
              bytes: [1, 2, 3],
              filename: 'capture.jpg',
              mimeType: 'image/jpeg',
              source: DocumentInputKind.camera,
            ),
      );
    }

    return Result.success(
      fileBytes ??
          const DocumentBytes(
            bytes: [37, 80, 68, 70],
            filename: 'upload.pdf',
            mimeType: 'application/pdf',
            source: DocumentInputKind.file,
          ),
    );
  }
}
