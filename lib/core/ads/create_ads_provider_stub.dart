import 'package:lexivo/core/ads/ads_provider.dart';
import 'package:lexivo/core/ads/noop_ads_provider.dart';

/// Web fallback — never binds AdMob.
AdsProvider createEnabledAdsProvider() => NoOpAdsProvider();
