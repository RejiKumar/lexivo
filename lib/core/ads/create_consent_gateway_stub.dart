import 'package:lexivo/core/ads/ads_consent.dart';
import 'package:lexivo/core/ads/ads_provider.dart';

AdsConsentGateway createEnabledConsentGateway() =>
    StubAdsConsentGateway(status: AdsConsentStatus.notRequired);
