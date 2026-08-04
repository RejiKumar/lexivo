import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/document_scan/domain/entities/document_input.dart';
import 'package:lexivo/features/document_scan/presentation/providers/document_providers.dart';

import '../../../helpers/document_test_harness.dart';
import '../../../helpers/fake_document_input_source.dart';
import '../../../helpers/fake_document_repository.dart';

void main() {
  test('library loads list; empty is valid', () async {
    final empty = createDocumentContainer(
      repository: FakeDocumentRepository(initial: []),
    );
    addTearDown(empty.dispose);
    final docs = await empty.read(documentLibraryProvider.future);
    expect(docs, isEmpty);

    final filled = createDocumentContainer(
      repository: FakeDocumentRepository(
        initial: [sampleDocument()],
      ),
    );
    addTearDown(filled.dispose);
    final listed = await filled.read(documentLibraryProvider.future);
    expect(listed.single.id, 'doc-1');
  });

  test('scan flow uploads without corrupting library on later failure', () async {
    final repo = FakeDocumentRepository(initial: [sampleDocument()]);
    final input = FakeDocumentInputSource();
    final container = createDocumentContainer(
      repository: repo,
      inputSource: input,
    );
    addTearDown(container.dispose);

    await container.read(documentLibraryProvider.future);
    final ok = await container
        .read(documentScanControllerProvider.notifier)
        .startScan();
    expect(ok.isSuccess, isTrue);
    expect(container.read(documentLibraryProvider).valueOrNull, isNotEmpty);

    repo.nextFailure = const NetworkFailure(message: 'boom');
    final fail = await container
        .read(documentScanControllerProvider.notifier)
        .startScan(preference: DocumentInputPreference.file);
    expect(fail.isFailure, isTrue);
    expect(
      container.read(documentLibraryProvider).valueOrNull?.any((d) => d.id == 'doc-1'),
      isTrue,
    );
  });

  test('status poll updates card status processing → ready', () async {
    final repo = FakeDocumentRepository(initial: []);
    repo.createdStatus = DocumentStatus.processing;
    repo.statusSequence.addAll([
      DocumentStatus.processing,
      DocumentStatus.ready,
    ]);
    final input = FakeDocumentInputSource();
    final container = createDocumentContainer(
      repository: repo,
      inputSource: input,
      overrides: [
        documentJobPollerProvider.overrideWithValue(
          const JobPoller(
            interval: Duration(milliseconds: 1),
            timeout: Duration(seconds: 2),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(documentLibraryProvider.future);
    await container.read(documentScanControllerProvider.notifier).startScan();
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final statuses = container
          .read(documentLibraryProvider)
          .valueOrNull
          ?.map((d) => d.status);
      if (statuses?.contains(DocumentStatus.ready) == true) break;
    }
    container.read(documentScanControllerProvider.notifier).cancelPolling();
    final statuses =
        container.read(documentLibraryProvider).valueOrNull?.map((d) => d.status);
    expect(statuses?.contains(DocumentStatus.ready), isTrue);
  });
}
