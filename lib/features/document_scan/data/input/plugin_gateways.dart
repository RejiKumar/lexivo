import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/document_scan/data/input/input_gateways.dart';

/// Camera via `image_picker`. Availability can be overridden for probes/tests.
class ImagePickerCameraGateway implements CameraGateway {
  ImagePickerCameraGateway({
    ImagePicker? picker,
    this._availabilityProbe,
  })  : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  final Future<bool> Function()? _availabilityProbe;

  @override
  Future<bool> get isAvailable async {
    if (_availabilityProbe != null) return _availabilityProbe();
    // Default: assume camera path is attemptable; capture maps failures.
    return true;
  }

  @override
  Future<Result<RawDocumentCapture>> capture() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 92,
      );
      if (file == null) {
        return Result.failure(
          const ValidationFailure(message: 'Camera capture cancelled'),
        );
      }
      final bytes = await file.readAsBytes();
      final name = file.name.isNotEmpty ? file.name : 'capture.jpg';
      final path = file.path.isNotEmpty ? file.path : null;
      return Result.success(
        RawDocumentCapture(
          bytes: bytes,
          filename: name,
          mimeType: _mimeFor(name),
          path: path,
        ),
      );
    } catch (e) {
      return Result.failure(
        UnexpectedFailure(message: 'Camera unavailable', cause: e),
      );
    }
  }

  String _mimeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }
}

/// Gallery via `image_picker` — preferred path for photos on Android/iOS.
class ImagePickerGalleryGateway implements GalleryGateway {
  ImagePickerGalleryGateway({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Result<RawDocumentCapture>> pick() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (file == null) {
        return Result.failure(
          const ValidationFailure(message: 'Gallery pick cancelled'),
        );
      }
      final bytes = await file.readAsBytes();
      final name = file.name.isNotEmpty ? file.name : 'gallery.jpg';
      final path = file.path.isNotEmpty ? file.path : null;
      return Result.success(
        RawDocumentCapture(
          bytes: bytes,
          filename: name,
          mimeType: _mimeFor(name),
          path: path,
        ),
      );
    } catch (e) {
      return Result.failure(
        UnexpectedFailure(message: 'Gallery unavailable', cause: e),
      );
    }
  }

  String _mimeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }
}

class FilePickerGatewayImpl implements FilePickerGateway {
  @override
  Future<Result<RawDocumentCapture>> pick() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return Result.failure(
          const ValidationFailure(message: 'File pick cancelled'),
        );
      }
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        return Result.failure(
          const UnexpectedFailure(message: 'Could not read selected file'),
        );
      }
      final name = file.name;
      final path = file.path;
      return Result.success(
        RawDocumentCapture(
          bytes: bytes,
          filename: name,
          mimeType: _mimeFor(name),
          path: path,
        ),
      );
    } catch (e) {
      return Result.failure(
        UnexpectedFailure(message: 'File picker failed', cause: e),
      );
    }
  }

  String _mimeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }
}

/// MVP crop via `image_cropper` when a filesystem [path] exists; else pass-through.
///
/// Full ML edge-detect is out of scope — see `docs/document_input_source.md`.
class ImageCropperDocumentCropper implements DocumentCropper {
  ImageCropperDocumentCropper({ImageCropper? cropper})
      : _cropper = cropper ?? ImageCropper();

  final ImageCropper _cropper;

  @override
  Future<Result<List<int>>> crop({
    required List<int> bytes,
    required String filename,
    String? path,
  }) async {
    if (path == null || path.isEmpty) {
      return Result.success(bytes);
    }
    try {
      final cropped = await _cropper.cropImage(sourcePath: path);
      if (cropped == null) {
        return Result.failure(
          const ValidationFailure(message: 'Crop cancelled'),
        );
      }
      return Result.success(await cropped.readAsBytes());
    } catch (_) {
      return Result.success(bytes);
    }
  }
}

/// Always returns input bytes (tests / platforms without crop UI).
class PassThroughDocumentCropper implements DocumentCropper {
  const PassThroughDocumentCropper();

  @override
  Future<Result<List<int>>> crop({
    required List<int> bytes,
    required String filename,
    String? path,
  }) async =>
      Result.success(bytes);
}
