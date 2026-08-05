## Why

Lexivo’s product and architecture specs already require localization, adaptive layouts, soft/force app upgrade, and free-tier ads — but these cross-cutting platform foundations are not implemented. Closing them now unblocks v1 Definition of Done items that feature work alone cannot satisfy, without reopening subscription, offline cache, OpenAPI codegen, or a physical `frontend/` migrate.

## What Changes

- Add Flutter **intl/ARB localization** under `core/l10n/` with default locale `en`, an `AppLocalizations` wiring pattern, and a migration path to eliminate hardcoded user-facing strings over time (foundation first; progressive migration of existing UI).
- Add an **adaptive app shell** that switches `LexivoBottomNav` (mobile) vs `LexivoNavRail` (tablet/desktop) from shared `NavItem` + router table, plus the per-feature `_MobileLayout` / `_TabletLayout` / `_DesktopLayout` entry pattern (same Riverpod providers; desktop multi-pane, hover, keyboard; dialog vs sheet overlays).
- Apply adaptive layouts first to **document library** (`document-scan`) and **rag_chat**, establishing the pattern for remaining features.
- Add **app upgrade** (`core/app_upgrade/`): soft + force gates driven by `GET /api/v1/app/version` per `docs/app-versioning.md`, with Settings/env-backed MSV and latest version (Play / App Store / Web).
- Add **ads** (`core/ads/`): `AdsProvider` adapter with AdMob implementation, `ENABLE_ADS` flag, GDPR/UMP consent gate, and suppression for premium users (subscription remains feature-flagged off; suppress hook still wired).
- **Out of scope:** re-implementing subscription/paywall, Drift offline cache, OpenAPI codegen rewrite, physical move to `frontend/`.

## Capabilities

### New Capabilities
- `localization`: Flutter intl/ARB foundation (`core/l10n/`), default `en`, zero hardcoded user-facing strings policy and migration pattern.
- `adaptive-ui`: Breakpoint-driven app shell and feature layout variants (mobile / tablet / desktop) with shared providers and design-system chrome.
- `app-upgrade`: Soft and force update flows, minimum supported version policy, platform-aware store/web actions, and client consumption of the version-check API.
- `ads`: Client `AdsProvider` adapter (AdMob), `ENABLE_ADS`, consent gating, placements, and premium suppress.

### Modified Capabilities
- `design-system`: Strengthen adaptive shell composition (BottomNav vs NavRail) and enforce localized string props on components (no hardcoded copy inside atoms).
- `document-scan`: Require purpose-built adaptive layouts for document library (and related entry screens) per architecture §2.1.
- `rag-chat`: Require purpose-built adaptive layouts for chat entry (list + detail multi-pane on large screens).
- `backend-services`: Add `GET /api/v1/app/version` (Settings/env-driven MSV + latest, platform blocks) per `docs/app-versioning.md`.
- `subscription`: Expose a premium/ads-suppress signal for the ads adapter without re-enabling or rebuilding the paywall (flag stays off).

## Impact

- **Flutter:** new `core/l10n/`, `core/ads/`, `core/app_upgrade/`; adaptive shell in routing/chrome; layout variants under `document_scan` and `rag_chat`; progressive ARB migration of user-facing strings.
- **Backend:** version-check route + Settings/env (`MIN_SUPPORTED_APP_VERSION`, `LATEST_APP_VERSION`, store URLs); OpenAPI snapshot update for the new endpoint only (no codegen rewrite).
- **Dependencies:** Flutter intl/ARB toolchain; AdMob + UMP (consent); package_info / platform version readers; existing design-system nav components.
- **Security/privacy:** ads consent and ATT notes per `docs/security.md`; test ad units in non-prod.
- **Does not touch:** subscription UI rework, Drift offline cache, full OpenAPI client regen strategy, monorepo `frontend/` path migrate.
