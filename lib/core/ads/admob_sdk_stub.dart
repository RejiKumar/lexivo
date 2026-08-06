import 'package:flutter/widgets.dart';
import 'package:lexivo/core/ads/admob_sdk.dart';
import 'package:lexivo/core/ads/ads_provider.dart';

/// Web / unsupported platform — no AdMob SDK.
class StubAdMobSdk implements AdMobSdk {
  @override
  Future<void> initialize({
    required bool childDirected,
    required bool requestPersonalized,
  }) async {}

  @override
  Widget createBanner({
    required String adUnitId,
    required bool nonPersonalizedOnly,
  }) =>
      const SizedBox.shrink();

  @override
  Widget createTrending({
    required String adUnitId,
    required bool nonPersonalizedOnly,
  }) =>
      const SizedBox.shrink();

  @override
  Future<void> showAppOpen({required String adUnitId}) async {}

  @override
  Future<RewardResult?> showRewarded({required String adUnitId}) async => null;

  @override
  Future<void> showInterstitial({required String adUnitId}) async {}
}

AdMobSdk createAdMobSdkImpl() => StubAdMobSdk();
