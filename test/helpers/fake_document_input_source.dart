import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/document_scan/domain/entities/document_input.dart';

class FakeDocumentInputSource implements DocumentInputSource {
  FakeDocumentInputSource({
    this.cameraAvailable = true,
    this.cameraBytes,
    this.galleryBytes,
    this.fileBytes,
    this.forceCropInvoked = false,
  });

  bool cameraAvailable;
  DocumentBytes? cameraBytes;
  DocumentBytes? galleryBytes;
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
    switch (preference) {
      case DocumentInputPreference.camera:
        if (!cameraAvailable) {
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
      case DocumentInputPreference.gallery:
      case DocumentInputPreference.auto when !cameraAvailable:
        cropInvocations++;
        forceCropInvoked = true;
        return Result.success(
          galleryBytes ??
              const DocumentBytes(
                bytes: [4, 5, 6],
                filename: 'gallery.jpg',
                mimeType: 'image/jpeg',
                source: DocumentInputKind.gallery,
              ),
        );
      case DocumentInputPreference.auto:
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
      case DocumentInputPreference.file:
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
}
