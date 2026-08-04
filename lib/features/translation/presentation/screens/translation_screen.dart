import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/design_system/components/skeleton_loader.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/widgets/async_value_view.dart';
import 'package:lexivo/features/translation/domain/entities/translation_view.dart';
import 'package:lexivo/features/translation/domain/usecases/translation_usecases.dart';
import 'package:lexivo/features/translation/presentation/providers/translation_providers.dart';

/// Translation screen — Lexivo* + AsyncValueView + language pickers.
class TranslationScreen extends ConsumerStatefulWidget {
  const TranslationScreen({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends ConsumerState<TranslationScreen> {
  String _sourceLang = 'en';
  String _targetLang = 'es';
  String? _langError;

  List<String> get _targetOptions {
    if (_sourceLang == 'en') {
      return supportedTranslationLangs.where((c) => c != 'en').toList();
    }
    return const ['en'];
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(translationResultProvider(widget.documentId));
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
                        context.go(RouteGuards.documentSummary(widget.documentId)),
                    tooltip: 'Back to summary',
                  ),
                  Expanded(
                    child: Text(
                      'Translation',
                      style: LexivoTypography.headline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LexivoSpacing.md),
              Expanded(
                child: AsyncValueView<TranslationView>(
                  value: result,
                  onRetry: () => ref
                      .read(
                        translationResultProvider(widget.documentId).notifier,
                      )
                      .retry(
                        sourceLang: _sourceLang,
                        targetLang: _targetLang,
                      ),
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
                        Text('Translating…'),
                      ],
                    ),
                  ),
                  builder: (context, view) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _LanguagePickers(
                            sourceLang: _sourceLang,
                            targetLang: _targetLang,
                            targetOptions: _targetOptions,
                            onSourceChanged: (value) {
                              setState(() {
                                _sourceLang = value;
                                _langError = null;
                                if (value != 'en') {
                                  _targetLang = 'en';
                                } else if (_targetLang == 'en') {
                                  _targetLang = 'es';
                                }
                              });
                            },
                            onTargetChanged: (value) {
                              setState(() {
                                _targetLang = value;
                                _langError = null;
                              });
                            },
                          ),
                          const SizedBox(height: LexivoSpacing.md),
                          if (_langError != null) ...[
                            LexivoErrorBanner(message: _langError!),
                            const SizedBox(height: LexivoSpacing.md),
                          ],
                          LexivoButton(
                            label: view.translationStatus ==
                                    TranslationStatus.ready
                                ? 'Translate again'
                                : 'Translate',
                            onPressed: () => _onTranslate(),
                          ),
                          const SizedBox(height: LexivoSpacing.xl),
                          if (view.translationStatus ==
                              TranslationStatus.ready) ...[
                            if (view.sourceLang != null &&
                                view.targetLang != null)
                              Text(
                                '${view.sourceLang!.toUpperCase()} → ${view.targetLang!.toUpperCase()}',
                                style: LexivoTypography.title.copyWith(
                                  color: colors.contentPrimary,
                                ),
                              ),
                            const SizedBox(height: LexivoSpacing.sm),
                            if (!view.hasTranslation)
                              const LexivoEmptyState(
                                title: 'No translation yet',
                                description:
                                    'Translation finished but no text was returned.',
                                icon: Icons.translate_outlined,
                              )
                            else
                              SelectableText(
                                view.translatedText!,
                                style: LexivoTypography.body.copyWith(
                                  color: colors.contentPrimary,
                                ),
                              ),
                          ] else if (view.translationStatus ==
                              TranslationStatus.idle)
                            Text(
                              'Choose languages and tap Translate.',
                              style: LexivoTypography.body.copyWith(
                                color: colors.contentSecondary,
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

  Future<void> _onTranslate() async {
    if (!isSupportedTranslationPair(_sourceLang, _targetLang)) {
      setState(() {
        _langError =
            'Unsupported language pair; v1 requires EN↔ES,FR,DE,HI,PT';
      });
      return;
    }
    setState(() => _langError = null);
    await ref
        .read(translationResultProvider(widget.documentId).notifier)
        .requestTranslation(
          sourceLang: _sourceLang,
          targetLang: _targetLang,
        );
  }
}

class _LanguagePickers extends StatelessWidget {
  const _LanguagePickers({
    required this.sourceLang,
    required this.targetLang,
    required this.targetOptions,
    required this.onSourceChanged,
    required this.onTargetChanged,
  });

  final String sourceLang;
  final String targetLang;
  final List<String> targetOptions;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<String> onTargetChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    return Row(
      children: [
        Expanded(
          child: _LangDropdown(
            label: 'From',
            value: sourceLang,
            options: supportedTranslationLangs,
            onChanged: onSourceChanged,
            colors: colors,
          ),
        ),
        const SizedBox(width: LexivoSpacing.md),
        Expanded(
          child: _LangDropdown(
            label: 'To',
            value: targetOptions.contains(targetLang)
                ? targetLang
                : targetOptions.first,
            options: targetOptions,
            onChanged: onTargetChanged,
            colors: colors,
          ),
        ),
      ],
    );
  }
}

class _LangDropdown extends StatelessWidget {
  const _LangDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.colors,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final LexivoColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: LexivoTypography.label.copyWith(color: colors.contentSecondary),
        ),
        const SizedBox(height: LexivoSpacing.xs),
        DropdownButtonFormField<String>(
          value: value,
          items: [
            for (final code in options)
              DropdownMenuItem(
                value: code,
                child: Text(code.toUpperCase()),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
