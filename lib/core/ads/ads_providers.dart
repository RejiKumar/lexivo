import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexivo/core/ads/ads_consent.dart';
import 'package:lexivo/core/ads/ads_provider.dart';
import 'package:lexivo/core/ads/create_ads_provider.dart';
import 'package:lexivo/core/ads/create_consent_gateway.dart';
import 'package:lexivo/core/config/app_config.dart';

/// Overrideable mirror of [AppConfig.enableAds] for widget tests.
final enableAdsFlagProvider = Provider<bool>((ref) => AppConfig.enableAds);

/// Premium / operator suppress. Default false; subscription overrides when tier
/// is paid. Features must not import AdMob — they feed this provider only.
final adsSuppressedProvider = Provider<bool>((ref) => false);

final adsConsentGatewayProvider = Provider<AdsConsentGateway>((ref) {
  return createDefaultConsentGateway();
});

final adsConsentStatusProvider =
    StateProvider<AdsConsentStatus>((ref) => AdsConsentStatus.unknown);

/// Underlying adapter instance (stable for the ProviderScope lifetime).
final adsProviderProvider = Provider<AdsProvider>((ref) {
  final ads = createDefaultAdsProvider();
  ads.setAdsSuppressed(ref.watch(adsSuppressedProvider));
  ref.listen<bool>(adsSuppressedProvider, (_, next) {
    ads.setAdsSuppressed(next);
  });
  return ads;
});

/// Resolves consent and initializes the ads adapter once at app start.
class AdsBootstrap extends ConsumerStatefulWidget {
  const AdsBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AdsBootstrap> createState() => _AdsBootstrapState();
}

class _AdsBootstrapState extends ConsumerState<AdsBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (!ref.read(enableAdsFlagProvider)) return;
    final gateway = ref.read(adsConsentGatewayProvider);
    final status = await gateway.resolveConsent();
    if (!mounted) return;
    // Initialize before publishing consent: slots read the adapter's readiness
    // synchronously, and nothing rebuilds them once the SDK finishes later.
    await ref.read(adsProviderProvider).initialize(consent: status);
    if (!mounted) return;
    ref.read(adsConsentStatusProvider.notifier).state = status;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
