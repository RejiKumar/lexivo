import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/pdf_export/domain/usecases/pdf_export_usecases.dart';
import 'package:lexivo/features/pdf_export/pdf_export.dart';

import '../../helpers/fake_pdf_export_repository.dart';

void main() {
  late FakePdfExportRepository repo;

  setUp(() {
    repo = FakePdfExportRepository();
  });

  test('RequestPdfExport rejects empty toggles', () async {
    final result = await RequestPdfExport(repo)(
      'doc-1',
      const ExportSectionToggles(),
    );
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
    expect(repo.requestCalls, 0);
  });

  test('RequestPdfExport success', () async {
    final result = await RequestPdfExport(repo)(
      'doc-1',
      const ExportSectionToggles(includeSummary: true),
    );
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.status, ExportJobStatus.processing);
    expect(repo.lastRequestToggles?.includeSummary, isTrue);
  });

  test('RequestPdfExport surfaces 409 ValidationFailure', () async {
    repo.nextRequestFailure = const ValidationFailure(
      message: 'Summary is not ready',
    );
    final result = await RequestPdfExport(repo)(
      'doc-1',
      const ExportSectionToggles(includeSummary: true),
    );
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message, contains('not ready'));
  });

  test('GetExportStatus returns ready signedUrl', () async {
    repo.latest = sampleExportJob();
    final result = await GetExportStatus(repo)('doc-1');
    expect(result.valueOrNull?.isReady, isTrue);
    expect(result.valueOrNull?.signedUrl, contains('signed.test'));
  });

  test('failed job exposes error for retry', () async {
    repo.latest = sampleExportJob(status: ExportJobStatus.failed)
        .copyWith(errorMessage: 'PDF boom', signedUrl: null);
    final result = await GetExportStatus(repo)('doc-1');
    expect(result.valueOrNull?.isFailed, isTrue);
    expect(result.valueOrNull?.errorMessage, 'PDF boom');
  });

  test('isExportStatusTerminal', () {
    expect(isExportStatusTerminal(ExportJobStatus.ready), isTrue);
    expect(isExportStatusTerminal(ExportJobStatus.failed), isTrue);
    expect(isExportStatusTerminal(ExportJobStatus.processing), isFalse);
  });
}
