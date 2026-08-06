import 'package:flutter/widgets.dart';
import 'package:lexivo/core/ads/ads_provider.dart';

import 'admob_sdk_stub.dart'
    if (dart.library.io) 'admob_sdk_gma.dart' as impl;

/// Thin SDK facade so AdMob platform code stays behind conditional imports.
abstract class AdMobSdk {
  Future<void> initialize({
    required bool childDirected,
    required bool requestPersonalized,
  });

  Widget createBanner({
    required String adUnitId,
    required bool nonPersonalizedOnly,
  });

  /// Medium-rectangle inventory used for "trending" menu placements.
  Widget createTrending({
    required String adUnitId,
    required bool nonPersonalizedOnly,
  });

  Future<void> showAppOpen({required String adUnitId});

  Future<RewardResult?> showRewarded({required String adUnitId});

  Future<void> showInterstitial({required String adUnitId});
}

/// Real GMA on `dart.library.io`; stub on web.
AdMobSdk createAdMobSdk() => impl.createAdMobSdkImpl();
