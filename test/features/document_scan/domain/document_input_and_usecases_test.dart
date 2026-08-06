import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/document_scan/data/input/document_input_source_impl.dart';
import 'package:lexivo/features/document_scan/data/input/input_gateways.dart';
import 'package:lexivo/features/document_scan/domain/entities/document_input.dart';
import 'package:lexivo/features/document_scan/domain/usecases/document_usecases.dart';

import '../../../helpers/fake_document_input_source.dart';
import '../../../helpers/fake_document_repository.dart';

class _FakeCamera implements CameraGateway {
  _FakeCamera({this.available = true});

  bool available;
  var captureCount = 0;

  @override
  Future<bool> get isAvailable async => available;

  @override
  Future<Result<RawDocumentCapture>> capture() async {
    captureCount++;
    return Result.success(
      const RawDocumentCapture(
        bytes: [9, 9],
        filename: 'cam.jpg',
        mimeType: 'image/jpeg',
        path: '/tmp/cam.jpg',
      ),
    );
  }
}

class _FakeGallery implements GalleryGateway {
  var pickCount = 0;

  @override
  Future<Result<RawDocumentCapture>> pick() async {
    pickCount++;
    return Result.success(
      const RawDocumentCapture(
        bytes: [1, 2, 3],
        filename: 'gallery.jpg',
        mimeType: 'image/jpeg',
        path: '/tmp/gallery.jpg',
      ),
    );
  }
}

class _FakeFiles implements FilePickerGateway {
  var pickCount = 0;

  @override
  Future<Result<RawDocumentCapture>> pick() async {
    pickCount++;
    return Result.success(
      const RawDocumentCapture(
        bytes: [37, 80, 68, 70],
        filename: 'doc.pdf',
        mimeType: 'application/pdf',
      ),
    );
  }
}

class _FakeCropper implements DocumentCropper {
  var cropCount = 0;

  @override
  Future<Result<List<int>>> crop({
    required List<int> bytes,
    required String filename,
    String? path,
  }) async {
    cropCount++;
    return Result.success([...bytes, 0]);
  }
}

void main() {
  group('DocumentInputSourceImpl', () {
    test('camera available → camera bytes after crop', () async {
      final camera = _FakeCamera(available: true);
      final gallery = _FakeGallery();
      final files = _FakeFiles();
      final cropper = _FakeCropper();
      final source = DocumentInputSourceImpl(
        camera: camera,
        gallery: gallery,
        files: files,
        cropper: cropper,
      );

      final result = await source.captureOrPick();
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.source, DocumentInputKind.camera);
      expect(cropper.cropCount, 1);
      expect(files.pickCount, 0);
      expect(gallery.pickCount, 0);
      expect(result.valueOrNull?.bytes, [9, 9, 0]);
    });

    test('camera unavailable → gallery bytes after crop', () async {
      final camera = _FakeCamera(available: false);
      final gallery = _FakeGallery();
      final files = _FakeFiles();
      final cropper = _FakeCropper();
      final source = DocumentInputSourceImpl(
        camera: camera,
        gallery: gallery,
        files: files,
        cropper: cropper,
      );

      final result = await source.captureOrPick();
      expect(result.valueOrNull?.source, DocumentInputKind.gallery);
      expect(gallery.pickCount, 1);
      expect(files.pickCount, 0);
      expect(cropper.cropCount, 1);
    });

    test('file preference → PDF skips crop', () async {
      final camera = _FakeCamera(available: true);
      final gallery = _FakeGallery();
      final files = _FakeFiles();
      final cropper = _FakeCropper();
      final source = DocumentInputSourceImpl(
        camera: camera,
        gallery: gallery,
        files: files,
        cropper: cropper,
      );

      final result = await source.captureOrPick(
        preference: DocumentInputPreference.file,
      );
      expect(result.valueOrNull?.source, DocumentInputKind.file);
      expect(files.pickCount, 1);
      expect(cropper.cropCount, 0);
    });

    test('preference never requires UI platform fork', () async {
      final fake = FakeDocumentInputSource(cameraAvailable: false);
      await fake.captureOrPick(preference: DocumentInputPreference.auto);
      expect(fake.lastPreference, DocumentInputPreference.auto);
      expect(fake.captureCalls, 1);
    });
  });

  group('usecases', () {
    test('ObtainDocumentInput / UploadDocument / ListDocuments', () async {
      final repo = FakeDocumentRepository();
      final input = FakeDocumentInputSource();
      final obtain = ObtainDocumentInput(input);
      final upload = UploadDocument(repo);
      final list = ListDocuments(repo);

      final bytes = await obtain();
      expect(bytes.isSuccess, isTrue);

      final created = await upload(
        bytes: bytes.valueOrNull!.bytes,
        filename: bytes.valueOrNull!.filename,
        title: 'Lease',
      );
      expect(created.isSuccess, isTrue);

      final docs = await list();
      expect(docs.valueOrNull, isNotEmpty);
    });
  });
}
