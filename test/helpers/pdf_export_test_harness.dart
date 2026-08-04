import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/features/pdf_export/pdf_export.dart';
import 'package:lexivo/features/pdf_export/presentation/providers/pdf_export_providers.dart';

import 'fake_pdf_export_repository.dart';

ProviderContainer createPdfExportContainer({
  FakePdfExportRepository? repository,
  JobPoller? poller,
  List<Override> overrides = const [],
}) {
  final repo = repository ?? FakePdfExportRepository();
  return ProviderContainer(
    overrides: [
      pdfExportRepositoryProvider.overrideWithValue(repo),
      if (poller != null) pdfExportJobPollerProvider.overrideWithValue(poller),
      ...pdfExportCoreOverrides(),
      ...overrides,
    ],
  );
}

Widget wrapPdfExportScreen(
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
        path: '/documents/:documentId/chat',
        builder: (context, state) => const Scaffold(
          body: Text('chat-stub'),
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
