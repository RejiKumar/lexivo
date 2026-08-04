import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/features/pdf_export/pdf_export.dart';

void main() {
  test('pdf_export barrel exports public surface', () {
    expect(pdfExportProvider, isNotNull);
    expect(pdfExportCoreOverrides, isNotNull);
    expect(PdfExportScreen, isNotNull);
    expect(ExportJobStatus.ready, isNotNull);
  });
}
