import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/features/translation/presentation/providers/translation_providers.dart';
import 'package:lexivo/features/translation/translation.dart';

import 'fake_translation_repository.dart';

ProviderContainer createTranslationContainer({
  FakeTranslationRepository? repository,
  JobPoller? poller,
  List<Override> overrides = const [],
}) {
  final repo = repository ?? FakeTranslationRepository();
  return ProviderContainer(
    overrides: [
      translationRepositoryProvider.overrideWithValue(repo),
      if (poller != null)
        translationJobPollerProvider.overrideWithValue(poller),
      ...translationCoreOverrides(),
      ...overrides,
    ],
  );
}

Widget wrapTranslationScreen(
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
        path: '/documents/:documentId/summary',
        builder: (context, state) => const Scaffold(
          body: Text('summary-stub'),
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
