/// Compile-time flags for subscription / paywall UI.
///
/// Enable paywall screens with:
/// `flutter run --dart-define=SUBSCRIPTION_PAYWALL_ENABLED=true`
///
/// Caps are always enforced by the API regardless of this flag.
library;

abstract final class LexivoSubscriptionFlags {
  static const bool subscriptionPaywallEnabled = bool.fromEnvironment(
    'SUBSCRIPTION_PAYWALL_ENABLED',
    defaultValue: false,
  );
}
