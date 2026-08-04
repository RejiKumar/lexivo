import 'package:flutter/foundation.dart';
import 'package:lexivo/core/config/app_config.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Initialize PostHog when [AppConfig.posthogApiKey] is non-empty; otherwise no-op.
Future<bool> initPosthogIfConfigured() async {
  if (!AppConfig.posthogEnabled) {
    if (kDebugMode) {
      debugPrint('PostHog skipped — POSTHOG_API_KEY empty');
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
