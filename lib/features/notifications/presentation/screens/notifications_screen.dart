import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/components/badge.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/widgets/async_value_view.dart';
import 'package:lexivo/features/notifications/domain/entities/app_notification.dart';
import 'package:lexivo/features/notifications/presentation/providers/notifications_providers.dart';

/// In-app notifications inbox — Lexivo* + AsyncValueView only.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(notificationsInboxProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LexivoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Notifications', style: LexivoTypography.headline),
              const SizedBox(height: LexivoSpacing.md),
              Expanded(
                child: AsyncValueView<List<AppNotification>>(
                  value: inbox,
                  onRetry: () =>
                      ref.read(notificationsInboxProvider.notifier).refresh(),
                  builder: (context, items) {
                    if (items.isEmpty) {
                      return const LexivoEmptyState(
                        title: 'No notifications yet',
                        description:
                            'You will see updates here when processing finishes.',
                        icon: Icons.notifications_none_outlined,
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => ref
                          .read(notificationsInboxProvider.notifier)
                          .refresh(),
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: LexivoSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _NotificationRow(
                            notification: item,
                            onTap: () => _onTap(context, ref, item),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification item,
  ) async {
    if (item.isUnread) {
      await ref.read(notificationsInboxProvider.notifier).markRead(item.id);
    }
    final docId = item.documentId;
    if (docId != null && context.mounted) {
      context.go(RouteGuards.documentOcr(docId));
    }
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = notification.isUnread
        ? LexivoTypography.title
        : LexivoTypography.body;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LexivoSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: titleStyle),
                  const SizedBox(height: LexivoSpacing.xs),
                  Text(notification.body, style: LexivoTypography.body),
                  if (notification.createdAt != null) ...[
                    const SizedBox(height: LexivoSpacing.xs),
                    Text(
                      _formatTime(notification.createdAt!),
                      style: LexivoTypography.caption,
                    ),
                  ],
                ],
              ),
            ),
            if (notification.isUnread) ...[
              const SizedBox(width: LexivoSpacing.sm),
              const LexivoBadge(
                label: 'New',
                variant: LexivoBadgeVariant.warning,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime at) {
    final local = at.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}
