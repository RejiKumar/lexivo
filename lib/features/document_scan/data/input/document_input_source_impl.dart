import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/document_scan/domain/entities/document_input.dart';
import 'package:lexivo/features/document_scan/data/input/input_gateways.dart';

/// Concrete [DocumentInputSource] wrapping gateways + MVP cropper.
///
/// Crop: camera path always crops images; file path crops images only;
/// PDFs skip crop. See `docs/document_input_source.md`.
class DocumentInputSourceImpl implements DocumentInputSource {
  DocumentInputSourceImpl({
    required CameraGateway camera,
    required FilePickerGateway files,
    required DocumentCropper cropper,
  })  : _camera = camera,
        _files = files,
        _cropper = cropper;

  final CameraGateway _camera;
  final FilePickerGateway _files;
  final DocumentCropper _cropper;

  @override
  Future<bool> get isCameraAvailable => _camera.isAvailable;

  @override
  Future<Result<DocumentBytes>> captureOrPick({
    DocumentInputPreference preference = DocumentInputPreference.auto,
  }) async {
    switch (preference) {
      case DocumentInputPreference.file:
        return _fromFile();
      case DocumentInputPreference.camera:
        return _fromCamera();
      case DocumentInputPreference.auto:
        final cam = await isCameraAvailable;
        return cam ? _fromCamera() : _fromFile();
    }
  }

  Future<Result<DocumentBytes>> _fromCamera() async {
    final capture = await _camera.capture();
    return capture.when(
      success: (raw) => _finalize(raw, DocumentInputKind.camera, crop: true),
      onFailure: Result.failure,
    );
  }

  Future<Result<DocumentBytes>> _fromFile() async {
    final pick = await _files.pick();
    return pick.when(
      success: (raw) => _finalize(
        raw,
        DocumentInputKind.file,
        crop: raw.isImage && !raw.isPdf,
      ),
      onFailure: Result.failure,
    );
  }

  Future<Result<DocumentBytes>> _finalize(
    RawDocumentCapture raw,
    DocumentInputKind source, {
    required bool crop,
  }) async {
    var bytes = raw.bytes;
    if (crop) {
      final cropped = await _cropper.crop(
        bytes: raw.bytes,
        filename: raw.filename,
        path: raw.path,
      );
      final failure = cropped.failureOrNull;
      if (failure != null) return Result.failure(failure);
      bytes = cropped.valueOrNull ?? raw.bytes;
    }
    return Result.success(
      DocumentBytes(
        bytes: bytes,
        filename: raw.filename,
        mimeType: raw.mimeType,
        source: source,
      ),
    );
  }
}
