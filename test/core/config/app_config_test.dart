import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/config/app_config.dart';

void main() {
  group('AppConfig dart-defines', () {
    test('defaults are local-safe (empty observability)', () {
      // Without --dart-define overrides, production hooks stay off.
      expect(AppConfig.apiBaseUrl, 'http://localhost:8000');
      expect(AppConfig.sentryDsn, isEmpty);
      expect(AppConfig.posthogApiKey, isEmpty);
      expect(AppConfig.sentryEnabled, isFalse);
      expect(AppConfig.posthogEnabled, isFalse);
    });

    test('API base URL is readable without network', () {
      expect(AppConfig.apiBaseUrl, startsWith('http'));
    });
  });
}
