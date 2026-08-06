import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/ads/ads.dart';
import 'package:lexivo/core/design_system/tokens/breakpoints.dart';
import 'package:lexivo/features/document_scan/presentation/screens/_desktop_layout.dart';
import 'package:lexivo/features/document_scan/presentation/screens/_mobile_layout.dart';
import 'package:lexivo/features/document_scan/presentation/screens/_tablet_layout.dart';

/// Document library entry — selects layout by [LexivoBreakpoints].
///
/// All layouts share [documentLibraryProvider]; no business-logic forks.
/// Free-tier banner slot is composed via [LexivoAdBanner] (core/ads adapter).
class DocumentLibraryScreen extends ConsumerWidget {
  const DocumentLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakpoint =
        LexivoBreakpoints.resolve(MediaQuery.sizeOf(context).width);

    final body = switch (breakpoint) {
      LexivoBreakpoint.mobile => const DocumentLibraryMobileLayout(),
      LexivoBreakpoint.tablet => const DocumentLibraryTabletLayout(),
      LexivoBreakpoint.desktop => const DocumentLibraryDesktopLayout(),
    };

    return LexivoMenuAdsScaffold(
      bannerPlacementId: AdsPlacements.documentLibraryBanner,
      trendingPlacementId: AdsPlacements.documentLibraryTrending,
      body: body,
    );
  }
}
