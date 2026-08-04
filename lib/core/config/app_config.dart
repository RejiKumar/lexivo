/// Compile-time / dart-define app configuration (staging vs production via env only).
library;

/// Reads release config from `--dart-define` values. Empty observability keys = no-op.
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static const String posthogApiKey = String.fromEnvironment('POSTHOG_API_KEY');

  static const String posthogHost = String.fromEnvironment('POSTHOG_HOST');

  static bool get sentryEnabled => sentryDsn.isNotEmpty;

  static bool get posthogEnabled => posthogApiKey.isNotEmpty;
}
