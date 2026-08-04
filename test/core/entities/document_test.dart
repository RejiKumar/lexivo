import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/document_card.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/entities/document_mapper.dart';
import 'package:lexivo/core/network/api_models.dart';
import 'package:lexivo/features/document_scan/presentation/document_status_ui.dart';

void main() {
  group('Document / DocumentStatus', () {
    test('equality and copyWith', () {
      const a = Document(
        id: '1',
        userId: 'u',
        status: DocumentStatus.processing,
        title: 'A',
        extractedText: 'body',
      );
      const b = Document(
        id: '1',
        userId: 'u',
        status: DocumentStatus.processing,
        title: 'A',
        extractedText: 'body',
      );
      expect(a, b);
      expect(
        a.copyWith(status: DocumentStatus.ready).status,
        DocumentStatus.ready,
      );
      expect(
        a.copyWith(extractedText: 'new').extractedText,
        'new',
      );
    });

    test('mapper includes extractedText and summary fields from DTO', () {
      final dto = DocumentDto.fromJson({
        'id': 'doc-1',
        'user_id': 'u1',
        'title': 'T',
        'storage_key': 'k',
        'status': 'ready',
        'extracted_text': 'Hello OCR',
        'short_summary': 'Short',
        'detailed_summary': 'Detailed',
        'summary_status': 'ready',
      });
      final doc = documentFromDto(dto);
      expect(doc.extractedText, 'Hello OCR');
      expect(doc.status, DocumentStatus.ready);
      expect(doc.shortSummary, 'Short');
      expect(doc.detailedSummary, 'Detailed');
      expect(doc.summaryStatus, SummaryStatus.ready);
    });

    test('summary status API string mapping', () {
      expect(SummaryStatusApiX.fromApi('idle'), SummaryStatus.idle);
      expect(SummaryStatusApiX.fromApi('PROCESSING'), SummaryStatus.processing);
      expect(SummaryStatusApiX.fromApi('ready'), SummaryStatus.ready);
      expect(SummaryStatusApiX.fromApi('failed'), SummaryStatus.failed);
      expect(SummaryStatus.ready.apiValue, 'ready');
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
