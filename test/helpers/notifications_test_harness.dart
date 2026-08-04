import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/features/notifications/notifications.dart';

import 'fake_notifications_repository.dart';

ProviderContainer createNotificationsContainer({
  FakeNotificationsRepository? repository,
  List<Override> overrides = const [],
}) {
  final repo = repository ?? FakeNotificationsRepository();
  return ProviderContainer(
    overrides: [
      notificationsRepositoryProvider.overrideWithValue(repo),
      ...notificationsCoreOverrides(),
      ...overrides,
    ],
  );
}

Widget wrapNotificationsScreen(
  Widget child, {
  List<Override> overrides = const [],
  FakeNotificationsRepository? repository,
}) {
  final container = createNotificationsContainer(
    repository: repository,
    overrides: overrides,
  );
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.light,
      home: child,
    ),
  );
}

Widget wrapNotificationsWithRouter({
  required FakeNotificationsRepository repository,
  String initialLocation = '/notifications',
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/documents/:documentId/ocr',
        builder: (context, state) => Scaffold(
          body: Text('OCR ${state.pathParameters['documentId']}'),
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      notificationsRepositoryProvider.overrideWithValue(repository),
      ...notificationsCoreOverrides(),
      ...overrides,
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}
