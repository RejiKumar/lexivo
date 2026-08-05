import 'package:flutter/foundation.dart';
import 'package:lexivo/core/ads/ads_provider.dart';
import 'package:lexivo/core/ads/noop_ads_provider.dart';
import 'package:lexivo/core/config/app_config.dart';

import 'create_ads_provider_stub.dart'
    if (dart.library.io) 'create_ads_provider_io.dart' as impl;

/// Selects [NoOpAdsProvider] when ads are disabled or on web; AdMob on mobile IO.
///
/// Web stays NoOp even if `ENABLE_ADS=true` (AdMob is mobile-first).
AdsProvider createDefaultAdsProvider() {
  if (!AppConfig.enableAds || kIsWeb) {
    return NoOpAdsProvider();
  }
  return impl.createEnabledAdsProvider();
}
