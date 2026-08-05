import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/components/button.dart';
import '../../../../core/design_system/tokens/spacing.dart';
import '../../../../core/design_system/tokens/typography.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/routing/route_guards.dart';
import '../providers/auth_providers.dart';

/// Legacy authenticated landing — kept for barrel / pattern demos.
///
/// Primary app home redirects to [RouteGuards.documents] via the adaptive shell.
class AuthHomeShell extends ConsumerWidget {
  const AuthHomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(authStateProvider).session;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LexivoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.appTitle, style: LexivoTypography.display),
              const SizedBox(height: LexivoSpacing.sm),
              Text(
                session?.user.email.isNotEmpty == true
                    ? l10n.signedInAs(session!.user.email)
                    : l10n.signedIn,
                style: LexivoTypography.body,
              ),
              const Spacer(),
              LexivoButton(
                label: l10n.navDocuments,
                onPressed: () => context.go(RouteGuards.documents),
                fullWidth: true,
              ),
              const SizedBox(height: LexivoSpacing.md),
              LexivoButton(
                label: l10n.navNotifications,
                variant: LexivoButtonVariant.secondary,
                onPressed: () => context.go(RouteGuards.notifications),
                fullWidth: true,
              ),
              const SizedBox(height: LexivoSpacing.md),
              LexivoButton(
                label: l10n.accountSettings,
                variant: LexivoButtonVariant.secondary,
                onPressed: () => context.go(RouteGuards.account),
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
        ),
      ),
    );
  }
}
