/// OCR feature public surface — ONLY import allowed outside this feature.
library;

export 'presentation/providers/ocr_providers.dart'
    show
        ocrResultProvider,
        ocrRepositoryProvider,
        ocrJobPollerProvider,
        ocrCoreOverrides,
        OcrResultNotifier;
export 'presentation/screens/ocr_result_screen.dart';
export 'domain/entities/ocr_result_view.dart';
