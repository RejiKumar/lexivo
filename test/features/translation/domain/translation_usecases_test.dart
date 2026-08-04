import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/translation/domain/usecases/translation_usecases.dart';
import 'package:lexivo/features/translation/translation.dart';

import '../../../helpers/fake_translation_repository.dart';

void main() {
  group('translation usecases', () {
    test('LoadTranslation returns document', () async {
      final repo = FakeTranslationRepository(
        initial: [sampleTranslationDocument()],
      );
      final result = await LoadTranslation(repo)('doc-1');
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.translatedText, contains('Texto traducido'));
    });

    test('RequestTranslation success path', () async {
      final repo = FakeTranslationRepository(
        initial: [
          sampleTranslationDocument(
            translationStatus: TranslationStatus.idle,
            translatedText: null,
          ),
        ],
      )..requestResultStatus = TranslationStatus.processing;

      final result = await RequestTranslation(repo)(
        'doc-1',
        sourceLang: 'en',
        targetLang: 'es',
      );
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.translationStatus, TranslationStatus.processing);
      expect(repo.requestCalls, 1);
    });

    test('RequestTranslation rejects unsupported pair without calling repo',
        () async {
      final repo = FakeTranslationRepository(
        initial: [sampleTranslationDocument()],
      );
      final result = await RequestTranslation(repo)(
        'doc-1',
        sourceLang: 'es',
        targetLang: 'fr',
      );
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(repo.requestCalls, 0);
    });

    test('GetTranslationStatus + terminal helper', () async {
      final repo = FakeTranslationRepository(
        initial: [sampleTranslationDocument()],
      );
      final result = await GetTranslationStatus(repo)('doc-1');
      expect(result.valueOrNull, TranslationStatus.ready);
      expect(isTranslationStatusTerminal(TranslationStatus.ready), isTrue);
      expect(isTranslationStatusTerminal(TranslationStatus.failed), isTrue);
      expect(isTranslationStatusTerminal(TranslationStatus.processing), isFalse);
      expect(isTranslationStatusTerminal(TranslationStatus.idle), isFalse);
    });

    test('isSupportedTranslationPair EN↔targets', () {
      expect(isSupportedTranslationPair('en', 'es'), isTrue);
      expect(isSupportedTranslationPair('hi', 'en'), isTrue);
      expect(isSupportedTranslationPair('en', 'en'), isFalse);
      expect(isSupportedTranslationPair('es', 'fr'), isFalse);
      expect(isSupportedTranslationPair('en', 'zh'), isFalse);
      expect(supportedTranslationLangs, containsAll(['en', 'es', 'fr', 'de', 'hi', 'pt']));
    });
  });
}
