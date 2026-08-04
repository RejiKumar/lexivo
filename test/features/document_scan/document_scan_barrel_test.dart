import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/features/document_scan/document_scan.dart';

void main() {
  test('barrel exports screens, providers, DocumentInputSource', () {
    expect(DocumentLibraryScreen, isNotNull);
    expect(DocumentScanScreen, isNotNull);
    expect(documentLibraryProvider, isNotNull);
    expect(documentScanControllerProvider, isNotNull);
    expect(documentScanCoreOverrides(), isNotEmpty);
    // Domain contract exported
    expect(DocumentInputPreference.auto, isNotNull);
    expect(DocumentInputKind.camera, isNotNull);
  });
}
