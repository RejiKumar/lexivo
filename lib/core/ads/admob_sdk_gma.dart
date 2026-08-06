import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lexivo/core/ads/admob_sdk.dart';
import 'package:lexivo/core/ads/ads_provider.dart';

/// Google Mobile Ads SDK binding (Android / iOS). Desktop no-ops safely.
class GoogleMobileAdsSdk implements AdMobSdk {
  bool _ready = false;

  @override
  Future<void> initialize({
    required bool childDirected,
    required bool requestPersonalized,
  }) async {
    try {
      await MobileAds.instance.initialize();
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // Hash from device log ("Use RequestConfiguration.Builder…
          // setTestDeviceIds") so Google serves test creatives reliably.
          testDeviceIds: const ['9AB4E1F97E05417E52785811E6603EA6'],
          tagForChildDirectedTreatment: childDirected
              ? TagForChildDirectedTreatment.yes
              : TagForChildDirectedTreatment.unspecified,
          tagForUnderAgeOfConsent: childDirected
              ? TagForUnderAgeOfConsent.yes
              : TagForUnderAgeOfConsent.unspecified,
          maxAdContentRating:
              childDirected ? MaxAdContentRating.g : MaxAdContentRating.pg,
        ),
      );
      _ready = true;
    } on Object {
      _ready = false;
    }
  }

  AdRequest _request({required bool nonPersonalizedOnly}) {
    if (nonPersonalizedOnly) {
      return const AdRequest(nonPersonalizedAds: true);
    }
    return const AdRequest();
  }

  @override
  Widget createBanner({
    required String adUnitId,
    required bool nonPersonalizedOnly,
  }) {
    if (!_ready) return const SizedBox.shrink();
    return _GmaBanner(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: _request(nonPersonalizedOnly: nonPersonalizedOnly),
    );
  }

  @override
  Widget createTrending({
    required String adUnitId,
    required bool nonPersonalizedOnly,
  }) {
    if (!_ready) return const SizedBox.shrink();
    return Center(
      child: _GmaBanner(
        adUnitId: adUnitId,
        size: AdSize.mediumRectangle,
        request: _request(nonPersonalizedOnly: nonPersonalizedOnly),
      ),
    );
  }

  @override
  Future<void> showAppOpen({required String adUnitId}) async {
    if (!_ready) return;
    final completer = Completer<void>();
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (_) {
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    return completer.future;
  }

  @override
  Future<RewardResult?> showRewarded({required String adUnitId}) async {
    if (!_ready) return null;
    final completer = Completer<RewardResult?>();
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete(null);
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete(null);
            },
          );
          ad.show(
            onUserEarnedReward: (_, reward) {
              if (!completer.isCompleted) {
                completer.complete(
                  RewardResult(type: reward.type, amount: reward.amount),
                );
              }
            },
          );
        },
        onAdFailedToLoad: (_) {
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
    return completer.future;
  }

  @override
  Future<void> showInterstitial({required String adUnitId}) async {
    if (!_ready) return;
    final completer = Completer<void>();
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (_) {
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    return completer.future;
  }
}

class _GmaBanner extends StatefulWidget {
  const _GmaBanner({
    required this.adUnitId,
    required this.request,
    this.size = AdSize.banner,
  });

  final String adUnitId;
  final AdRequest request;
  final AdSize size;

  @override
  State<_GmaBanner> createState() => _GmaBannerState();
}

class _GmaBannerState extends State<_GmaBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final ad = BannerAd(
      size: widget.size,
      adUnitId: widget.adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (kDebugMode) {
            debugPrint(
              'AdMob ${widget.size.width}x${widget.size.height} loaded '
              '(${widget.adUnitId})',
            );
          }
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            debugPrint(
              'AdMob banner failed (${widget.adUnitId}): '
              '${error.code} ${error.message}',
            );
          }
          ad.dispose();
          _ad = null;
        },
      ),
      request: widget.request,
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}

AdMobSdk createAdMobSdkImpl() => GoogleMobileAdsSdk();
