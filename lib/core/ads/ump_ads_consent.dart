import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lexivo/core/ads/ads_consent.dart';
import 'package:lexivo/core/ads/ads_provider.dart';
import 'package:lexivo/core/config/app_config.dart';

/// UMP consent via Google Mobile Ads. No-ops safely when the platform channel
/// is unavailable (desktop / tests without a device).
///
/// ATT: On iOS, UMP presents App Tracking Transparency when the advertising
/// identifier is used — no separate ATT package required for the basic path.
class UmpAdsConsentGateway implements AdsConsentGateway {
  AdsConsentStatus _status = AdsConsentStatus.unknown;

  @override
  bool get allowsPersonalizedAds {
    if (AppConfig.childDirected) return false;
    return _status == AdsConsentStatus.obtained ||
        _status == AdsConsentStatus.notRequired;
  }

  @override
  Future<AdsConsentStatus> resolveConsent() async {
    if (kIsWeb) {
      _status = AdsConsentStatus.notRequired;
      return _status;
    }

    try {
      final completer = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () {
          if (!completer.isCompleted) completer.complete();
        },
        (_) {
          if (!completer.isCompleted) completer.complete();
        },
      );
      await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {},
      );

      await ConsentForm.loadAndShowConsentFormIfRequired((_) {});

      final canRequest = await ConsentInformation.instance.canRequestAds();
      final raw = await ConsentInformation.instance.getConsentStatus();
      _status = _mapStatus(raw, canRequestAds: canRequest);
    } on Object {
      // Fail closed for personalized; treat as unknown so UI stays empty.
      _status = AdsConsentStatus.unknown;
    }
    return _status;
  }

  AdsConsentStatus _mapStatus(
    ConsentStatus raw, {
    required bool canRequestAds,
  }) {
    switch (raw) {
      case ConsentStatus.obtained:
        return AdsConsentStatus.obtained;
      case ConsentStatus.notRequired:
        return AdsConsentStatus.notRequired;
      case ConsentStatus.required:
        return canRequestAds
            ? AdsConsentStatus.denied
            : AdsConsentStatus.required;
      case ConsentStatus.unknown:
        return AdsConsentStatus.unknown;
    }
  }
}
