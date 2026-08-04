import 'package:flutter/material.dart';

import '../../theming/app_theme.dart';
import '../components/components.dart';
import '../tokens/color.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Dev catalog for every §3 design-system component and major variants.
///
/// Only mounted when the showcase flag is on — see `design_system_flags.dart`.
class DesignSystemShowcase extends StatefulWidget {
  const DesignSystemShowcase({super.key});

  static const String routeName = '/design-system';
  static const String title = 'Design System Showcase';

  @override
  State<DesignSystemShowcase> createState() => _DesignSystemShowcaseState();
}

class _DesignSystemShowcaseState extends State<DesignSystemShowcase> {
  int _navIndex = 0;
  bool _railExtended = true;
  bool _dark = false;

  static const _navItems = [
    NavItem(
      id: '/home',
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    NavItem(
      id: '/library',
      label: 'Library',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
    ),
    NavItem(
      id: '/chat',
      label: 'Chat',
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble,
    ),
    NavItem(id: '/search', label: 'Search', icon: Icons.search),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _dark ? AppTheme.dark : AppTheme.light,
      child: Builder(
        builder: (context) {
          final colors = Theme.of(context).extension<LexivoColors>()!;
          return Scaffold(
            backgroundColor: colors.backgroundDefault,
            appBar: AppBar(
              title: Text(
                DesignSystemShowcase.title,
                style: LexivoTypography.title.copyWith(
                  color: colors.contentPrimary,
                ),
              ),
              backgroundColor: colors.backgroundSurface,
              foregroundColor: colors.contentPrimary,
              elevation: 0,
              actions: [
                IconButton(
                  tooltip: _dark ? 'Light theme' : 'Dark theme',
                  onPressed: () => setState(() => _dark = !_dark),
                  icon: Icon(
                    _dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(LexivoSpacing.lg),
              children: [
                _section(context, 'Button', _buttons()),
                _section(context, 'Card', _cards()),
                _section(context, 'TextField', _inputs()),
                _section(context, 'Badge', _badges()),
                _section(context, 'Skeleton', _skeletons()),
                _section(context, 'ErrorBanner', _errorBanner()),
                _section(context, 'EmptyState', _emptyState()),
                _section(context, 'Snackbar', _snackbars(context)),
                _section(context, 'Dialog', _dialogs(context)),
                _section(context, 'BottomSheet', _bottomSheets(context)),
                _section(context, 'BottomNav', _bottomNav()),
                _section(context, 'NavRail', _navRail()),
                _section(context, 'ChatBubble', _chatBubbles()),
                _section(context, 'DocumentCard', _documentCards()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: LexivoSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: LexivoTypography.headline.copyWith(
              color: colors.contentPrimary,
            ),
          ),
          const SizedBox(height: LexivoSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buttons() {
    return Wrap(
      spacing: LexivoSpacing.sm,
      runSpacing: LexivoSpacing.sm,
      children: [
        for (final v in LexivoButtonVariant.values)
          LexivoButton(label: v.name, variant: v, onPressed: () {}),
        LexivoButton(
          label: 'sm',
          size: LexivoButtonSize.sm,
          onPressed: () {},
        ),
        LexivoButton(
          label: 'md',
          size: LexivoButtonSize.md,
          onPressed: () {},
        ),
        LexivoButton(
          label: 'lg',
          size: LexivoButtonSize.lg,
          onPressed: () {},
        ),
        LexivoButton(
          label: 'Loading',
          loading: true,
          onPressed: () {},
        ),
        LexivoButton(
          label: 'Disabled',
          enabled: false,
          onPressed: () {},
        ),
        LexivoButton(
          label: 'Icons',
          leadingIcon: Icons.add,
          trailingIcon: Icons.arrow_forward,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _cards() {
    return Column(
      children: [
        for (final v in LexivoCardVariant.values) ...[
          LexivoCard(
            variant: v,
            onTap: v == LexivoCardVariant.interactive ? () {} : null,
            child: Text('${v.name} card'),
          ),
          const SizedBox(height: LexivoSpacing.sm),
        ],
      ],
    );
  }

  Widget _inputs() {
    return const Column(
      children: [
        LexivoTextField(
          variant: LexivoTextFieldVariant.text,
          label: 'Text',
          hintText: 'Enter text',
        ),
        SizedBox(height: LexivoSpacing.sm),
        LexivoTextField(
          variant: LexivoTextFieldVariant.multiline,
          label: 'Multiline',
          hintText: 'Notes…',
        ),
        SizedBox(height: LexivoSpacing.sm),
        LexivoTextField(
          variant: LexivoTextFieldVariant.search,
          hintText: 'Search',
        ),
        SizedBox(height: LexivoSpacing.sm),
        LexivoTextField(
          label: 'Error',
          errorText: 'Required field',
        ),
      ],
    );
  }

  Widget _badges() {
    return Wrap(
      spacing: LexivoSpacing.sm,
      runSpacing: LexivoSpacing.sm,
      children: [
        for (final v in LexivoBadgeVariant.values)
          LexivoBadge(label: v.name, variant: v),
      ],
    );
  }

  Widget _skeletons() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LexivoSkeleton(variant: LexivoSkeletonVariant.line, width: 200),
        SizedBox(height: LexivoSpacing.sm),
        LexivoSkeleton(
          variant: LexivoSkeletonVariant.card,
          width: 240,
          height: 80,
        ),
        SizedBox(height: LexivoSpacing.sm),
        LexivoSkeleton(variant: LexivoSkeletonVariant.avatar),
      ],
    );
  }

  Widget _errorBanner() {
    return LexivoErrorBanner(
      message: 'Something went wrong loading documents.',
      onRetry: () {},
      onDismiss: () {},
    );
  }

  Widget _emptyState() {
    return LexivoEmptyState(
      icon: Icons.inbox_outlined,
      title: 'No documents yet',
      description: 'Upload a PDF or scan a page to get started.',
      ctaLabel: 'Upload',
      onCtaPressed: () {},
    );
  }

  Widget _snackbars(BuildContext context) {
    return Wrap(
      spacing: LexivoSpacing.sm,
      children: [
        LexivoButton(
          label: 'Info',
          variant: LexivoButtonVariant.secondary,
          onPressed: () => LexivoSnackbar.show(
            context,
            message: 'Info toast',
            variant: LexivoSnackbarVariant.info,
          ),
        ),
        LexivoButton(
          label: 'Success',
          variant: LexivoButtonVariant.secondary,
          onPressed: () => LexivoSnackbar.show(
            context,
            message: 'Saved',
            variant: LexivoSnackbarVariant.success,
          ),
        ),
        LexivoButton(
          label: 'Error',
          variant: LexivoButtonVariant.secondary,
          onPressed: () => LexivoSnackbar.show(
            context,
            message: 'Failed',
            variant: LexivoSnackbarVariant.error,
          ),
        ),
      ],
    );
  }

  Widget _dialogs(BuildContext context) {
    return Wrap(
      spacing: LexivoSpacing.sm,
      children: [
        LexivoButton(
          label: 'Confirmation',
          variant: LexivoButtonVariant.secondary,
          onPressed: () => LexivoDialog.show(
            context,
            variant: LexivoDialogVariant.confirmation,
            title: 'Delete document?',
            body: 'This cannot be undone.',
            primaryLabel: 'Delete',
            secondaryLabel: 'Cancel',
            primaryVariant: LexivoButtonVariant.destructive,
            onPrimary: () => Navigator.of(context).pop(),
            onSecondary: () => Navigator.of(context).pop(),
          ),
        ),
        LexivoButton(
          label: 'Alert',
          variant: LexivoButtonVariant.secondary,
          onPressed: () => LexivoDialog.show(
            context,
            variant: LexivoDialogVariant.alert,
            title: 'Update available',
            body: 'Restart to apply.',
            primaryLabel: 'OK',
            onPrimary: () => Navigator.of(context).pop(),
          ),
        ),
        LexivoButton(
          label: 'Custom',
          variant: LexivoButtonVariant.secondary,
          onPressed: () => LexivoDialog.show(
            context,
            variant: LexivoDialogVariant.custom,
            title: 'Custom',
            content: const Text('Arbitrary content slot'),
            primaryLabel: 'Close',
            onPrimary: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  Widget _bottomSheets(BuildContext context) {
    return Wrap(
      spacing: LexivoSpacing.sm,
      children: [
        LexivoButton(
          label: 'Generic',
          variant: LexivoButtonVariant.secondary,
          onPressed: () => LexivoBottomSheet.show(
            context,
            variant: LexivoBottomSheetVariant.generic,
            title: 'Generic sheet',
            child: const Padding(
              padding: EdgeInsets.all(LexivoSpacing.md),
              child: Text('Custom content'),
            ),
          ),
        ),
        LexivoButton(
          label: 'Action list',
          variant: LexivoButtonVariant.secondary,
          onPressed: () => LexivoBottomSheet.show(
            context,
            variant: LexivoBottomSheetVariant.actionList,
            title: 'Actions',
            actions: [
              LexivoBottomSheetAction(
                label: 'Share',
                icon: Icons.share_outlined,
                onTap: () => Navigator.of(context).pop(),
              ),
              LexivoBottomSheetAction(
                label: 'Delete',
                icon: Icons.delete_outline,
                isDestructive: true,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        LexivoButton(
          label: 'Scrollable',
          variant: LexivoButtonVariant.secondary,
          onPressed: () => LexivoBottomSheet.show(
            context,
            variant: LexivoBottomSheetVariant.scrollable,
            title: 'Details',
            child: Column(
              children: List.generate(
                20,
                (i) => ListTile(title: Text('Row $i')),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomNav() {
    return LexivoBottomNav(
      items: _navItems,
      selectedIndex: _navIndex,
      onDestinationSelected: (i) => setState(() => _navIndex = i),
    );
  }

  Widget _navRail() {
    return SizedBox(
      height: 280,
      child: LexivoNavRail(
        items: _navItems,
        selectedIndex: _navIndex,
        extended: _railExtended,
        onToggleExtended: () => setState(() => _railExtended = !_railExtended),
        onDestinationSelected: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  Widget _chatBubbles() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LexivoChatBubble(
          variant: LexivoChatBubbleVariant.user,
          message: 'Summarize this contract.',
        ),
        SizedBox(height: LexivoSpacing.sm),
        LexivoChatBubble(
          variant: LexivoChatBubbleVariant.assistant,
          message: 'Here is a concise summary…',
          citationChips: Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('p.1')),
              Chip(label: Text('p.4')),
            ],
          ),
        ),
        SizedBox(height: LexivoSpacing.sm),
        LexivoChatBubble(
          variant: LexivoChatBubbleVariant.assistantStreaming,
          message: 'Streaming…',
          animateStreaming: false,
        ),
      ],
    );
  }

  Widget _documentCards() {
    return Column(
      children: [
        for (final status in LexivoDocumentStatus.values) ...[
          LexivoDocumentCard(
            name: 'Contract_${status.name}.pdf',
            status: status,
            timestamp: 'Aug 4, 2026',
            onTap: () {},
          ),
          const SizedBox(height: LexivoSpacing.sm),
        ],
      ],
    );
  }
}
