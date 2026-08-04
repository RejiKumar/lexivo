import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/translation/presentation/providers/translation_providers.dart';
import 'package:lexivo/features/translation/translation.dart';

import '../../helpers/fake_translation_repository.dart';

void main() {
  testWidgets('idle → select langs → POST → poll → ready shows text',
      (tester) async {
    final repo = FakeTranslationRepository(
      initial: [
        sampleTranslationDocument(
          translationStatus: TranslationStatus.idle,
          translatedText: 'Texto traducido del contrato de arrendamiento.',
          sourceLang: null,
          targetLang: null,
        ),
      ],
    )..requestResultStatus = TranslationStatus.processing;

    final router = GoRouter(
      initialLocation: RouteGuards.documentTranslation('doc-1'),
      routes: [
        GoRoute(
          path: '/documents/:documentId/translation',
          builder: (context, state) => TranslationScreen(
            documentId: state.pathParameters['documentId']!,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          translationRepositoryProvider.overrideWithValue(repo),
          translationJobPollerProvider.overrideWithValue(
            const JobPoller(
              interval: Duration(milliseconds: 10),
              timeout: Duration(seconds: 2),
            ),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(repo.requestCalls, 0);
    expect(find.text('Translate'), findsOneWidget);

    repo.statusSequence.addAll([
      TranslationStatus.processing,
      TranslationStatus.ready,
    ]);

    await tester.tap(find.text('Translate'));
    await tester.pumpAndSettle();

    expect(repo.requestCalls, greaterThanOrEqualTo(1));
    expect(find.textContaining('Texto traducido'), findsOneWidget);
  });

  testWidgets('already-ready → shows text without request', (tester) async {
    final repo = FakeTranslationRepository(
      initial: [sampleTranslationDocument()],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          translationRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const TranslationScreen(documentId: 'doc-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.requestCalls, 0);
    expect(find.textContaining('Texto traducido'), findsOneWidget);
  });

  testWidgets('not-ready → clear error; no translation content', (tester) async {
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          translationRepositoryProvider.overrideWithValue(repo),
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

    expect(find.textContaining('not ready'), findsOneWidget);
    expect(find.textContaining('Texto traducido'), findsNothing);
  });

  testWidgets('poll failed → error + retry re-enters path', (tester) async {
    final repo = FakeTranslationRepository(
      initial: [
        sampleTranslationDocument(
          translationStatus: TranslationStatus.failed,
          translatedText: null,
          sourceLang: 'en',
          targetLang: 'es',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          translationRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const TranslationScreen(documentId: 'doc-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('failed'), findsWidgets);

    repo.requestResultStatus = TranslationStatus.ready;
    repo.documents[0] = sampleTranslationDocument(
      translationStatus: TranslationStatus.idle,
    );

    await tester.tap(find.text('Retry').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Texto traducido'), findsOneWidget);
  });
}
