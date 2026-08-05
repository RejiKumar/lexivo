import 'package:flutter/widgets.dart';

/// Consent state for personalized advertising (UMP / GDPR).
enum AdsConsentStatus {
  /// Consent not yet resolved.
  unknown,

  /// Form required; user has not completed it.
  required,

  /// User granted consent for personalized ads.
  obtained,

  /// Consent not required in this region.
  notRequired,

  /// User declined personalized ads (non-personalized may still be allowed).
  denied,
}

/// Result of a rewarded ad completion.
class RewardResult {
  const RewardResult({required this.type, required this.amount});

  final String type;
  final num amount;
}

/// Shared ads adapter — features MUST NOT import AdMob SDK directly.
abstract class AdsProvider {
  Future<void> initialize({required AdsConsentStatus consent});

  Future<void> showAppOpen();

  Widget banner({required String placementId});

  Widget native({required String placementId});

  Future<RewardResult?> showRewarded({required String placementId});

  Future<void> showInterstitial({required String placementId});

  /// Premium / operator suppress — when true, no ad surfaces render or load.
  void setAdsSuppressed(bool suppressed);

  bool get isAdsSuppressed;

  /// Whether the provider may load personalized inventory given consent + flags.
  bool get canRequestPersonalizedAds;
}
