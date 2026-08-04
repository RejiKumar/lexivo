/// Document scan feature public surface — ONLY import allowed outside this feature.
library;

export 'domain/entities/document_input.dart';
export 'presentation/providers/document_providers.dart'
    show
        documentLibraryProvider,
        documentScanControllerProvider,
        documentRepositoryProvider,
        documentInputSourceProvider,
        documentScanCoreOverrides,
        DocumentScanState,
        DocumentScanController,
        DocumentLibraryNotifier;
export 'presentation/screens/document_library_screen.dart';
export 'presentation/screens/document_scan_screen.dart';
