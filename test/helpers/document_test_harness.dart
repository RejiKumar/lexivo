import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/l10n/l10n.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/features/document_scan/document_scan.dart';
import 'package:lexivo/features/document_scan/presentation/providers/document_providers.dart';

import 'fake_document_input_source.dart';
import 'fake_document_repository.dart';

ProviderContainer createDocumentContainer({
  FakeDocumentRepository? repository,
  FakeDocumentInputSource? inputSource,
  List<Override> overrides = const [],
}) {
  final repo = repository ?? FakeDocumentRepository();
  final input = inputSource ?? FakeDocumentInputSource();
  return ProviderContainer(
    overrides: [
      documentRepositoryProvider.overrideWithValue(repo),
      documentInputSourceProvider.overrideWithValue(input),
      ...documentScanCoreOverrides(),
      ...overrides,
    ],
  );
}

Widget wrapDocumentScreen(
  Widget child, {
  List<Override> overrides = const [],
  String initialLocation = '/',
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
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
      GoRoute(
        path: '/documents/scan',
        builder: (context, state) => child,
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}
