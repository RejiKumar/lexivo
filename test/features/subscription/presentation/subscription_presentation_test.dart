import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/subscription/presentation/providers/subscription_providers.dart';

import '../../../helpers/fake_subscription_repository.dart';
import '../../../helpers/subscription_test_harness.dart';

void main() {
  testWidgets('usage summary shows limits without upgrade CTA (flag off)',
      (tester) async {
    await tester.pumpWidget(wrapUsageSummary(paywallEnabled: false));
    await tester.pumpAndSettle();
    expect(find.textContaining('Documents'), findsOneWidget);
    expect(find.textContaining('5 / 20'), findsOneWidget);
    expect(find.text('Upgrade'), findsNothing);
    expect(find.byType(LexivoButton), findsNothing);
  });

  testWidgets('paywall shows upgrade CTA when flag on', (tester) async {
    await tester.pumpWidget(wrapPaywallScreen(paywallEnabled: true));
    await tester.pumpAndSettle();
    expect(find.text('Lexivo Plan'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
  });

  testWidgets('paywall hides upgrade CTA when flag off', (tester) async {
    await tester.pumpWidget(wrapPaywallScreen(paywallEnabled: false));
    await tester.pumpAndSettle();
    expect(find.text('Upgrade'), findsNothing);
  });

  testWidgets('upgrade screen confirms stub upgrade', (tester) async {
    final repo = FakeSubscriptionRepository(
      initial: sampleSubscriptionStatus(paywallEnabled: true),
    );
    await tester.pumpWidget(
      wrapUpgradeScreen(repository: repo, paywallEnabled: true),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm upgrade'));
    await tester.pumpAndSettle();
    expect(repo.upgradeCalls, 1);
    expect(repo.status.isPaid, isTrue);
  });

  testWidgets('load failure shows LexivoErrorBanner + retry', (tester) async {
    final repo = FakeSubscriptionRepository()
      ..nextGetMeFailure = const NetworkFailure(message: 'offline');
    await tester.pumpWidget(wrapUsageSummary(repository: repo));
    await tester.pumpAndSettle();
    expect(find.byType(LexivoErrorBanner), findsOneWidget);
    expect(find.text('offline'), findsOneWidget);
  });

  test('provider loads me into AsyncData', () async {
    final repo = FakeSubscriptionRepository();
    final container = createSubscriptionContainer(repository: repo);
    addTearDown(container.dispose);
    final value = await container.read(subscriptionMeProvider.future);
    expect(value.tier, 'free');
    expect(repo.getMeCalls, greaterThan(0));
  });
}
