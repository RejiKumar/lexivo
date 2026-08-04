import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('subscription feature has no Dio or cross-feature imports', () {
    final root = Directory('lib/features/subscription');
    expect(root.existsSync(), isTrue);
    final dartFiles = root
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      expect(
        source.contains("package:dio"),
        isFalse,
        reason: '${file.path} must not import Dio',
      );
      for (final feature in [
        'auth',
        'document_scan',
        'ocr',
        'summarization',
        'translation',
        'rag_chat',
        'pdf_export',
        'notifications',
      ]) {
        expect(
          source.contains('package:lexivo/features/$feature/'),
          isFalse,
          reason: '${file.path} must not import features/$feature',
        );
      }
    }
  });
}
