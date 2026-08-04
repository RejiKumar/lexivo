import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/main.dart';

void main() {
  testWidgets('LexivoApp renders Lexivo placeholder home', (tester) async {
    AppRouter.showcaseEnabled = false;
    await tester.pumpWidget(const LexivoApp(showcaseEnabled: false));

    expect(find.text('Lexivo'), findsOneWidget);
  });
}
