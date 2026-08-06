import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ads/ads.dart';
import '../../../../core/design_system/components/button.dart';
import '../../../../core/design_system/components/input.dart';
import '../../../../core/design_system/components/snackbar.dart';
import '../../../../core/design_system/tokens/spacing.dart';
import '../../../../core/design_system/tokens/typography.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../domain/entities/auth_entities.dart';
import '../providers/auth_providers.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  TextEditingController? _displayName;
  TextEditingController? _email;
  var _saving = false;

  @override
  void dispose() {
    _displayName?.dispose();
    _email?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final display = _displayName?.text.trim();
    final email = _email?.text.trim();
    setState(() => _saving = true);
    final result = await ref.read(authStateProvider.notifier).updateAccount(
          displayName: display,
          email: email,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    result.when(
      success: (_) {
        LexivoSnackbar.show(
          context,
          message: l10n.accountUpdated,
          variant: LexivoSnackbarVariant.success,
        );
        ref.invalidate(accountProfileProvider);
      },
      onFailure: (f) {
        LexivoSnackbar.show(
          context,
          message: f.message,
          variant: LexivoSnackbarVariant.error,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(accountProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountTitle, style: LexivoTypography.title),
      ),
      body: LexivoMenuAdsScaffold(
        bannerPlacementId: AdsPlacements.accountBanner,
        trendingPlacementId: AdsPlacements.accountTrending,
        body: AsyncValueView<AuthUser>(
          value: profile,
          onRetry: () => ref.invalidate(accountProfileProvider),
          builder: (context, AuthUser user) {
            _displayName ??=
                TextEditingController(text: user.displayName ?? '');
            _email ??= TextEditingController(text: user.email);

            return Padding(
              padding: const EdgeInsets.all(LexivoSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LexivoTextField(
                    controller: _displayName,
                    label: l10n.displayNameLabel,
                  ),
                  const SizedBox(height: LexivoSpacing.md),
                  LexivoTextField(
                    controller: _email,
                    label: l10n.emailLabel,
                  ),
                  const SizedBox(height: LexivoSpacing.lg),
                  LexivoButton(
                    label: l10n.saveAction,
                    loading: _saving,
                    onPressed: _save,
                    fullWidth: true,
                  ),
                  const SizedBox(height: LexivoSpacing.md),
                  LexivoButton(
                    label: l10n.signOutAction,
                    variant: LexivoButtonVariant.ghost,
                    onPressed: () =>
                        ref.read(authStateProvider.notifier).signOut(),
                    fullWidth: true,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
