import 'package:lexivo/core/ads/ads_provider.dart';
import 'package:lexivo/core/config/app_config.dart';

/// Abstract consent gateway (UMP / GDPR + ATT hook point).
abstract class AdsConsentGateway {
  /// Resolves current consent; may show UMP form when required.
  Future<AdsConsentStatus> resolveConsent();

  /// Whether personalized ads are allowed under current consent + child flags.
  bool get allowsPersonalizedAds;
}

/// Configurable stub for tests and platforms without UMP.
class StubAdsConsentGateway implements AdsConsentGateway {
  StubAdsConsentGateway({
    this.status = AdsConsentStatus.notRequired,
  });

  AdsConsentStatus status;

  @override
  bool get allowsPersonalizedAds {
    if (AppConfig.childDirected) return false;
    return status == AdsConsentStatus.obtained ||
        status == AdsConsentStatus.notRequired;
  }

  @override
  Future<AdsConsentStatus> resolveConsent() async => status;
}

/// Tracks whether personalized load was blocked (for tests / diagnostics).
class ConsentGatedAdsConsentGateway implements AdsConsentGateway {
  ConsentGatedAdsConsentGateway(this._inner);

  final AdsConsentGateway _inner;
  bool personalizedLoadBlocked = false;

  @override
  bool get allowsPersonalizedAds => _inner.allowsPersonalizedAds;

  @override
  Future<AdsConsentStatus> resolveConsent() => _inner.resolveConsent();

  void notePersonalizedLoadAttempt() {
    if (!allowsPersonalizedAds) {
      personalizedLoadBlocked = true;
    }
  }
}
