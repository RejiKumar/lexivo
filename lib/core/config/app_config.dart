/// Compile-time / dart-define app configuration (staging vs production via env only).
library;

/// Reads release config from `--dart-define` / `--dart-define-from-file` values.
///
/// Empty observability keys = no-op. Never hardcode secrets in source.
/// AI / OCR / R2 keys belong in `backend/.env`, not Flutter dart-defines.
abstract final class AppConfig {
  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Lexivo',
  );

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static const String posthogApiKey = String.fromEnvironment('POSTHOG_API_KEY');

  static const String posthogHost = String.fromEnvironment('POSTHOG_HOST');

  /// Client hint only — server [LLM_PROVIDER] is authoritative.
  static const String aiProvider = String.fromEnvironment(
    'AI_PROVIDER',
    defaultValue: 'gemini',
  );

  /// Client hint only — server [OCR_PROVIDER] is authoritative.
  static const String ocrProvider = String.fromEnvironment(
    'OCR_PROVIDER',
    defaultValue: 'mistral',
  );

  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: false,
  );

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

  static bool get sentryEnabled =>
      enableCrashReporting && sentryDsn.isNotEmpty;

  static bool get posthogEnabled =>
      enableAnalytics && posthogApiKey.isNotEmpty;

  /// Required client-side defines for a working Debug session.
  static List<String> missingRequired() {
    final missing = <String>[];
    if (supabaseUrl.trim().isEmpty) {
      missing.add('SUPABASE_URL');
    }
    if (supabaseAnonKey.trim().isEmpty) {
      missing.add('SUPABASE_ANON_KEY');
    }
    return missing;
  }

  /// Mask a secret for debug logs (never print the full value).
  static String maskSecret(String value, {int visible = 4}) {
    final raw = value.trim();
    if (raw.isEmpty) {
      return '(not set)';
    }
    if (raw.length <= visible) {
      return '*' * raw.length;
    }
    return ('*' * (raw.length - visible)) + raw.substring(raw.length - visible);
  }

  /// Print enabled providers / masked config. Call only in debug.
  static void logStartupConfig(void Function(String message) log) {
    log('=== Lexivo Flutter startup config ===');
    log('ENV: $env');
    log('APP_NAME: $appName');
    log('API_BASE_URL: $apiBaseUrl');
    log('AI provider (hint): $aiProvider');
    log('OCR provider (hint): $ocrProvider');
    log('Supabase URL: ${supabaseUrl.isEmpty ? '(not set)' : supabaseUrl}');
    log('Supabase anon key: ${maskSecret(supabaseAnonKey)}');
    log('Ads: $enableAds');
    log('Analytics: $enableAnalytics (PostHog: $posthogEnabled)');
    log('Crash reporting: $enableCrashReporting (Sentry: $sentryEnabled)');
    log('=====================================');
  }
}
