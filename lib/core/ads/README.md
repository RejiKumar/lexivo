# Ads (`core/ads/`)

Client ads go only through [AdsProvider]. Features compose [LexivoAdBanner]
(or other adapter APIs) and **must not** import `google_mobile_ads`.

## Flags (`AppConfig` / `--dart-define`)

| Define | Default | Meaning |
|--------|---------|---------|
| `ENABLE_ADS` | `false` | Master switch. When false → [NoOpAdsProvider], zero SDK init, zero UI. |
| `CHILD_DIRECTED` | `false` | Tag for child-directed treatment; blocks personalized ads. |
| `ADS_USE_PRODUCTION_IDS` | `false` | When false, use **Google test ad unit IDs**. |

## Google test ad units (non-production)

Used whenever `ADS_USE_PRODUCTION_IDS` is false (see [AdsUnitIds]):

| Format | Unit ID |
|--------|---------|
| Banner | `ca-app-pub-3940256099942544/6300978111` |
| Interstitial | `ca-app-pub-3940256099942544/1033173712` |
| Rewarded | `ca-app-pub-3940256099942544/5224354917` |
| Native | `ca-app-pub-3940256099942544/2247696110` |
| App open | `ca-app-pub-3940256099942544/3419835294` |

Manifest sample App IDs (Android / iOS) match Google’s test app IDs.

## Web

AdMob is mobile-first. Even with `ENABLE_ADS=true`, web binds [NoOpAdsProvider].

## Premium suppress

[adsSuppressedProvider] defaults to `false`. Subscription overrides it when
`tier` is paid (`SubscriptionStatus.isPaid`) via `subscriptionCoreOverrides`.
Paywall UI stays behind `SUBSCRIPTION_PAYWALL_ENABLED` (default off).

## Consent

[AdsConsentGateway] resolves UMP/GDPR before personalized inventory. Until
consent is `obtained` or `notRequired`, [LexivoAdBanner] renders nothing.
iOS ATT is handled by UMP when the advertising identifier is used.

UMP is unreachable on emulators and unregistered debug devices, which would
leave every slot blank locally. `resolveUnreachableConsent` therefore treats an
unreachable lookup as `notRequired` **only** in debug builds using Google test
ad units; release builds and `ADS_USE_PRODUCTION_IDS=true` stay `unknown`.

## Tests / CI

Default `ENABLE_ADS=false` keeps `flutter test` free of device AdMob init.
Override `enableAdsFlagProvider`, `adsSuppressedProvider`,
`adsConsentStatusProvider`, and `adsProviderProvider` in widget tests.
