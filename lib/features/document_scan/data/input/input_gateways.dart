import 'package:lexivo/core/utils/result.dart';

/// Raw capture/pick before optional crop.
class RawDocumentCapture {
  const RawDocumentCapture({
    required this.bytes,
    required this.filename,
    required this.mimeType,
    this.path,
  });

  final List<int> bytes;
  final String filename;
  final String mimeType;

  /// Local filesystem path when available (mobile cropper); null on web memory picks.
  final String? path;

  bool get isPdf =>
      mimeType == 'application/pdf' ||
      filename.toLowerCase().endsWith('.pdf');

  bool get isImage =>
      mimeType.startsWith('image/') ||
      filename.toLowerCase().endsWith('.jpg') ||
      filename.toLowerCase().endsWith('.jpeg') ||
      filename.toLowerCase().endsWith('.png');
}

/// Camera capability + capture (plugin-backed in data layer).
abstract class CameraGateway {
  Future<bool> get isAvailable;

  Future<Result<RawDocumentCapture>> capture();
}

/// Device photo gallery / media library pick (images).
abstract class GalleryGateway {
  Future<Result<RawDocumentCapture>> pick();
}

/// File picker for images/PDFs.
abstract class FilePickerGateway {
  Future<Result<RawDocumentCapture>> pick();
}

/// MVP interactive crop (or pass-through when unavailable).
abstract class DocumentCropper {
  Future<Result<List<int>>> crop({
    required List<int> bytes,
    required String filename,
    String? path,
  });
}
