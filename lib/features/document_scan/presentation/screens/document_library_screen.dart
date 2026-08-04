import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/document_card.dart';
import 'package:lexivo/core/design_system/components/empty_state.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';
import 'package:lexivo/core/design_system/tokens/typography.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/widgets/async_value_view.dart';
import 'package:lexivo/features/document_scan/presentation/document_status_ui.dart';
import 'package:lexivo/features/document_scan/presentation/providers/document_providers.dart';

/// Document library — LexivoDocumentCard + AsyncValueView only.
class DocumentLibraryScreen extends ConsumerWidget {
  const DocumentLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(documentLibraryProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LexivoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Documents', style: LexivoTypography.headline),
              const SizedBox(height: LexivoSpacing.md),
              Expanded(
                child: AsyncValueView<List<Document>>(
                  value: library,
                  onRetry: () =>
                      ref.read(documentLibraryProvider.notifier).refresh(),
                  builder: (context, docs) {
                    if (docs.isEmpty) {
                      return LexivoEmptyState(
                        title: 'No documents yet',
                        description:
                            'Scan or upload a document to get started.',
                        icon: Icons.description_outlined,
                        ctaLabel: 'Scan document',
                        onCtaPressed: () =>
                            context.go(RouteGuards.documentScan),
                      );
                    }
                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: LexivoSpacing.sm),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        return LexivoDocumentCard(
                          name: doc.title?.isNotEmpty == true
                              ? doc.title!
                              : 'Untitled',
                          status: toLexivoDocumentStatus(doc.status),
                          timestamp: formatDocumentTimestamp(doc.createdAt),
                          onTap: () =>
                              context.go(RouteGuards.documentOcr(doc.id)),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: LexivoSpacing.md),
              LexivoButton(
                label: 'Scan document',
                onPressed: () => context.go(RouteGuards.documentScan),
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
