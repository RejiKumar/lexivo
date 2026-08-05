## 1. Wave 1 — Localization foundation

- [x] 1.1 Enable Flutter gen-l10n / ARB under `core/l10n/` with default locale `en` and wire `AppLocalizations` at the app root
- [x] 1.2 Document the string migration pattern (ARB key → localizations → string props) for features and design-system callers
- [x] 1.3 Migrate app shell / navigation chrome user-facing strings into ARB (`en`)
- [x] 1.4 Add a lightweight check or PR checklist note: no new hardcoded user-facing strings in touched UI

## 2. Wave 1 — Adaptive app shell

- [x] 2.1 Add shared breakpoint helper and shell that selects `LexivoBottomNav` (mobile) vs `LexivoNavRail` (tablet/desktop) from one `NavItem` list + `app_router` destinations
- [x] 2.2 Ensure design-system BottomNav/NavRail share the NavItem model and accept localized labels from the shell
- [x] 2.3 Overlay convention: sheets on mobile, dialogs on desktop/web for shell-level prompts
- [x] 2.4 Widget tests: shell chrome switches correctly at mobile vs tablet/desktop breakpoints

## 3. Wave 2 — Adaptive document library + rag_chat

- [x] 3.1 Refactor document library entry into `_MobileLayout` / `_TabletLayout` / `_DesktopLayout` sharing existing document providers
- [x] 3.2 Desktop/tablet library: two-pane or multi-pane list + detail; mobile: single-column; migrate touched library strings to ARB
- [x] 3.3 Refactor rag_chat entry into `_MobileLayout` / `_TabletLayout` / `_DesktopLayout` sharing existing chat providers
- [x] 3.4 Desktop/web chat: multi-pane (context + conversation); mobile: single-column + sheet overlays; migrate touched chat strings to ARB
- [x] 3.5 Widget tests: library and chat layout variants render at each breakpoint without provider forks

## 4. Wave 2 — App version check E2E

- [x] 4.1 Backend: Settings/env for `MIN_SUPPORTED_APP_VERSION`, `LATEST_APP_VERSION`, messages, and store URLs
- [x] 4.2 Backend: implement `GET /api/v1/app/version` (auth optional) with root + android/ios/web blocks per `docs/app-versioning.md`
- [x] 4.3 Update OpenAPI snapshot for the version route and regenerate the typed client slice for that endpoint only
- [x] 4.4 Client `core/app_upgrade/`: SemVer policy evaluator (force / soft / OK), platform checkers, fail-open on network error
- [x] 4.5 Soft-update dismissible prompt and force-update blocking UI via design-system dialog/sheet; wire into app startup/resume
- [ ] 4.6 Integration/E2E: toggle Settings MSV/latest and verify soft vs force vs OK on client

## 5. Wave 3 — Ads adapter, placements, premium suppress

- [x] 5.1 Add `AdsProvider` abstract surface in `core/ads/` (initialize, app open, banner, native, rewarded, interstitial, `setAdsSuppressed`)
- [x] 5.2 Implement AdMob provider with `ENABLE_ADS` gate; use test ad units outside production
- [x] 5.3 Consent gate: UMP/GDPR before personalized ads; ATT hook on iOS when advertising identifier is used
- [x] 5.4 Expose premium/ads-suppress signal from subscription state (paywall flag remains off) and wire to `setAdsSuppressed`
- [x] 5.5 Add initial placements on agreed free-tier surfaces (shell/library/chat as chosen in Wave 3); no ads when flag off, consent missing, or premium
- [x] 5.6 Unit/widget tests: flag off, premium suppress, and consent-blocked paths show no ads

## 6. Tests and Definition of Done gates

- [x] 6.1 Unit tests for SemVer policy edges (below MSV, soft band, current/latest, build metadata ignored)
- [x] 6.2 Backend tests for version endpoint Settings-driven responses
- [x] 6.3 Golden/widget coverage for adaptive shell chrome at key breakpoints
- [x] 6.4 DoD checklist: en ARB wired; adaptive shell + library + rag_chat layouts reviewed; soft/force upgrade demoed; ads hooks present with premium suppress; no subscription re-enable; no Drift/OpenAPI-rewrite/`frontend/` migrate scope creep
- [x] 6.5 Run lint/tests for touched packages and confirm CI-relevant gates still green
