import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lexivo/core/ads/ads_consent.dart';
import 'package:lexivo/core/ads/ads_provider.dart';
import 'package:lexivo/core/config/app_config.dart';

/// Consent when UMP itself cannot be reached (emulator, unregistered debug
/// device, no network). Release builds and builds using production ad units stay
/// `unknown` so no inventory loads; debug builds on Google test units carry no
/// user data, so they may render instead of leaving every slot blank.
@visibleForTesting
AdsConsentStatus resolveUnreachableConsent({
  required bool debugBuild,
  required bool productionAdUnits,
}) {
  if (debugBuild && !productionAdUnits) {
    return AdsConsentStatus.notRequired;
  }
  return AdsConsentStatus.unknown;
}

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

    var unreachable = false;
    try {
      final completer = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () {
          if (!completer.isCompleted) completer.complete();
        },
        (_) {
          unreachable = true;
          if (!completer.isCompleted) completer.complete();
        },
      );
      await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () => unreachable = true,
      );

      await ConsentForm.loadAndShowConsentFormIfRequired((_) {});

      final canRequest = await ConsentInformation.instance.canRequestAds();
      final raw = await ConsentInformation.instance.getConsentStatus();
      _status = _mapStatus(raw, canRequestAds: canRequest);
    } on Object {
      // Fail closed for personalized; treat as unknown so UI stays empty.
      unreachable = true;
      _status = AdsConsentStatus.unknown;
    }

    if (unreachable && _status == AdsConsentStatus.unknown) {
      _status = resolveUnreachableConsent(
        debugBuild: kDebugMode,
        productionAdUnits: AppConfig.adsUseProductionIds,
      );
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
