/// Translation feature public surface — ONLY import allowed outside this feature.
library;

export 'presentation/providers/translation_providers.dart'
    show
        translationResultProvider,
        translationRepositoryProvider,
        translationJobPollerProvider,
        translationCoreOverrides,
        TranslationResultNotifier;
export 'presentation/screens/translation_screen.dart';
export 'domain/entities/translation_view.dart';
export 'domain/usecases/translation_usecases.dart'
    show
        supportedTranslationLangs,
        isSupportedTranslationPair,
        isTranslationStatusTerminal;
