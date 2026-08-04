import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/showcase/design_system_showcase.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/main.dart';

void main() {
  tearDown(() {
    AppRouter.showcaseEnabled = false;
  });

  group('design_system_showcase gate', () {
    testWidgets('renders catalog when showcase flag is on', (tester) async {
      AppRouter.showcaseEnabled = true;
      await tester.pumpWidget(const LexivoApp(showcaseEnabled: true));
      await tester.pumpAndSettle();

      expect(find.text(DesignSystemShowcase.title), findsOneWidget);
      expect(find.byType(DesignSystemShowcase), findsOneWidget);
      expect(find.text('Button'), findsWidgets);
      expect(find.text('Lexivo'), findsNothing);

      final scrollable = find.byType(Scrollable).first;
      for (final section in [
        'Card',
        'TextField',
        'Badge',
        'Skeleton',
        'ErrorBanner',
        'EmptyState',
        'Snackbar',
        'Dialog',
        'BottomSheet',
        'BottomNav',
        'NavRail',
        'ChatBubble',
        'DocumentCard',
      ]) {
        await tester.scrollUntilVisible(
          find.text(section),
          300,
          scrollable: scrollable,
        );
        expect(find.text(section), findsOneWidget);
      }
    });

    testWidgets('uses placeholder home when showcase flag is off',
        (tester) async {
      AppRouter.showcaseEnabled = false;
      await tester.pumpWidget(const LexivoApp(showcaseEnabled: false));
      await tester.pumpAndSettle();

      expect(find.text(DesignSystemShowcase.title), findsNothing);
      expect(find.text('Lexivo'), findsOneWidget);
      expect(find.byType(DesignSystemShowcase), findsNothing);
    });

    test('AppRouter.pageForRoute returns null when flag off', () {
      AppRouter.showcaseEnabled = false;
      expect(AppRouter.pageForRoute(AppRouter.designSystemShowcase), isNull);
      expect(AppRouter.routes, isEmpty);
      expect(AppRouter.initialHome(), isNull);
    });

    testWidgets('AppRouter.pageForRoute builds showcase when flag on',
        (tester) async {
      AppRouter.showcaseEnabled = true;
      final page = AppRouter.pageForRoute(AppRouter.designSystemShowcase);
      expect(page, isA<DesignSystemShowcase>());
      expect(AppRouter.routes, contains(AppRouter.designSystemShowcase));
      expect(AppRouter.initialHome(), isA<DesignSystemShowcase>());

      await tester.pumpWidget(const LexivoApp(showcaseEnabled: true));
      await tester.pumpAndSettle();
      expect(find.text(DesignSystemShowcase.title), findsOneWidget);
    });
  });
}
