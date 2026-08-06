import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/ads/ads_placements.dart';
import 'package:lexivo/core/ads/ads_provider.dart';
import 'package:lexivo/core/ads/ads_providers.dart';
import 'package:lexivo/core/ads/lexivo_ad_banner.dart';
import 'package:lexivo/core/design_system/tokens/spacing.dart';

/// Medium-rectangle / native-style "trending" slot for primary menus.
///
/// Collapses when ads are off, suppressed, or consent blocks inventory.
class LexivoTrendingAd extends ConsumerWidget {
  const LexivoTrendingAd({
    super.key,
    this.placementId = AdsPlacements.documentLibraryTrending,
  });

  final String placementId;

  static const Key visibleSlotKey = Key('lexivo_trending_ad_slot');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(enableAdsFlagProvider)) {
      return const SizedBox.shrink();
    }
    if (ref.watch(adsSuppressedProvider)) {
      return const SizedBox.shrink();
    }

    final consent = ref.watch(adsConsentStatusProvider);
    if (consent == AdsConsentStatus.required ||
        consent == AdsConsentStatus.unknown) {
      return const SizedBox.shrink();
    }

    final ads = ref.watch(adsProviderProvider);
    return KeyedSubtree(
      key: visibleSlotKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LexivoSpacing.md,
          vertical: LexivoSpacing.sm,
        ),
        child: ads.native(placementId: placementId),
      ),
    );
  }
}

/// Shared chrome for authenticated primary menus: trending on top, banner below.
class LexivoMenuAdsScaffold extends ConsumerWidget {
  const LexivoMenuAdsScaffold({
    super.key,
    required this.body,
    required this.bannerPlacementId,
    required this.trendingPlacementId,
  });

  final Widget body;
  final String bannerPlacementId;
  final String trendingPlacementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        LexivoTrendingAd(placementId: trendingPlacementId),
        Expanded(child: body),
        LexivoAdBanner(placementId: bannerPlacementId),
      ],
    );
  }
}
