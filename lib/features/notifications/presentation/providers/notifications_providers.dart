import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:lexivo/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:lexivo/features/notifications/domain/entities/app_notification.dart';
import 'package:lexivo/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:lexivo/features/notifications/domain/usecases/notifications_usecases.dart';
import 'package:lexivo/features/notifications/presentation/screens/notifications_screen.dart';

final notificationsRemoteDatasourceProvider =
    Provider<NotificationsRemoteDatasource>((ref) {
  return NotificationsRemoteDatasource(ref.watch(apiClientProvider));
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(
    ref.watch(notificationsRemoteDatasourceProvider),
  );
});

final listNotificationsUseCaseProvider = Provider((ref) {
  return ListNotifications(ref.watch(notificationsRepositoryProvider));
});

final markNotificationReadUseCaseProvider = Provider((ref) {
  return MarkNotificationRead(ref.watch(notificationsRepositoryProvider));
});

/// Inbox list — sync HTTP; no JobPoller.
final notificationsInboxProvider =
    AsyncNotifierProvider<NotificationsInboxNotifier, List<AppNotification>>(
  NotificationsInboxNotifier.new,
);

class NotificationsInboxNotifier
    extends AsyncNotifier<List<AppNotification>> {
  Failure? _markReadFailure;

  Failure? get markReadFailure => _markReadFailure;

  @override
  Future<List<AppNotification>> build() => _load();

  Future<List<AppNotification>> _load() async {
    final result = await ref.read(listNotificationsUseCaseProvider)();
    return result.when(
      success: (items) => items,
      onFailure: (f) => throw f,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> markRead(String id) async {
    _markReadFailure = null;
    final current = state.valueOrNull;
    if (current != null) {
      // Optimistic: clear unread affordance while request runs.
      state = AsyncData([
        for (final n in current)
          if (n.id == id && n.isUnread)
            n.copyWith(readAt: DateTime.now().toUtc())
          else
            n,
      ]);
    }

    final result = await ref.read(markNotificationReadUseCaseProvider)(id);
    result.when(
      success: (updated) {
        final list = state.valueOrNull ?? const <AppNotification>[];
        state = AsyncData([
          for (final n in list)
            if (n.id == updated.id) updated else n,
        ]);
      },
      onFailure: (f) {
        _markReadFailure = f;
        // Keep inbox; surface failure for snackbar / banner without wipe.
        if (current != null) {
          state = AsyncData(current);
        }
      },
    );
  }
}

final notificationsScreenBuildersBridgeProvider =
    Provider<NotificationsScreenBuilders>((ref) {
  return (
    inbox: (context) => const NotificationsScreen(),
  );
});

/// Wire notifications routes into core GoRouter.
List<Override> notificationsCoreOverrides() => [
      notificationsScreenBuildersProvider.overrideWith(
        (ref) => ref.watch(notificationsScreenBuildersBridgeProvider),
      ),
    ];
