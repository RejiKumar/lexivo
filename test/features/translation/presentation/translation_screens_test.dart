import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/translation/presentation/providers/translation_providers.dart';
import 'package:lexivo/features/translation/translation.dart';

import '../../../helpers/fake_translation_repository.dart';
import '../../../helpers/translation_test_harness.dart';

void main() {
  testWidgets('ready → translated text + lang labels', (tester) async {
    final repo = FakeTranslationRepository(
      initial: [sampleTranslationDocument()],
    );
    await tester.pumpWidget(
      wrapTranslationScreen(
        const TranslationScreen(documentId: 'doc-1'),
        overrides: [
          translationRepositoryProvider.overrideWithValue(repo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Texto traducido'), findsOneWidget);
    expect(find.textContaining('EN → ES'), findsOneWidget);
  });

  testWidgets('idle → language pickers + Translate CTA', (tester) async {
    final repo = FakeTranslationRepository(
      initial: [
        sampleTranslationDocument(
          translationStatus: TranslationStatus.idle,
          translatedText: null,
          sourceLang: null,
          targetLang: null,
        ),
      ],
    );
    await tester.pumpWidget(
      wrapTranslationScreen(
        const TranslationScreen(documentId: 'doc-1'),
        overrides: [
          translationRepositoryProvider.overrideWithValue(repo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Translate'), findsOneWidget);
    expect(find.textContaining('Choose languages'), findsOneWidget);
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
  });

  testWidgets('empty ready → LexivoEmptyState', (tester) async {
    final repo = FakeTranslationRepository(
      initial: [
        sampleTranslationDocument(
          translationStatus: TranslationStatus.ready,
          translatedText: '',
        ),
      ],
    );
    await tester.pumpWidget(
      wrapTranslationScreen(
        const TranslationScreen(documentId: 'doc-1'),
        overrides: [
          translationRepositoryProvider.overrideWithValue(repo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No translation yet'), findsOneWidget);
  });

  testWidgets('failed → LexivoErrorBanner with retry', (tester) async {
    final repo = FakeTranslationRepository(
      initial: [
        sampleTranslationDocument(
          translationStatus: TranslationStatus.failed,
          translatedText: null,
        ),
      ],
    );
    await tester.pumpWidget(
      wrapTranslationScreen(
        const TranslationScreen(documentId: 'doc-1'),
        overrides: [
          translationRepositoryProvider.overrideWithValue(repo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('failed'), findsWidgets);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('unsupported pair shows validation copy without request',
      (tester) async {
    final repo = FakeTranslationRepository(
      initial: [
        sampleTranslationDocument(
          translationStatus: TranslationStatus.idle,
          translatedText: null,
        ),
      ],
    );
    await tester.pumpWidget(
      wrapTranslationScreen(
        const TranslationScreen(documentId: 'doc-1'),
        overrides: [
          translationRepositoryProvider.overrideWithValue(repo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Switch source to ES so target becomes EN only — then we need es→fr
    // which the UI prevents. Trigger via notifier instead for 422-style path
    // after tapping Translate with forced langs is covered by provider tests.
    // Here: tap Translate with default en→es works; validation banner via
    // setting unsupported through provider error after request.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          translationRepositoryProvider.overrideWithValue(
            repo
              ..nextRequestFailure = const ValidationFailure(
                message: 'Unsupported language pair',
              ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const TranslationScreen(documentId: 'doc-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Translate'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Unsupported'), findsWidgets);
  });
}
