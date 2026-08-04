import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/features/ocr/ocr.dart';

void main() {
  test('barrel exports OCR result screen and providers', () {
    expect(OcrResultScreen, isNotNull);
    expect(ocrResultProvider, isNotNull);
    expect(ocrCoreOverrides(), isNotEmpty);
    expect(OcrResultView, isNotNull);
  });
}
