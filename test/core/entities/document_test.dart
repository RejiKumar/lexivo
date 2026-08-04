import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/document_card.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/features/document_scan/presentation/document_status_ui.dart';

void main() {
  group('Document / DocumentStatus', () {
    test('equality and copyWith', () {
      const a = Document(
        id: '1',
        userId: 'u',
        status: DocumentStatus.processing,
        title: 'A',
      );
      const b = Document(
        id: '1',
        userId: 'u',
        status: DocumentStatus.processing,
        title: 'A',
      );
      expect(a, b);
      expect(
        a.copyWith(status: DocumentStatus.ready).status,
        DocumentStatus.ready,
      );
    });

    test('API string mapping', () {
      expect(DocumentStatusApiX.fromApi('processing'), DocumentStatus.processing);
      expect(DocumentStatusApiX.fromApi('READY'), DocumentStatus.ready);
      expect(DocumentStatusApiX.fromApi('failed'), DocumentStatus.failed);
      expect(DocumentStatusApiX.fromApi('weird'), DocumentStatus.failed);
      expect(DocumentStatus.ready.apiValue, 'ready');
    });

    test('maps to LexivoDocumentStatus', () {
      expect(
        toLexivoDocumentStatus(DocumentStatus.processing),
        LexivoDocumentStatus.processing,
      );
      expect(
        toLexivoDocumentStatus(DocumentStatus.ready),
        LexivoDocumentStatus.ready,
      );
      expect(
        toLexivoDocumentStatus(DocumentStatus.failed),
        LexivoDocumentStatus.failed,
      );
    });
  });
}
