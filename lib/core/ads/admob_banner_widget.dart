import 'package:flutter/widgets.dart';
import 'package:lexivo/core/ads/admob_sdk.dart';

/// Banner host that delegates to [AdMobSdk.createBanner].
class AdMobBannerWidget extends StatelessWidget {
  const AdMobBannerWidget({
    super.key,
    required this.adUnitId,
    required this.nonPersonalizedOnly,
    required this.sdk,
  });

  final String adUnitId;
  final bool nonPersonalizedOnly;
  final AdMobSdk sdk;

  @override
  Widget build(BuildContext context) {
    return sdk.createBanner(
      adUnitId: adUnitId,
      nonPersonalizedOnly: nonPersonalizedOnly,
    );
  }
}
