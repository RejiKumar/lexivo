import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/features/rag_chat/presentation/providers/rag_chat_providers.dart';
import 'package:lexivo/features/rag_chat/rag_chat.dart';

import 'fake_rag_chat_repository.dart';

ProviderContainer createRagChatContainer({
  FakeRagChatRepository? repository,
  List<Override> overrides = const [],
}) {
  final repo = repository ?? FakeRagChatRepository();
  return ProviderContainer(
    overrides: [
      ragChatRepositoryProvider.overrideWithValue(repo),
      ...ragChatCoreOverrides(),
      ...overrides,
    ],
  );
}

Widget wrapRagChatScreen(
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
        path: '/documents/:documentId/translation',
        builder: (context, state) => const Scaffold(
          body: Text('translation-stub'),
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
