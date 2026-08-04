import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/translation/domain/entities/translation_view.dart';
import 'package:lexivo/features/translation/presentation/providers/translation_providers.dart';

import '../../../helpers/fake_translation_repository.dart';
import '../../../helpers/translation_test_harness.dart';

void main() {
  test('ready document → AsyncValue data with translated text + langs',
      () async {
    final repo = FakeTranslationRepository(
      initial: [sampleTranslationDocument()],
    );
    final container = createTranslationContainer(repository: repo);
    addTearDown(container.dispose);

    final view = await container.read(translationResultProvider('doc-1').future);
    expect(view.translatedText, contains('Texto traducido'));
    expect(view.sourceLang, 'en');
    expect(view.targetLang, 'es');
    expect(repo.requestCalls, 0);
  });

  test('idle → load without auto-request; request then poll', () async {
    final repo = FakeTranslationRepository(
      initial: [
        sampleTranslationDocument(
          translationStatus: TranslationStatus.idle,
          translatedText: null,
          sourceLang: null,
          targetLang: null,
        ),
      ],
    )
      ..requestResultStatus = TranslationStatus.processing
      ..statusSequence.addAll([
        TranslationStatus.idle,
        TranslationStatus.processing,
        TranslationStatus.ready,
      ]);

    final container = createTranslationContainer(
      repository: repo,
      poller: const JobPoller(
        interval: Duration(milliseconds: 10),
        timeout: Duration(seconds: 2),
      ),
    );
    addTearDown(container.dispose);

    final idle = await container.read(translationResultProvider('doc-1').future);
    expect(idle.translationStatus, TranslationStatus.idle);
    expect(repo.requestCalls, 0);

    // Reset status sequence for poll after request
    repo.statusCalls = 0;
    repo.statusSequence
      ..clear()
      ..addAll([
        TranslationStatus.processing,
        TranslationStatus.ready,
      ]);
    repo.documents[0] = sampleTranslationDocument(
      translationStatus: TranslationStatus.idle,
      translatedText: 'Texto traducido del contrato de arrendamiento.',
    );

    await container
        .read(translationResultProvider('doc-1').notifier)
        .requestTranslation(sourceLang: 'en', targetLang: 'es');
    final view = await container.read(translationResultProvider('doc-1').future);
    expect(repo.requestCalls, greaterThanOrEqualTo(1));
    expect(view.hasTranslation, isTrue);
  });

  test('processing → poll until ready', () async {
    final repo = FakeTranslationRepository(
      initial: [
        sampleTranslationDocument(
          translationStatus: TranslationStatus.processing,
        ),
      ],
    )..statusSequence.addAll([
        TranslationStatus.processing,
        TranslationStatus.processing,
        TranslationStatus.ready,
      ]);

    final container = createTranslationContainer(
      repository: repo,
      poller: const JobPoller(
        interval: Duration(milliseconds: 10),
        timeout: Duration(seconds: 2),
      ),
    );
    addTearDown(container.dispose);

    final view = await container.read(translationResultProvider('doc-1').future);
    expect(repo.requestCalls, 0);
    expect(view.translatedText, isNotEmpty);
  });

  test('409 not-ready → error without polling', () async {
    final repo = FakeTranslationRepository(
      initial: [
        sampleTranslationDocument(
          translationStatus: TranslationStatus.idle,
          translatedText: null,
        ),
      ],
    )..nextRequestFailure = const ValidationFailure(
        message: 'Document OCR is not ready',
      );

    final container = createTranslationContainer(repository: repo);
    addTearDown(container.dispose);

    await container.read(translationResultProvider('doc-1').future);
    await expectLater(
      container
          .read(translationResultProvider('doc-1').notifier)
          .requestTranslation(sourceLang: 'en', targetLang: 'es'),
      completes,
    );
    final state = container.read(translationResultProvider('doc-1'));
    expect(state, isA<AsyncError<TranslationView>>());
    expect(state.error, isA<ValidationFailure>());
    expect(repo.statusCalls, lessThan(3));
  });

  test('unsupported lang → validation without polling', () async {
    final repo = FakeTranslationRepository(
      initial: [
        sampleTranslationDocument(translationStatus: TranslationStatus.idle),
      ],
    );
    final container = createTranslationContainer(repository: repo);
    addTearDown(container.dispose);

    await container.read(translationResultProvider('doc-1').future);
    await container
        .read(translationResultProvider('doc-1').notifier)
        .requestTranslation(sourceLang: 'es', targetLang: 'fr');
    final state = container.read(translationResultProvider('doc-1'));
    expect(state, isA<AsyncError<TranslationView>>());
    expect(state.error, isA<ValidationFailure>());
    expect(repo.requestCalls, 0);
  });

  test('dispose cancels polling', () async {
    final repo = FakeTranslationRepository(
      initial: [
        sampleTranslationDocument(
          translationStatus: TranslationStatus.processing,
          translatedText: null,
        ),
      ],
    )..statusSequence.addAll([
        TranslationStatus.processing,
        TranslationStatus.processing,
        TranslationStatus.processing,
      ]);

    final container = createTranslationContainer(
      repository: repo,
      poller: const JobPoller(
        interval: Duration(milliseconds: 20),
        timeout: Duration(seconds: 5),
      ),
    );

    final future = container.read(translationResultProvider('doc-1').future);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    container.dispose();

    await expectLater(future, throwsA(isA<JobPollerCancelled>()));
  });
}
