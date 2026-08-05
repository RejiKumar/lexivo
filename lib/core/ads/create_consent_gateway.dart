import 'package:flutter/foundation.dart';
import 'package:lexivo/core/ads/ads_consent.dart';
import 'package:lexivo/core/ads/ads_provider.dart';
import 'package:lexivo/core/config/app_config.dart';

import 'create_consent_gateway_stub.dart'
    if (dart.library.io) 'create_consent_gateway_io.dart' as impl;

/// Stub when ads off / web; UMP on IO when ads enabled.
AdsConsentGateway createDefaultConsentGateway() {
  if (!AppConfig.enableAds || kIsWeb) {
    return StubAdsConsentGateway(status: AdsConsentStatus.notRequired);
  }
  return impl.createEnabledConsentGateway();
}
