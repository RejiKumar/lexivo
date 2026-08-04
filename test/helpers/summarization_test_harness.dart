import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/features/summarization/presentation/providers/summarization_providers.dart';
import 'package:lexivo/features/summarization/summarization.dart';

import 'fake_summarization_repository.dart';

ProviderContainer createSummarizationContainer({
  FakeSummarizationRepository? repository,
  JobPoller? poller,
  List<Override> overrides = const [],
}) {
  final repo = repository ?? FakeSummarizationRepository();
  return ProviderContainer(
    overrides: [
      summarizationRepositoryProvider.overrideWithValue(repo),
      if (poller != null) summaryJobPollerProvider.overrideWithValue(poller),
      ...summarizationCoreOverrides(),
      ...overrides,
    ],
  );
}

Widget wrapSummaryScreen(
  Widget child, {
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => child,
      ),
      GoRoute(
        path: '/documents/:documentId/ocr',
        builder: (context, state) => const Scaffold(
          body: Text('ocr-stub'),
        ),
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) => const Scaffold(
          body: Text('library-stub'),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}
