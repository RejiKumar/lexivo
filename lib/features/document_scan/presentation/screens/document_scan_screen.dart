import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/design_system/components/snackbar.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/features/document_scan/domain/entities/document_input.dart';
import 'package:lexivo/features/document_scan/presentation/providers/document_providers.dart';

/// Capture / upload entry — Lexivo* only; no platform UI forks.
class DocumentScanScreen extends ConsumerWidget {
  const DocumentScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(documentScanControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LexivoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Scan document', style: LexivoTypography.headline),
              const SizedBox(height: LexivoSpacing.sm),
              Text(
                'Take a photo, pick one from your gallery, or upload a PDF. '
                'Same flow on every platform.',
                style: LexivoTypography.body,
              ),
              const SizedBox(height: LexivoSpacing.lg),
              if (scan.failure != null) ...[
                LexivoErrorBanner(message: scan.failure!.message),
                const SizedBox(height: LexivoSpacing.md),
              ],
              const Spacer(),
              LexivoButton(
                label: 'Take photo',
                loading: scan.isLoading,
                onPressed: scan.isLoading
                    ? null
                    : () => _start(
                          context,
                          ref,
                          DocumentInputPreference.camera,
                        ),
                fullWidth: true,
              ),
              const SizedBox(height: LexivoSpacing.sm),
              LexivoButton(
                label: 'Choose from gallery',
                variant: LexivoButtonVariant.secondary,
                loading: scan.isLoading,
                onPressed: scan.isLoading
                    ? null
                    : () => _start(
                          context,
                          ref,
                          DocumentInputPreference.gallery,
                        ),
                fullWidth: true,
              ),
              const SizedBox(height: LexivoSpacing.sm),
              LexivoButton(
                label: 'Upload file (PDF or image)',
                variant: LexivoButtonVariant.ghost,
                loading: scan.isLoading,
                onPressed: scan.isLoading
                    ? null
                    : () => _start(
                          context,
                          ref,
                          DocumentInputPreference.file,
                        ),
                fullWidth: true,
              ),
              const SizedBox(height: LexivoSpacing.md),
              LexivoButton(
                label: 'Back to library',
                variant: LexivoButtonVariant.ghost,
                onPressed: () => context.go(RouteGuards.documents),
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _start(
    BuildContext context,
    WidgetRef ref,
    DocumentInputPreference preference,
  ) async {
    final result = await ref
        .read(documentScanControllerProvider.notifier)
        .startScan(preference: preference);
    if (!context.mounted) return;
    result.when(
      success: (_) {
        LexivoSnackbar.show(
          context,
          message: 'Document uploaded',
          variant: LexivoSnackbarVariant.success,
        );
        context.go(RouteGuards.documents);
      },
      onFailure: (_) {},
    );
  }
}
