import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/widgets/async_value_view.dart';
import 'package:lexivo/features/subscription/domain/entities/subscription_status.dart';
import 'package:lexivo/features/subscription/presentation/providers/subscription_providers.dart';

/// Stub upgrade screen — no payment SDK; calls upgrade API when flag on.
class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(subscriptionMeProvider);
    final paywallOn = ref.watch(subscriptionPaywallEnabledProvider);
    final upgradeFailure =
        ref.watch(subscriptionMeProvider.notifier).upgradeFailure;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LexivoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Upgrade to Paid', style: LexivoTypography.headline),
              const SizedBox(height: LexivoSpacing.sm),
              Text(
                'Remove free-tier caps on documents, chat, and OCR pages.',
                style: LexivoTypography.body,
              ),
              const SizedBox(height: LexivoSpacing.lg),
              if (upgradeFailure != null)
                LexivoErrorBanner(
                  message: upgradeFailure.message,
                  onRetry: _busy || !paywallOn ? null : _onUpgrade,
                ),
              Expanded(
                child: AsyncValueView<SubscriptionStatus>(
                  value: me,
                  onRetry: () =>
                      ref.read(subscriptionMeProvider.notifier).refresh(),
                  builder: (context, status) {
                    if (status.isPaid) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'You are on the paid plan.',
                            style: LexivoTypography.title,
                          ),
                          const Spacer(),
                          LexivoButton(
                            label: 'Back',
                            onPressed: () =>
                                context.go(RouteGuards.subscription),
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        if (paywallOn)
                          LexivoButton(
                            label: _busy ? 'Upgrading…' : 'Confirm upgrade',
                            onPressed: _busy ? null : _onUpgrade,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onUpgrade() async {
    setState(() => _busy = true);
    final ok = await ref.read(subscriptionMeProvider.notifier).upgrade();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      context.go(RouteGuards.subscription);
    }
  }
}
