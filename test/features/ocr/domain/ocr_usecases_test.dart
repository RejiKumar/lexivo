import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/ocr/domain/entities/ocr_result_view.dart';
import 'package:lexivo/features/ocr/domain/usecases/ocr_usecases.dart';

import '../../../helpers/fake_ocr_repository.dart';

void main() {
  group('OCR usecases', () {
    test('GetOcrDocument success / failure', () async {
      final repo = FakeOcrRepository(
        initial: [sampleOcrDocument()],
      );
      final get = GetOcrDocument(repo);

      final ok = await get('doc-1');
      expect(ok.isSuccess, isTrue);
      expect(ok.valueOrNull?.extractedText, contains('Extracted OCR'));

      repo.nextFailure = const UnexpectedFailure(message: 'boom');
      final fail = await get('doc-1');
      expect(fail.isFailure, isTrue);
    });

    test('GetOcrStatus success / failure', () async {
      final repo = FakeOcrRepository(
        initial: [
          sampleOcrDocument(status: DocumentStatus.processing),
        ],
      );
      final getStatus = GetOcrStatus(repo);

      final ok = await getStatus('doc-1');
      expect(ok.valueOrNull, DocumentStatus.processing);

      repo.nextFailure = const NetworkFailure(message: 'down');
      final fail = await getStatus('doc-1');
      expect(fail.isFailure, isTrue);
    });

    test('isOcrStatusTerminal: ready/failed terminal; processing not', () {
      expect(isOcrStatusTerminal(DocumentStatus.ready), isTrue);
      expect(isOcrStatusTerminal(DocumentStatus.failed), isTrue);
      expect(isOcrStatusTerminal(DocumentStatus.processing), isFalse);
    });
  });

  group('OcrResultView', () {
    test('fromDocument and hasExtractedText', () {
      final withText = OcrResultView.fromDocument(sampleOcrDocument());
      expect(withText.hasExtractedText, isTrue);

      final empty = OcrResultView.fromDocument(
        sampleOcrDocument(extractedText: '   '),
      );
      expect(empty.hasExtractedText, isFalse);
    });
  });
}
