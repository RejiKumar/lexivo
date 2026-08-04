import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/features/summarization/summarization.dart';

void main() {
  test('barrel exports summary screen and providers', () {
    expect(SummaryScreen, isNotNull);
    expect(summaryResultProvider, isNotNull);
    expect(summarizationCoreOverrides(), isNotEmpty);
    expect(SummaryView, isNotNull);
  });
}
