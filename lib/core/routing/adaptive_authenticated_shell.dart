import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design_system/components/nav_bar.dart';
import '../design_system/tokens/breakpoints.dart';
import '../l10n/l10n.dart';
import 'route_guards.dart';

/// Shared primary destinations for [LexivoBottomNav] / [LexivoNavRail].
List<NavItem> lexivoPrimaryNavItems(AppLocalizations l10n) {
  return [
    NavItem(
      id: RouteGuards.documents,
      label: l10n.navDocuments,
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
    ),
    NavItem(
      id: RouteGuards.documentScan,
      label: l10n.navScan,
      icon: Icons.document_scanner_outlined,
      selectedIcon: Icons.document_scanner,
    ),
    NavItem(
      id: RouteGuards.notifications,
      label: l10n.navNotifications,
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications,
    ),
    NavItem(
      id: RouteGuards.account,
      label: l10n.navAccount,
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];
}

/// Whether [location] is a document deep-detail path (OCR, chat, …).
///
/// Primary destinations `/documents` and `/documents/scan` keep chrome visible.
bool isDocumentDetailLocation(String location) {
  final path = Uri.tryParse(location)?.path ?? location;
  final segments =
      path.split('/').where((segment) => segment.isNotEmpty).toList();
  if (segments.length < 3) return false;
  if (segments.first != 'documents') return false;
  if (segments[1] == 'scan') return false;
  return true;
}

int primaryNavSelectedIndex(String location, List<NavItem> items) {
  final path = Uri.tryParse(location)?.path ?? location;
  var bestIndex = -1;
  var bestLength = -1;
  for (var i = 0; i < items.length; i++) {
    final id = items[i].id;
    if (path == id || path.startsWith('$id/')) {
      if (id.length > bestLength) {
        bestLength = id.length;
        bestIndex = i;
      }
    }
  }
  if (bestIndex >= 0) return bestIndex;
  final documentsIndex =
      items.indexWhere((item) => item.id == RouteGuards.documents);
  return documentsIndex < 0 ? 0 : documentsIndex;
}

/// Authenticated chrome: bottom nav on mobile, nav rail on tablet/desktop.
class AdaptiveAuthenticatedShell extends StatelessWidget {
  const AdaptiveAuthenticatedShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = lexivoPrimaryNavItems(l10n);
    final location = GoRouterState.of(context).matchedLocation;
    final hideChrome = isDocumentDetailLocation(location);
    final selectedIndex = primaryNavSelectedIndex(location, items);
    final breakpoint =
        LexivoBreakpoints.resolve(MediaQuery.sizeOf(context).width);

    if (hideChrome) {
      return child;
    }

    void onDestinationSelected(int index) {
      final target = items[index].id;
      if (target != location) {
        context.go(target);
      }
    }

    if (breakpoint == LexivoBreakpoint.mobile) {
      return Scaffold(
        body: child,
        bottomNavigationBar: LexivoBottomNav(
          items: items,
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          LexivoNavRail(
            items: items,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            extended: breakpoint == LexivoBreakpoint.desktop,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
