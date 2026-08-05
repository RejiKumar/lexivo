import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/app_upgrade/app_upgrade_service.dart';
import 'package:lexivo/core/app_upgrade/upgrade_policy.dart';
import 'package:lexivo/core/design_system/components/bottom_sheet.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/dialog.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/design_system/utils/adaptive_overlay.dart';
import 'package:lexivo/core/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

typedef UpgradeLaunchUrl = Future<bool> Function(
  Uri uri, {
  LaunchMode mode,
});

/// Runs version check on startup + resume; shows soft/force UI via design-system.
///
/// Wrap the [MaterialApp.router] child (via `builder:`) so [LexivoApp] showcase
/// path stays untouched.
class AppUpgradeGate extends ConsumerStatefulWidget {
  const AppUpgradeGate({
    super.key,
    required this.child,
    this.launchUrlFn,
  });

  final Widget child;

  /// Injectable for tests — defaults to [launchUrl].
  final UpgradeLaunchUrl? launchUrlFn;

  @override
  ConsumerState<AppUpgradeGate> createState() => _AppUpgradeGateState();
}

class _AppUpgradeGateState extends ConsumerState<AppUpgradeGate>
    with WidgetsBindingObserver {
  bool _checking = false;
  bool _softDismissed = false;
  bool _promptVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _runCheck());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _softDismissed = false;
      _runCheck();
    }
  }

  Future<void> _runCheck() async {
    if (!mounted || _checking || _promptVisible) return;
    _checking = true;
    try {
      final decision = await ref.read(appUpgradeServiceProvider).check();
      if (!mounted || !decision.needsPrompt) return;
      if (decision.kind == UpgradeKind.soft && _softDismissed) return;
      await _present(decision);
    } finally {
      _checking = false;
    }
  }

  Future<void> _present(UpgradeDecision decision) async {
    _promptVisible = true;
    try {
      await showLexivoAdaptiveOverlay<void>(
        context: context,
        showSheet: () => _showSheet(decision),
        showDialog: () => _showDialog(decision),
      );
    } finally {
      _promptVisible = false;
    }
  }

  Future<void> _showDialog(UpgradeDecision decision) async {
    final l10n = AppLocalizations.of(context);
    final force = decision.kind == UpgradeKind.force;
    await LexivoDialog.show<void>(
      context,
      variant: force
          ? LexivoDialogVariant.alert
          : LexivoDialogVariant.confirmation,
      title: force ? l10n.upgradeForceTitle : l10n.upgradeSoftTitle,
      body: _body(decision, l10n),
      primaryLabel:
          decision.isWeb ? l10n.upgradeReloadAction : l10n.upgradeUpdateAction,
      onPrimary: () {
        Navigator.of(context).pop();
        _openUpdate(decision);
      },
      secondaryLabel: force ? null : l10n.upgradeLaterAction,
      onSecondary: force
          ? null
          : () {
              _softDismissed = true;
              Navigator.of(context).pop();
            },
      barrierDismissible: !force,
    );
  }

  Future<void> _showSheet(UpgradeDecision decision) async {
    final l10n = AppLocalizations.of(context);
    final force = decision.kind == UpgradeKind.force;
    await LexivoBottomSheet.show<void>(
      context,
      title: force ? l10n.upgradeForceTitle : l10n.upgradeSoftTitle,
      isDismissible: !force,
      enableDrag: !force,
      child: _UpgradeSheetBody(
        body: _body(decision, l10n),
        primaryLabel:
            decision.isWeb ? l10n.upgradeReloadAction : l10n.upgradeUpdateAction,
        secondaryLabel: force ? null : l10n.upgradeLaterAction,
        onPrimary: () {
          Navigator.of(context).pop();
          _openUpdate(decision);
        },
        onSecondary: force
            ? null
            : () {
                _softDismissed = true;
                Navigator.of(context).pop();
              },
      ),
    );
  }

  String _body(UpgradeDecision decision, AppLocalizations l10n) {
    if (decision.message.trim().isNotEmpty) return decision.message;
    return decision.kind == UpgradeKind.force
        ? l10n.upgradeForceBody
        : l10n.upgradeSoftBody;
  }

  Future<void> _openUpdate(UpgradeDecision decision) async {
    final UpgradeLaunchUrl launch = widget.launchUrlFn ??
        (uri, {LaunchMode mode = LaunchMode.platformDefault}) =>
            launchUrl(uri, mode: mode);

    if (decision.isWeb) {
      // Reload current origin (webOnlyWindowName _self replaces the tab).
      await launch(Uri.base, mode: LaunchMode.platformDefault);
      return;
    }

    final url = decision.storeUrl.trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launch(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _UpgradeSheetBody extends StatelessWidget {
  const _UpgradeSheetBody({
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(body, style: LexivoTypography.body),
        const SizedBox(height: LexivoSpacing.lg),
        LexivoButton(
          label: primaryLabel,
          onPressed: onPrimary,
          variant: LexivoButtonVariant.primary,
        ),
        if (secondaryLabel != null && onSecondary != null) ...[
          const SizedBox(height: LexivoSpacing.sm),
          LexivoButton(
            label: secondaryLabel!,
            onPressed: onSecondary,
            variant: LexivoButtonVariant.ghost,
          ),
        ],
      ],
    );
  }
}
