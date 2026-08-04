import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/design_system/components/skeleton_loader.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/widgets/async_value_view.dart';
import 'package:lexivo/features/pdf_export/domain/entities/export_job.dart';
import 'package:lexivo/features/pdf_export/presentation/providers/pdf_export_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// PDF export screen — section toggles + Lexivo* + JobPoller-driven state.
class PdfExportScreen extends ConsumerStatefulWidget {
  const PdfExportScreen({
    super.key,
    required this.documentId,
    this.launchUrlFn,
  });

  final String documentId;

  /// Injectable for tests — defaults to [launchUrl].
  final Future<bool> Function(Uri uri)? launchUrlFn;

  @override
  ConsumerState<PdfExportScreen> createState() => _PdfExportScreenState();
}

class _PdfExportScreenState extends ConsumerState<PdfExportScreen> {
  bool _includeSummary = true;
  bool _includeTranslation = false;
  bool _includeChat = false;
  String? _toggleError;
  bool _hintsLoaded = false;

  ExportSectionToggles get _toggles => ExportSectionToggles(
        includeSummary: _includeSummary,
        includeTranslation: _includeTranslation,
        includeChat: _includeChat,
      );

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(pdfExportProvider(widget.documentId));
    final colors = Theme.of(context).extension<LexivoColors>()!;

    ref.listen(pdfExportProvider(widget.documentId), (prev, next) {
      next.whenData((job) {
        if (job != null && !_hintsLoaded) {
          setState(() {
            _includeSummary = job.toggles.includeSummary;
            _includeTranslation = job.toggles.includeTranslation;
            _includeChat = job.toggles.includeChat;
            _hintsLoaded = true;
          });
        }
      });
    });

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
                        context.go(RouteGuards.documentChat(widget.documentId)),
                    tooltip: 'Back to chat',
                  ),
                  const Expanded(
                    child: Text(
                      'Export PDF',
                      style: LexivoTypography.headline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LexivoSpacing.md),
              Expanded(
                child: AsyncValueView<ExportJob?>(
                  value: result,
                  onRetry: () => ref
                      .read(pdfExportProvider(widget.documentId).notifier)
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
                        Text('Preparing PDF…'),
                      ],
                    ),
                  ),
                  builder: (context, job) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Choose sections to include',
                            style: LexivoTypography.title,
                          ),
                          const SizedBox(height: LexivoSpacing.sm),
                          Text(
                            'Summary, translation, and chat annotations are '
                            'assembled on the server.',
                            style: LexivoTypography.body.copyWith(
                              color: colors.contentSecondary,
                            ),
                          ),
                          const SizedBox(height: LexivoSpacing.md),
                          _SectionToggle(
                            label: 'Summary',
                            value: _includeSummary,
                            colors: colors,
                            onChanged: (v) => setState(() {
                              _includeSummary = v;
                              _toggleError = null;
                            }),
                          ),
                          _SectionToggle(
                            label: 'Translation',
                            value: _includeTranslation,
                            colors: colors,
                            onChanged: (v) => setState(() {
                              _includeTranslation = v;
                              _toggleError = null;
                            }),
                          ),
                          _SectionToggle(
                            label: 'Chat annotations',
                            value: _includeChat,
                            colors: colors,
                            onChanged: (v) => setState(() {
                              _includeChat = v;
                              _toggleError = null;
                            }),
                          ),
                          if (_toggleError != null) ...[
                            const SizedBox(height: LexivoSpacing.sm),
                            LexivoErrorBanner(
                              message: _toggleError!,
                              onRetry: null,
                            ),
                          ],
                          const SizedBox(height: LexivoSpacing.lg),
                          LexivoButton(
                            label: 'Export PDF',
                            onPressed: () {
                              if (!_toggles.anySelected) {
                                setState(() {
                                  _toggleError =
                                      'Select at least one section to export';
                                });
                                return;
                              }
                              setState(() => _toggleError = null);
                              ref
                                  .read(
                                    pdfExportProvider(widget.documentId)
                                        .notifier,
                                  )
                                  .requestExport(_toggles);
                            },
                          ),
                          if (job != null && job.isReady) ...[
                            const SizedBox(height: LexivoSpacing.lg),
                            LexivoButton(
                              label: 'Download PDF',
                              onPressed: () => _openSignedUrl(job.signedUrl!),
                            ),
                          ],
                          const SizedBox(height: LexivoSpacing.md),
                          _DocumentHints(documentId: widget.documentId),
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

  Future<void> _openSignedUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final launcher = widget.launchUrlFn ??
        ((Uri u) => launchUrl(u, mode: LaunchMode.externalApplication));
    await launcher(uri);
  }
}

class _SectionToggle extends StatelessWidget {
  const _SectionToggle({
    required this.label,
    required this.value,
    required this.colors,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final LexivoColors colors;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: LexivoTypography.body),
      value: value,
      activeThumbColor: colors.brandPrimary,
      onChanged: onChanged,
    );
  }
}

/// Soft readiness hints from core [Document] — no other-feature imports.
class _DocumentHints extends ConsumerWidget {
  const _DocumentHints({required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(apiClientProvider).getDocument(documentId),
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result == null) return const SizedBox.shrink();
        return result.when(
          success: (dto) {
            final summaryReady = dto.summaryStatus == 'ready';
            final translationReady = dto.translationStatus == 'ready';
            final colors = Theme.of(context).extension<LexivoColors>()!;
            return Text(
              'Hints: summary ${summaryReady ? 'ready' : 'not ready'}; '
              'translation ${translationReady ? 'ready' : 'not ready'}. '
              'OCR status: ${dto.status}.',
              style: LexivoTypography.caption.copyWith(
                color: colors.contentSecondary,
              ),
            );
          },
          onFailure: (_) => const SizedBox.shrink(),
        );
      },
    );
  }
}
