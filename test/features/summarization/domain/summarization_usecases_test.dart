import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/features/summarization/domain/entities/summary_view.dart';
import 'package:lexivo/features/summarization/domain/usecases/summarization_usecases.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';

import '../../../helpers/fake_summarization_repository.dart';

void main() {
  group('Summarization usecases', () {
    test('LoadSummary / GetSummaryStatus / RequestSummary success', () async {
      final repo = FakeSummarizationRepository(
        initial: [sampleSummaryDocument()],
      );
      final load = await LoadSummary(repo)('doc-1');
      expect(load.isSuccess, isTrue);
      expect(load.valueOrNull?.shortSummary, contains('Lease covers'));

      final status = await GetSummaryStatus(repo)('doc-1');
      expect(status.valueOrNull, SummaryStatus.ready);

      final request = await RequestSummary(repo)('doc-1');
      expect(request.isSuccess, isTrue);
      expect(repo.requestCalls, 1);
    });

    test('RequestSummary surfaces not-ready ValidationFailure', () async {
      final repo = FakeSummarizationRepository(
        initial: [
          sampleSummaryDocument(summaryStatus: SummaryStatus.idle),
        ],
      )..nextRequestFailure = const ValidationFailure(
          message: 'Document OCR is not ready',
        );

      final result = await RequestSummary(repo)('doc-1');
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('isSummaryStatusTerminal', () {
      expect(isSummaryStatusTerminal(SummaryStatus.ready), isTrue);
      expect(isSummaryStatusTerminal(SummaryStatus.failed), isTrue);
      expect(isSummaryStatusTerminal(SummaryStatus.processing), isFalse);
      expect(isSummaryStatusTerminal(SummaryStatus.idle), isFalse);
    });

    test('SummaryView.fromDocument', () {
      final view = SummaryView.fromDocument(sampleSummaryDocument());
      expect(view.hasSummaries, isTrue);
      expect(view.shortSummary, isNotEmpty);
      expect(view.detailedSummary, isNotEmpty);
    });
  });
}
