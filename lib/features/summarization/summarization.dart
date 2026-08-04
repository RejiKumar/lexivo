/// Summarization feature public surface — ONLY import allowed outside this feature.
library;

export 'presentation/providers/summarization_providers.dart'
    show
        summaryResultProvider,
        summarizationRepositoryProvider,
        summaryJobPollerProvider,
        summarizationCoreOverrides,
        SummaryResultNotifier;
export 'presentation/screens/summary_screen.dart';
export 'domain/entities/summary_view.dart';
