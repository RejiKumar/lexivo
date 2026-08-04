import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/components/skeleton_loader.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/widgets/async_value_view.dart';
import 'package:lexivo/features/summarization/domain/entities/summary_view.dart';
import 'package:lexivo/features/summarization/presentation/providers/summarization_providers.dart';

/// Summary screen — Lexivo* + AsyncValueView only.
class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(summaryResultProvider(documentId));
    final colors = Theme.of(context).extension<LexivoColors>()!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LexivoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () =>
                        context.go(RouteGuards.documentOcr(documentId)),
                    tooltip: 'Back to OCR',
                  ),
                  Expanded(
                    child: Text(
                      'Summary',
                      style: LexivoTypography.headline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LexivoSpacing.md),
              Expanded(
                child: AsyncValueView<SummaryView>(
                  value: result,
                  onRetry: () => ref
                      .read(summaryResultProvider(documentId).notifier)
                      .retry(),
                  loading: const Padding(
                    padding: EdgeInsets.all(LexivoSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LexivoSkeleton(
                          variant: LexivoSkeletonVariant.line,
                          width: 160,
                        ),
                        SizedBox(height: LexivoSpacing.sm),
                        LexivoSkeleton(
                          variant: LexivoSkeletonVariant.line,
                          width: double.infinity,
                        ),
                        SizedBox(height: LexivoSpacing.sm),
                        LexivoSkeleton(
                          variant: LexivoSkeletonVariant.line,
                          width: double.infinity,
                        ),
                        SizedBox(height: LexivoSpacing.md),
                        LexivoSkeleton(
                          variant: LexivoSkeletonVariant.line,
                          width: 180,
                        ),
                        SizedBox(height: LexivoSpacing.sm),
                        LexivoSkeleton(
                          variant: LexivoSkeletonVariant.line,
                          width: double.infinity,
                        ),
                        SizedBox(height: LexivoSpacing.sm),
                        LexivoSkeleton(
                          variant: LexivoSkeletonVariant.line,
                          width: double.infinity,
                        ),
                        SizedBox(height: LexivoSpacing.md),
                        Text('Generating summaries…'),
                      ],
                    ),
                  ),
                  builder: (context, view) {
                    if (!view.hasSummaries) {
                      return LexivoEmptyState(
                        title: 'No summaries yet',
                        description:
                            'Summarization finished but no short or detailed text was returned.',
                        icon: Icons.notes_outlined,
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Short summary',
                            style: LexivoTypography.title.copyWith(
                              color: colors.contentPrimary,
                            ),
                          ),
                          const SizedBox(height: LexivoSpacing.sm),
                          SelectableText(
                            view.shortSummary!,
                            style: LexivoTypography.body.copyWith(
                              color: colors.contentPrimary,
                            ),
                          ),
                          const SizedBox(height: LexivoSpacing.xl),
                          Text(
                            'Detailed summary',
                            style: LexivoTypography.title.copyWith(
                              color: colors.contentPrimary,
                            ),
                          ),
                          const SizedBox(height: LexivoSpacing.sm),
                          SelectableText(
                            view.detailedSummary!,
                            style: LexivoTypography.body.copyWith(
                              color: colors.contentPrimary,
                            ),
                          ),
                        ],
                      ),
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
}
