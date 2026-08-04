import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/nav_bar.dart';

import 'harness.dart';

final _items = [
  const NavItem(id: '/home', label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home),
  const NavItem(id: '/library', label: 'Library', icon: Icons.folder_outlined, selectedIcon: Icons.folder),
  const NavItem(id: '/chat', label: 'Chat', icon: Icons.chat_bubble_outline, selectedIcon: Icons.chat_bubble),
  const NavItem(id: '/search', label: 'Search', icon: Icons.search),
  const NavItem(id: '/settings', label: 'Settings', icon: Icons.settings_outlined, selectedIcon: Icons.settings),
];

void main() {
  group('NavItem', () {
    test('equality by fields', () {
      const a = NavItem(id: '/a', label: 'A', icon: Icons.abc);
      const b = NavItem(id: '/a', label: 'A', icon: Icons.abc);
      const c = NavItem(id: '/b', label: 'A', icon: Icons.abc);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('holds route id stub as string', () {
      expect(_items.first.id, '/home');
    });
  });

  group('LexivoBottomNav', () {
    testWidgets('renders up to 5 items and reports selection', (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoBottomNav(
            items: _items,
            selectedIndex: selected,
            onDestinationSelected: (i) => selected = i,
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      await tester.tap(find.text('Chat'));
      expect(selected, 2);
    });

    testWidgets('assert fails for more than 5 items', (tester) async {
      expect(
        () => LexivoBottomNav(
          items: [
            ..._items,
            const NavItem(id: '/extra', label: 'Extra', icon: Icons.add),
          ],
          selectedIndex: 0,
          onDestinationSelected: (_) {},
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('LexivoNavRail', () {
    testWidgets('consumes the same NavItem list', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: SizedBox(
            height: 400,
            child: LexivoNavRail(
              items: _items,
              selectedIndex: 1,
              onDestinationSelected: (_) {},
              extended: true,
            ),
          ),
        ),
      );

      expect(find.text('Library'), findsOneWidget);
      expect(find.byIcon(Icons.folder), findsOneWidget);
    });

    testWidgets('collapses to icon-focused layout', (tester) async {
      var extended = true;
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                height: 400,
                child: LexivoNavRail(
                  items: _items.take(3).toList(),
                  selectedIndex: 0,
                  onDestinationSelected: (_) {},
                  extended: extended,
                  onToggleExtended: () => setState(() => extended = !extended),
                ),
              );
            },
          ),
        ),
      );

      expect(tester.getSize(find.byType(LexivoNavRail)).width, 220);
      await tester.tap(find.byTooltip('Collapse'));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(LexivoNavRail)).width, 72);
    });
  });
}
