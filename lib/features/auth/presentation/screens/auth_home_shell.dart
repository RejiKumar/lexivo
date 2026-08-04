import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/components/button.dart';
import '../../../../core/design_system/tokens/spacing.dart';
import '../../../../core/design_system/tokens/typography.dart';
import '../../../../core/routing/route_guards.dart';
import '../providers/auth_providers.dart';

/// Minimal authenticated shell — brand only; no document_scan UI.
class AuthHomeShell extends ConsumerWidget {
  const AuthHomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authStateProvider).session;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LexivoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Lexivo', style: LexivoTypography.display),
              const SizedBox(height: LexivoSpacing.sm),
              Text(
                session?.user.email.isNotEmpty == true
                    ? 'Signed in as ${session!.user.email}'
                    : 'Signed in',
                style: LexivoTypography.body,
              ),
              const Spacer(),
              LexivoButton(
                label: 'Documents',
                onPressed: () => context.go(RouteGuards.documents),
                fullWidth: true,
              ),
              const SizedBox(height: LexivoSpacing.md),
              LexivoButton(
                label: 'Account settings',
                variant: LexivoButtonVariant.secondary,
                onPressed: () => context.go(RouteGuards.account),
                fullWidth: true,
              ),
              const SizedBox(height: LexivoSpacing.md),
              LexivoButton(
                label: 'Sign out',
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
