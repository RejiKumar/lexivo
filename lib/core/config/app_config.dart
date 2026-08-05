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

  /// Master ads switch. Default off — no AdMob init / no ad UI.
  /// Enable with `--dart-define=ENABLE_ADS=true`.
  static const bool enableAds = bool.fromEnvironment(
    'ENABLE_ADS',
    defaultValue: false,
  );

  /// When true, request child-directed treatment (no personalized ads).
  /// `--dart-define=CHILD_DIRECTED=true`.
  static const bool childDirected = bool.fromEnvironment(
    'CHILD_DIRECTED',
    defaultValue: false,
  );

  /// When true, use production ad unit IDs. Default false → Google test units.
  /// `--dart-define=ADS_USE_PRODUCTION_IDS=true`.
  static const bool adsUseProductionIds = bool.fromEnvironment(
    'ADS_USE_PRODUCTION_IDS',
    defaultValue: false,
  );

  static bool get sentryEnabled => sentryDsn.isNotEmpty;

  static bool get posthogEnabled => posthogApiKey.isNotEmpty;
}
