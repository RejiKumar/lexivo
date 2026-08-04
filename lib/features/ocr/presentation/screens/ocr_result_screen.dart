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
import 'package:lexivo/features/ocr/domain/entities/ocr_result_view.dart';
import 'package:lexivo/features/ocr/presentation/providers/ocr_providers.dart';

/// OCR result — Lexivo* + AsyncValueView only.
class OcrResultScreen extends ConsumerWidget {
  const OcrResultScreen({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(ocrResultProvider(documentId));
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
                    onPressed: () => context.go(RouteGuards.documents),
                    tooltip: 'Back to documents',
                  ),
                  Expanded(
                    child: Text(
                      'OCR result',
                      style: LexivoTypography.headline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LexivoSpacing.md),
              Expanded(
                child: AsyncValueView<OcrResultView>(
                  value: result,
                  onRetry: () =>
                      ref.read(ocrResultProvider(documentId).notifier).retry(),
                  loading: const Padding(
                    padding: EdgeInsets.all(LexivoSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LexivoSkeleton(
                          variant: LexivoSkeletonVariant.line,
                          width: 220,
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
                        SizedBox(height: LexivoSpacing.sm),
                        LexivoSkeleton(
                          variant: LexivoSkeletonVariant.line,
                          width: 180,
                        ),
                        SizedBox(height: LexivoSpacing.md),
                        Text('Processing document…'),
                      ],
                    ),
                  ),
                  builder: (context, view) {
                    if (!view.hasExtractedText) {
                      return LexivoEmptyState(
                        title: 'No text extracted',
                        description:
                            'OCR finished but no text was found in this document.',
                        icon: Icons.description_outlined,
                      );
                    }
                    return SingleChildScrollView(
                      child: SelectableText(
                        view.extractedText!,
                        style: LexivoTypography.body.copyWith(
                          color: colors.contentPrimary,
                        ),
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
