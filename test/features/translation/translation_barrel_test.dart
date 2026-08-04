import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/features/translation/translation.dart';

void main() {
  test('translation barrel exports screen builders override', () {
    expect(translationCoreOverrides(), isNotEmpty);
  });
}
