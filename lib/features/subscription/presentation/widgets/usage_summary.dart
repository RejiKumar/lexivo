import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/design_system/components/badge.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/widgets/async_value_view.dart';
import 'package:lexivo/features/subscription/domain/entities/subscription_status.dart';
import 'package:lexivo/features/subscription/presentation/providers/subscription_providers.dart';

/// Informational usage rows — safe with paywall flag off (no upgrade CTA).
class UsageSummary extends ConsumerWidget {
  const UsageSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(subscriptionMeProvider);
    return AsyncValueView<SubscriptionStatus>(
      value: me,
      onRetry: () => ref.read(subscriptionMeProvider.notifier).refresh(),
      builder: (context, status) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Usage', style: LexivoTypography.title),
                const SizedBox(width: LexivoSpacing.sm),
                LexivoBadge(
                  label: status.isPaid ? 'Paid' : 'Free',
                  variant: status.isPaid
                      ? LexivoBadgeVariant.success
                      : LexivoBadgeVariant.neutral,
                ),
              ],
            ),
            const SizedBox(height: LexivoSpacing.md),
            _UsageRow(label: 'Documents', bucket: status.documents),
            const SizedBox(height: LexivoSpacing.sm),
            _UsageRow(label: 'Chat messages', bucket: status.chatMessages),
            const SizedBox(height: LexivoSpacing.sm),
            _UsageRow(label: 'OCR pages', bucket: status.ocrPages),
          ],
        );
      },
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({required this.label, required this.bucket});

  final String label;
  final UsageBucket bucket;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: LexivoTypography.body)),
        Text(
          '${bucket.used} / ${bucket.limit} per ${bucket.period}',
          style: LexivoTypography.caption,
        ),
      ],
    );
  }
}
