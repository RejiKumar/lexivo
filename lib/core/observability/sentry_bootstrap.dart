import 'package:flutter/foundation.dart';
import 'package:lexivo/core/config/app_config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Initialize Sentry when [AppConfig.sentryDsn] is non-empty; otherwise no-op.
///
/// Safe for local/CI builds with empty DSN. Production supplies DSN via dart-define.
Future<bool> initSentryIfConfigured() async {
  if (!AppConfig.sentryEnabled) {
    if (kDebugMode) {
      debugPrint('Sentry skipped — SENTRY_DSN empty');
    }
    return false;
  }

  await SentryFlutter.init((options) {
    options.dsn = AppConfig.sentryDsn;
    options.tracesSampleRate = 0.1;
  });
  return true;
}
