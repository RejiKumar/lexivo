import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/l10n/l10n.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/splash/splash_screen.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/features/auth/auth.dart';
import 'package:lexivo/features/auth/presentation/providers/auth_providers.dart';

import 'fake_auth_repository.dart';

ProviderContainer createAuthContainer({
  FakeAuthRepository? repository,
  List<Override> overrides = const [],
}) {
  final repo = repository ?? FakeAuthRepository();
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      splashMinDurationProvider.overrideWithValue(Duration.zero),
      ...authCoreOverrides(),
      ...overrides,
    ],
  );
}

Widget pumpAuthApp({
  required FakeAuthRepository repository,
  String initialLocation = RouteGuards.home,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      splashMinDurationProvider.overrideWithValue(Duration.zero),
      ...authCoreOverrides(),
      ...overrides,
    ],
    child: const LexivoRouterApp(),
  );
}

/// Minimal themed host for feature widget tests.
Widget wrapAuthScreen(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

Dio createTestDio({String baseUrl = 'http://localhost'}) {
  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: const {
        Headers.contentTypeHeader: Headers.jsonContentType,
        Headers.acceptHeader: Headers.jsonContentType,
      },
    ),
  );
}

Future<void> settleAuth(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

extension GoRouterTestX on WidgetTester {
  GoRouter routerOf(ProviderContainer container) {
    return container.read(goRouterProvider);
  }
}
