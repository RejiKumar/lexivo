import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notifications feature has no Dio or other feature imports', () {
    final root = Directory('lib/features/notifications');
    expect(root.existsSync(), isTrue);
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      expect(
        source.contains('package:dio'),
        isFalse,
        reason: '${entity.path} must not import dio',
      );
      for (final other in [
        'features/pdf_export',
        'features/rag_chat',
        'features/translation',
        'features/summarization',
        'features/ocr',
        'features/document_scan',
      ]) {
        expect(
          source.contains('package:lexivo/$other'),
          isFalse,
          reason: '${entity.path} must not import $other',
        );
      }
    }
  });
}
