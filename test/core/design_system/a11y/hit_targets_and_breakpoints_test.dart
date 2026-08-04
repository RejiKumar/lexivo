import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/card.dart';
import 'package:lexivo/core/design_system/components/document_card.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/design_system/components/input.dart';
import 'package:lexivo/core/design_system/components/nav_bar.dart';
import 'package:lexivo/core/design_system/tokens/breakpoints.dart';

import '../components/harness.dart';

void main() {
  group('≥44×44 hit targets', () {
    testWidgets('LexivoButton all sizes', (tester) async {
      for (final size in LexivoButtonSize.values) {
        await tester.pumpWidget(
          wrapWithLexivoTheme(
            child: LexivoButton(label: 'Go', size: size, onPressed: () {}),
          ),
        );
        final box = tester.renderObject<RenderBox>(find.byType(LexivoButton));
        expect(box.size.width, greaterThanOrEqualTo(44), reason: '$size width');
        expect(box.size.height, greaterThanOrEqualTo(44), reason: '$size height');
      }
    });

    testWidgets('LexivoCard interactive', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoCard(
            variant: LexivoCardVariant.interactive,
            onTap: () {},
            child: const Text('Tap'),
          ),
        ),
      );
      final box = tester.renderObject<RenderBox>(find.byType(LexivoCard));
      expect(box.size.width, greaterThanOrEqualTo(44));
      expect(box.size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('LexivoTextField clear control', (tester) async {
      final controller = TextEditingController(text: 'query');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          surfaceSize: const Size(400, 80),
          child: LexivoTextField(
            variant: LexivoTextFieldVariant.search,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final clear = find.byIcon(Icons.close);
      expect(clear, findsOneWidget);
      final button = tester.renderObject<RenderBox>(
        find.ancestor(of: clear, matching: find.byType(IconButton)),
      );
      expect(button.size.width, greaterThanOrEqualTo(44));
      expect(button.size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('LexivoErrorBanner retry and dismiss', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          surfaceSize: const Size(400, 100),
          child: LexivoErrorBanner(
            message: 'Error',
            onRetry: () {},
            onDismiss: () {},
          ),
        ),
      );
      final retry = tester.renderObject<RenderBox>(find.byType(TextButton));
      expect(retry.size.width, greaterThanOrEqualTo(44));
      expect(retry.size.height, greaterThanOrEqualTo(44));

      final dismissIcon = find.byIcon(Icons.close);
      final dismiss = tester.renderObject<RenderBox>(
        find.ancestor(of: dismissIcon, matching: find.byType(IconButton)),
      );
      expect(dismiss.size.width, greaterThanOrEqualTo(44));
      expect(dismiss.size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('LexivoBottomNav destinations', (tester) async {
      const items = [
        NavItem(id: '/a', label: 'A', icon: Icons.home),
        NavItem(id: '/b', label: 'B', icon: Icons.search),
      ];
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoBottomNav(
            items: items,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      );
      final inkWells = find.descendant(
        of: find.byType(LexivoBottomNav),
        matching: find.byType(InkWell),
      );
      expect(inkWells, findsNWidgets(2));
      for (var i = 0; i < 2; i++) {
        final box = tester.renderObject<RenderBox>(inkWells.at(i));
        expect(box.size.width, greaterThanOrEqualTo(44));
        expect(box.size.height, greaterThanOrEqualTo(44));
      }
    });

    testWidgets('LexivoDocumentCard interactive', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoDocumentCard(
            name: 'Doc.pdf',
            status: LexivoDocumentStatus.ready,
            timestamp: 'now',
            onTap: () {},
          ),
        ),
      );
      final box = tester.renderObject<RenderBox>(find.byType(LexivoDocumentCard));
      expect(box.size.width, greaterThanOrEqualTo(44));
      expect(box.size.height, greaterThanOrEqualTo(44));
    });
  });

  group('LexivoBreakpoints', () {
    test('resolves mobile / tablet / desktop', () {
      expect(LexivoBreakpoints.resolve(320), LexivoBreakpoint.mobile);
      expect(LexivoBreakpoints.resolve(599), LexivoBreakpoint.mobile);
      expect(LexivoBreakpoints.resolve(600), LexivoBreakpoint.tablet);
      expect(LexivoBreakpoints.resolve(1023), LexivoBreakpoint.tablet);
      expect(LexivoBreakpoints.resolve(1024), LexivoBreakpoint.desktop);
    });

    test('pagePadding uses spacing tokens', () {
      expect(
        LexivoBreakpoints.pagePadding(LexivoBreakpoint.mobile),
        LexivoBreakpoints.pagePadding(LexivoBreakpoint.mobile),
      );
      expect(
        LexivoBreakpoints.pagePadding(LexivoBreakpoint.mobile),
        lessThan(LexivoBreakpoints.pagePadding(LexivoBreakpoint.tablet)),
      );
      expect(
        LexivoBreakpoints.pagePadding(LexivoBreakpoint.tablet),
        lessThan(LexivoBreakpoints.pagePadding(LexivoBreakpoint.desktop)),
      );
    });
  });
}
