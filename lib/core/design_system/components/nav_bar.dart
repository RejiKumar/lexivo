import 'package:flutter/material.dart';

import '../tokens/color.dart';
import '../tokens/icon_size.dart';
import '../tokens/motion.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Shared navigation destination — design-system owned; route ids are string
/// stubs for later `app_router` binding. No feature imports.
@immutable
class NavItem {
  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  /// Route / destination id stub (e.g. `/library`).
  final String id;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavItem &&
          id == other.id &&
          label == other.label &&
          icon == other.icon &&
          selectedIcon == other.selectedIcon;

  @override
  int get hashCode => Object.hash(id, label, icon, selectedIcon);
}

/// Mobile bottom navigation — at most 5 [NavItem]s.
class LexivoBottomNav extends StatelessWidget {
  const LexivoBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : assert(items.length <= 5, 'LexivoBottomNav supports at most 5 items');

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;

    return Material(
      color: colors.backgroundSurface,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.borderDefault)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavDestination(
                      item: items[i],
                      selected: i == selectedIndex,
                      onTap: () => onDestinationSelected(i),
                      compact: true,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tablet/web navigation rail — collapsible; shares [NavItem] with bottom nav.
class LexivoNavRail extends StatelessWidget {
  const LexivoNavRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extended = true,
    this.onToggleExtended,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// When true, shows labels beside icons; when false, icons only.
  final bool extended;
  final VoidCallback? onToggleExtended;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;

    return AnimatedContainer(
      duration: LexivoMotion.standard.duration,
      curve: LexivoMotion.standard.curve,
      width: extended ? 220 : 72,
      decoration: BoxDecoration(
        color: colors.backgroundSurface,
        border: Border(right: BorderSide(color: colors.borderDefault)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (onToggleExtended != null)
              Align(
                alignment: extended ? Alignment.centerRight : Alignment.center,
                child: IconButton(
                  tooltip: extended ? 'Collapse' : 'Expand',
                  onPressed: onToggleExtended,
                  icon: Icon(
                    extended ? Icons.menu_open : Icons.menu,
                    color: colors.contentSecondary,
                  ),
                ),
              ),
            const SizedBox(height: LexivoSpacing.xs),
            for (var i = 0; i < items.length; i++)
              _NavDestination(
                item: items[i],
                selected: i == selectedIndex,
                onTap: () => onDestinationSelected(i),
                compact: !extended,
              ),
          ],
        ),
      ),
    );
  }
}

class _NavDestination extends StatelessWidget {
  const _NavDestination({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    final fg = selected ? colors.brandPrimary : colors.contentSecondary;
    final icon = selected ? (item.selectedIcon ?? item.icon) : item.icon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LexivoRadius.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? LexivoSpacing.xs : LexivoSpacing.md,
              vertical: compact ? LexivoSpacing.xxs : LexivoSpacing.sm,
            ),
            child: compact
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: fg, size: LexivoIconSize.md),
                      const SizedBox(height: LexivoSpacing.micro),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LexivoTypography.captionCompact.copyWith(
                          color: fg,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(icon, color: fg, size: LexivoIconSize.md),
                      const SizedBox(width: LexivoSpacing.sm),
                      Expanded(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LexivoTypography.body.copyWith(
                            color: fg,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
