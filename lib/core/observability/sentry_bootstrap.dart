import 'package:flutter/foundation.dart';
import 'package:lexivo/core/config/app_config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Initialize Sentry when crash reporting is on and DSN is set; otherwise no-op.
///
/// Safe for local/CI builds with empty DSN. Production supplies DSN via dart-define.
Future<bool> initSentryIfConfigured() async {
  if (!AppConfig.sentryEnabled) {
    if (kDebugMode) {
      debugPrint(
        'Sentry skipped — set ENABLE_CRASH_REPORTING=true and SENTRY_DSN',
      );
    }
    return false;
  }

  await SentryFlutter.init((options) {
    options.dsn = AppConfig.sentryDsn;
    options.tracesSampleRate = 0.1;
  });
  return true;
}
