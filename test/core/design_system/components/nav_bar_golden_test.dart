import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lexivo/core/design_system/components/nav_bar.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/theming/app_theme.dart';

final _items = [
  const NavItem(
    id: '/home',
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  const NavItem(
    id: '/library',
    label: 'Library',
    icon: Icons.folder_outlined,
    selectedIcon: Icons.folder,
  ),
  const NavItem(
    id: '/chat',
    label: 'Chat',
    icon: Icons.chat_bubble_outline,
    selectedIcon: Icons.chat_bubble,
  ),
  const NavItem(id: '/search', label: 'Search', icon: Icons.search),
  const NavItem(
    id: '/settings',
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];

void main() {
  goldenTest(
    'Lexivo navigation variants',
    fileName: 'lexivo_nav',
    builder: () => Theme(
      data: AppTheme.light,
      child: ColoredBox(
        color: LexivoColors.light().backgroundDefault,
        child: GoldenTestGroup(
          columns: 2,
          children: [
            GoldenTestScenario(
              name: 'bottom nav selected home',
              child: SizedBox(
                width: 390,
                child: LexivoBottomNav(
                  items: _items,
                  selectedIndex: 0,
                  onDestinationSelected: (_) {},
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'bottom nav selected chat',
              child: SizedBox(
                width: 390,
                child: LexivoBottomNav(
                  items: _items,
                  selectedIndex: 2,
                  onDestinationSelected: (_) {},
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'nav rail expanded',
              child: SizedBox(
                height: 320,
                child: LexivoNavRail(
                  items: _items,
                  selectedIndex: 1,
                  onDestinationSelected: (_) {},
                  extended: true,
                  onToggleExtended: () {},
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'nav rail collapsed',
              child: SizedBox(
                height: 320,
                child: LexivoNavRail(
                  items: _items,
                  selectedIndex: 1,
                  onDestinationSelected: (_) {},
                  extended: false,
                  onToggleExtended: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
