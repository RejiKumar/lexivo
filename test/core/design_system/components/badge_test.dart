import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/badge.dart';

import 'harness.dart';

void main() {
  group('LexivoBadge', () {
    testWidgets('renders all variants', (tester) async {
      for (final variant in LexivoBadgeVariant.values) {
        await tester.pumpWidget(
          wrapWithLexivoTheme(
            child: LexivoBadge(label: variant.name, variant: variant),
          ),
        );
        expect(find.text(variant.name), findsOneWidget);
      }
    });
  });
}
