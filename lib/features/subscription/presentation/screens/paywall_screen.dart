import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/widgets/async_value_view.dart';
import 'package:lexivo/features/subscription/domain/entities/subscription_status.dart';
import 'package:lexivo/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:lexivo/features/subscription/presentation/widgets/usage_summary.dart';

/// Paywall / plan overview — only reachable when paywall flag is on.
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(subscriptionMeProvider);
    final paywallOn = ref.watch(subscriptionPaywallEnabledProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LexivoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Lexivo Plan', style: LexivoTypography.headline),
              const SizedBox(height: LexivoSpacing.sm),
              Text(
                'Free-tier limits still apply. Upgrade unlocks unlimited usage.',
                style: LexivoTypography.body,
              ),
              const SizedBox(height: LexivoSpacing.lg),
              const UsageSummary(),
              const Spacer(),
              AsyncValueView<SubscriptionStatus>(
                value: me,
                onRetry: () =>
                    ref.read(subscriptionMeProvider.notifier).refresh(),
                builder: (context, status) {
                  if (!paywallOn || status.isPaid) {
                    return const SizedBox.shrink();
                  }
                  return LexivoButton(
                    label: 'Upgrade',
                    onPressed: () =>
                        context.go(RouteGuards.subscriptionUpgrade),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
