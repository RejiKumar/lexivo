import 'package:flutter/widgets.dart';
import 'package:lexivo/core/ads/ads_provider.dart';
import 'package:lexivo/core/ads/ads_unit_ids.dart';
import 'package:lexivo/core/ads/admob_banner_widget.dart';
import 'package:lexivo/core/ads/admob_sdk.dart';
import 'package:lexivo/core/config/app_config.dart';

/// AdMob-backed [AdsProvider]. Uses Google test unit IDs unless production IDs
/// are enabled via [AppConfig.adsUseProductionIds].
///
/// Does not initialize the SDK until [initialize] runs with allowable consent.
/// Web should bind [NoOpAdsProvider] instead (see factory).
class AdMobAdsProvider implements AdsProvider {
  AdMobAdsProvider({AdMobSdk? sdk}) : _sdk = sdk ?? createAdMobSdk();

  final AdMobSdk _sdk;

  bool _suppressed = false;
  bool _initialized = false;
  AdsConsentStatus _consent = AdsConsentStatus.unknown;
  int _personalizedLoadAttempts = 0;
  int _blockedPersonalizedLoads = 0;

  bool get isInitialized => _initialized;

  int get personalizedLoadAttempts => _personalizedLoadAttempts;

  int get blockedPersonalizedLoads => _blockedPersonalizedLoads;

  @override
  bool get isAdsSuppressed => _suppressed;

  bool get _mayLoadAds {
    if (_suppressed || !_initialized) return false;
    return _consent == AdsConsentStatus.obtained ||
        _consent == AdsConsentStatus.notRequired ||
        _consent == AdsConsentStatus.denied;
  }

  @override
  bool get canRequestPersonalizedAds {
    if (AppConfig.childDirected) return false;
    if (_suppressed) return false;
    return _consent == AdsConsentStatus.obtained ||
        _consent == AdsConsentStatus.notRequired;
  }

  /// Records a personalized inventory request; returns whether it is allowed.
  bool tryRequestPersonalizedInventory() {
    _personalizedLoadAttempts++;
    if (!canRequestPersonalizedAds) {
      _blockedPersonalizedLoads++;
      return false;
    }
    return true;
  }

  @override
  Future<void> initialize({required AdsConsentStatus consent}) async {
    _consent = consent;
    if (_suppressed) {
      _initialized = true;
      return;
    }
    if (consent == AdsConsentStatus.required ||
        consent == AdsConsentStatus.unknown) {
      // Do not init Mobile Ads SDK until consent flow completes.
      _initialized = true;
      return;
    }

    await _sdk.initialize(
      childDirected: AppConfig.childDirected,
      requestPersonalized: canRequestPersonalizedAds,
    );
    _initialized = true;
  }

  @override
  Future<void> showAppOpen() async {
    if (!_mayLoadAds) return;
    tryRequestPersonalizedInventory();
    if (!canRequestPersonalizedAds && _consent != AdsConsentStatus.denied) {
      return;
    }
    await _sdk.showAppOpen(adUnitId: AdsUnitIds.appOpen);
  }

  @override
  Widget banner({required String placementId}) {
    if (!_mayLoadAds) return const SizedBox.shrink();
    final personalized = tryRequestPersonalizedInventory();
    // Non-personalized still allowed when consent is denied.
    if (!personalized && _consent != AdsConsentStatus.denied) {
      return const SizedBox.shrink();
    }
    return AdMobBannerWidget(
      key: ValueKey('admob-banner-$placementId'),
      adUnitId: AdsUnitIds.banner,
      nonPersonalizedOnly: !personalized || AppConfig.childDirected,
      sdk: _sdk,
    );
  }

  @override
  Widget native({required String placementId}) {
    if (!_mayLoadAds) return const SizedBox.shrink();
    final personalized = tryRequestPersonalizedInventory();
    if (!personalized && _consent != AdsConsentStatus.denied) {
      return const SizedBox.shrink();
    }
    // Medium-rectangle creatives stand in for "trending" native until a
    // platform NativeAd factory is registered.
    return _sdk.createTrending(
      adUnitId: AdsUnitIds.mediumRectangle,
      nonPersonalizedOnly: !personalized || AppConfig.childDirected,
    );
  }

  @override
  Future<RewardResult?> showRewarded({required String placementId}) async {
    if (!_mayLoadAds) return null;
    final personalized = tryRequestPersonalizedInventory();
    if (!personalized && _consent != AdsConsentStatus.denied) return null;
    return _sdk.showRewarded(adUnitId: AdsUnitIds.rewarded);
  }

  @override
  Future<void> showInterstitial({required String placementId}) async {
    if (!_mayLoadAds) return;
    final personalized = tryRequestPersonalizedInventory();
    if (!personalized && _consent != AdsConsentStatus.denied) return;
    await _sdk.showInterstitial(adUnitId: AdsUnitIds.interstitial);
  }

  @override
  void setAdsSuppressed(bool suppressed) {
    _suppressed = suppressed;
  }
}
