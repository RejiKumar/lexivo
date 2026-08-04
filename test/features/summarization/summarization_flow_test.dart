import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/summarization/presentation/providers/summarization_providers.dart';
import 'package:lexivo/features/summarization/summarization.dart';

import '../../helpers/fake_summarization_repository.dart';

void main() {
  testWidgets('idle → POST → poll → ready shows short + detailed',
      (tester) async {
    final repo = FakeSummarizationRepository(
      initial: [
        sampleSummaryDocument(
          summaryStatus: SummaryStatus.idle,
        ),
      ],
    )
      ..requestResultStatus = SummaryStatus.processing
      ..statusSequence.addAll([
        SummaryStatus.idle,
        SummaryStatus.processing,
        SummaryStatus.ready,
      ]);

    final router = GoRouter(
      initialLocation: RouteGuards.documentSummary('doc-1'),
      routes: [
        GoRoute(
          path: '/documents/:documentId/summary',
          builder: (context, state) => SummaryScreen(
            documentId: state.pathParameters['documentId']!,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          summarizationRepositoryProvider.overrideWithValue(repo),
          summaryJobPollerProvider.overrideWithValue(
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

    expect(repo.requestCalls, greaterThanOrEqualTo(1));
    expect(find.textContaining('Lease covers'), findsOneWidget);
    expect(find.textContaining('rental term'), findsOneWidget);
  });

  testWidgets('already-ready → shows texts without request', (tester) async {
    final repo = FakeSummarizationRepository(
      initial: [sampleSummaryDocument()],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          summarizationRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SummaryScreen(documentId: 'doc-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.requestCalls, 0);
    expect(find.text('Short summary'), findsOneWidget);
    expect(find.textContaining('Lease covers'), findsOneWidget);
  });

  testWidgets('not-ready → clear error; no summary content', (tester) async {
    final repo = FakeSummarizationRepository(
      initial: [
        sampleSummaryDocument(
          summaryStatus: SummaryStatus.idle,
          shortSummary: null,
          detailedSummary: null,
        ),
      ],
    )..nextRequestFailure = const ValidationFailure(
        message: 'Document OCR is not ready',
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          summarizationRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SummaryScreen(documentId: 'doc-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('not ready'), findsOneWidget);
    expect(find.text('Short summary'), findsNothing);
  });

  testWidgets('poll failed → error + retry re-enters path', (tester) async {
    final repo = FakeSummarizationRepository(
      initial: [
        sampleSummaryDocument(
          summaryStatus: SummaryStatus.failed,
          shortSummary: null,
          detailedSummary: null,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          summarizationRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SummaryScreen(documentId: 'doc-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('failed'), findsWidgets);

    repo.requestResultStatus = SummaryStatus.ready;
    repo.documents[0] = sampleSummaryDocument(summaryStatus: SummaryStatus.idle);

    await tester.tap(find.text('Retry').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Lease covers'), findsOneWidget);
  });
}
