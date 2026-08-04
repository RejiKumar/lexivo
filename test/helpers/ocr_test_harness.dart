import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/features/ocr/ocr.dart';
import 'package:lexivo/features/ocr/presentation/providers/ocr_providers.dart';

import 'fake_ocr_repository.dart';

ProviderContainer createOcrContainer({
  FakeOcrRepository? repository,
  JobPoller? poller,
  List<Override> overrides = const [],
}) {
  final repo = repository ?? FakeOcrRepository();
  return ProviderContainer(
    overrides: [
      ocrRepositoryProvider.overrideWithValue(repo),
      if (poller != null) ocrJobPollerProvider.overrideWithValue(poller),
      ...ocrCoreOverrides(),
      ...overrides,
    ],
  );
}

Widget wrapOcrScreen(
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
