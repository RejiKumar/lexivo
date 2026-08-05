import 'package:flutter/widgets.dart';
import 'package:lexivo/core/ads/ads_provider.dart';
import 'package:lexivo/core/config/app_config.dart';

/// Zero-SDK provider used when [AppConfig.enableAds] is false, on web, or in tests.
class NoOpAdsProvider implements AdsProvider {
  // Public named arg `suppressed` (not private initializing formal).
  // ignore: prefer_initializing_formals
  NoOpAdsProvider({bool suppressed = false}) : _suppressed = suppressed;

  bool _suppressed;
  AdsConsentStatus _consent = AdsConsentStatus.unknown;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  AdsConsentStatus get lastConsent => _consent;

  @override
  bool get isAdsSuppressed => _suppressed;

  @override
  bool get canRequestPersonalizedAds {
    if (AppConfig.childDirected) return false;
    if (_suppressed) return false;
    return _consent == AdsConsentStatus.obtained ||
        _consent == AdsConsentStatus.notRequired;
  }

  @override
  Future<void> initialize({required AdsConsentStatus consent}) async {
    _consent = consent;
    _initialized = true;
  }

  @override
  Future<void> showAppOpen() async {}

  @override
  Widget banner({required String placementId}) => const SizedBox.shrink();

  @override
  Widget native({required String placementId}) => const SizedBox.shrink();

  @override
  Future<RewardResult?> showRewarded({required String placementId}) async =>
      null;

  @override
  Future<void> showInterstitial({required String placementId}) async {}

  @override
  void setAdsSuppressed(bool suppressed) {
    _suppressed = suppressed;
  }
}
