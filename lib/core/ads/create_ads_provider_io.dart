import 'package:lexivo/core/ads/admob_ads_provider.dart';
import 'package:lexivo/core/ads/ads_provider.dart';

/// Mobile / desktop VM binding when `ENABLE_ADS` is true.
AdsProvider createEnabledAdsProvider() => AdMobAdsProvider();
