import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/ads/ads_placements.dart';
import 'package:lexivo/core/ads/ads_provider.dart';
import 'package:lexivo/core/ads/ads_providers.dart';

/// Feature-facing banner slot. Empty when ads are off, suppressed, or consent
/// blocks inventory. Features compose this — they never import AdMob.
class LexivoAdBanner extends ConsumerWidget {
  const LexivoAdBanner({
    super.key,
    this.placementId = AdsPlacements.documentLibraryBanner,
  });

  final String placementId;

  static const Key visibleSlotKey = Key('lexivo_ad_banner_slot');

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
      child: ads.banner(placementId: placementId),
    );
  }
}
