import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/config/app_config.dart';

void main() {
  group('AppConfig dart-defines', () {
    test('defaults are safe for local / CI without secrets', () {
      expect(AppConfig.apiBaseUrl, 'http://localhost:8000');
      expect(AppConfig.sentryDsn, isEmpty);
      expect(AppConfig.posthogApiKey, isEmpty);
      expect(AppConfig.sentryEnabled, isFalse);
      expect(AppConfig.posthogEnabled, isFalse);
      expect(AppConfig.enableAds, isFalse);
      expect(AppConfig.childDirected, isFalse);
      expect(AppConfig.enableAnalytics, isFalse);
      expect(AppConfig.enableCrashReporting, isFalse);
      expect(AppConfig.aiProvider, 'gemini');
      expect(AppConfig.ocrProvider, 'mistral');
    });

    test('apiBaseUrl is an absolute http(s) URL string', () {
      expect(AppConfig.apiBaseUrl, startsWith('http'));
    });

    test('maskSecret never returns the full secret', () {
      const secret = 'abcdefghijklmnop';
      final masked = AppConfig.maskSecret(secret);
      expect(masked, isNot(secret));
      expect(masked, endsWith('mnop'));
      expect(masked, contains('*'));
      expect(AppConfig.maskSecret(''), '(not set)');
    });

    test('missingRequired lists empty supabase defines', () {
      // Without --dart-define, both are empty in unit tests.
      expect(AppConfig.missingRequired(), containsAll(['SUPABASE_URL', 'SUPABASE_ANON_KEY']));
    });

    test('logStartupConfig never prints raw anon key material', () {
      final lines = <String>[];
      AppConfig.logStartupConfig(lines.add);
      final joined = lines.join('\n');
      expect(joined, contains('AI provider'));
      expect(joined, contains('OCR provider'));
      // Logger must never dump JWT-shaped material even if present via defines.
      expect(joined, isNot(contains('eyJ')));
    });
  });
}
