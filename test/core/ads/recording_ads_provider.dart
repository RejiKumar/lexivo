import 'package:flutter/widgets.dart';
import 'package:lexivo/core/ads/ads_provider.dart';
import 'package:lexivo/core/ads/admob_sdk.dart';
import 'package:lexivo/core/config/app_config.dart';

/// Test double — renders a marked slot when ads would show.
class RecordingAdsProvider implements AdsProvider {
  RecordingAdsProvider({
    this._consent = AdsConsentStatus.notRequired,
  });

  AdsConsentStatus _consent;
  bool _suppressed = false;
  bool _initialized = false;
  int bannerBuilds = 0;
  int nativeBuilds = 0;
  int personalizedAttempts = 0;
  int blockedPersonalized = 0;
  int initializeCalls = 0;

  static const Key bannerKey = Key('recording_ad_banner');

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
    initializeCalls++;
    _consent = consent;
    _initialized = true;
  }

  @override
  Future<void> showAppOpen() async {}

  @override
  Widget banner({required String placementId}) {
    bannerBuilds++;
    if (_suppressed || !_initialized) return const SizedBox.shrink();
    if (_consent == AdsConsentStatus.required ||
        _consent == AdsConsentStatus.unknown) {
      return const SizedBox.shrink();
    }
    personalizedAttempts++;
    if (!canRequestPersonalizedAds &&
        _consent != AdsConsentStatus.denied) {
      blockedPersonalized++;
      return const SizedBox.shrink();
    }
    if (!canRequestPersonalizedAds) {
      blockedPersonalized++;
    }
    return const SizedBox(key: bannerKey, height: 50, width: double.infinity);
  }

  @override
  Widget native({required String placementId}) {
    nativeBuilds++;
    if (_suppressed || !_initialized) return const SizedBox.shrink();
    if (_consent == AdsConsentStatus.required ||
        _consent == AdsConsentStatus.unknown) {
      return const SizedBox.shrink();
    }
    personalizedAttempts++;
    if (!canRequestPersonalizedAds &&
        _consent != AdsConsentStatus.denied) {
      blockedPersonalized++;
      return const SizedBox.shrink();
    }
    return const SizedBox(
      key: Key('recording_trending_ad'),
      height: 120,
      width: double.infinity,
    );
  }

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

/// Records SDK calls without touching Google Mobile Ads.
class RecordingAdMobSdk implements AdMobSdk {
  int initializeCalls = 0;
  bool? lastChildDirected;
  bool? lastRequestPersonalized;

  @override
  Future<void> initialize({
    required bool childDirected,
    required bool requestPersonalized,
  }) async {
    initializeCalls++;
    lastChildDirected = childDirected;
    lastRequestPersonalized = requestPersonalized;
  }

  @override
  Widget createBanner({
    required String adUnitId,
    required bool nonPersonalizedOnly,
  }) =>
      const SizedBox(key: Key('stub_sdk_banner'), height: 50);

  @override
  Widget createTrending({
    required String adUnitId,
    required bool nonPersonalizedOnly,
  }) =>
      const SizedBox(key: Key('stub_sdk_trending'), height: 120);

  @override
  Future<void> showAppOpen({required String adUnitId}) async {}

  @override
  Future<RewardResult?> showRewarded({required String adUnitId}) async => null;

  @override
  Future<void> showInterstitial({required String adUnitId}) async {}
}
