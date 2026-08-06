import 'package:flutter/foundation.dart';
import 'package:lexivo/core/config/app_config.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Initialize PostHog when analytics is on and API key is set; otherwise no-op.
Future<bool> initPosthogIfConfigured() async {
  if (!AppConfig.posthogEnabled) {
    if (kDebugMode) {
      debugPrint(
        'PostHog skipped — set ENABLE_ANALYTICS=true and POSTHOG_API_KEY',
      );
    }
    return false;
  }

  final config = PostHogConfig(AppConfig.posthogApiKey);
  if (AppConfig.posthogHost.isNotEmpty) {
    config.host = AppConfig.posthogHost;
  }
  await Posthog().setup(config);
  return true;
}
