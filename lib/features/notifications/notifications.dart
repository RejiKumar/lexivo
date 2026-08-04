/// Notifications feature public surface — ONLY import allowed outside this feature.
library;

export 'presentation/providers/notifications_providers.dart'
    show
        notificationsInboxProvider,
        notificationsRepositoryProvider,
        notificationsCoreOverrides,
        NotificationsInboxNotifier;
export 'presentation/screens/notifications_screen.dart';
export 'domain/entities/app_notification.dart';
