import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/main.dart';

void main() {
  testWidgets('LexivoApp renders Lexivo placeholder home', (tester) async {
    await tester.pumpWidget(const LexivoApp());

    expect(find.text('Lexivo'), findsOneWidget);
  });
}
