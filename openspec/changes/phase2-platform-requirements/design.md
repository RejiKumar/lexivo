## Context

See proposal.md for motivation. Lexivo already has a design system with BottomNav/NavRail, feature modules (`document_scan` including document library, `rag_chat`), and a feature-flagged subscription module — but lacks `core/l10n/`, adaptive shell + per-feature layout variants, `core/app_upgrade/`, and `core/ads/`. Authoritative contracts: `spec/architecture.md` §2.1–2.7 / §3.3, `spec/ui_design_system.md` §5.1, `docs/app-versioning.md`, `docs/security.md` (ads/consent). Application code remains at repo root (`lib/`); no physical `frontend/` migrate in this change.

## Goals / Non-Goals

**Goals:**
- Land shared foundations (`l10n`, adaptive shell, `app_upgrade`, `ads`) that other features reuse.
- Prove adaptive layouts on document library + rag_chat first; establish the pattern for later features.
- Ship version-check E2E (backend Settings/env → API → client soft/force UI).
- Wire ads adapter with flag, consent, placements, and premium suppress without turning subscription on.

**Non-Goals:**
- Full ARB migration of every existing string in one PR (foundation + pattern + Wave migrations for touched surfaces).
- Adaptive layouts for every remaining feature in this change (only library + rag_chat required; others follow the same pattern later).
- Rebuilding subscription/paywall, Drift offline cache, OpenAPI codegen rewrite, or monorepo folder migrate.
- Production AdMob IDs in non-prod builds; child-directed store listing decisions beyond the suppress/treatment hooks.

## Decisions

### 1. Wave order: foundations → adaptive features + version E2E → ads
**Choice:** Wave 1 = l10n foundation + adaptive shell; Wave 2 = document library + rag_chat adaptive layouts + version-check E2E; Wave 3 = ads adapter, placements, premium suppress; then tests/DoD gates.  
**Why:** Shell and strings unblock feature layouts; version-check is independent of ads; ads depend on premium signal and shell placement slots.  
**Alternative:** Ads before adaptive — rejected; placements need stable chrome/layout slots.

### 2. Localization: Flutter gen-l10n / ARB under `core/l10n/`
**Choice:** Standard Flutter intl + ARB (`en` default), `AppLocalizations` wired at app root; components take string props; features call localizations. Migration: any UI touched in a wave moves strings to ARB; remaining hardcoded strings tracked as follow-on, not a blocker for shell landing.  
**Why:** Matches product SoT; no custom i18n stack.  
**Alternative:** Easy Localization / custom JSON — rejected; intl is the architecture default.

### 3. Adaptive shell: one `NavItem` list, breakpoint picks chrome
**Choice:** Shared `NavItem` + `app_router` destinations; breakpoint utility selects `LexivoBottomNav` vs `LexivoNavRail`. Feature entries switch `_MobileLayout` / `_TabletLayout` / `_DesktopLayout` only; providers stay shared. Overlays: sheets on mobile, dialogs on desktop per §5.1.  
**Why:** Architecture §2.1 / design-system inventory already define the chrome atoms.  
**Alternative:** Separate mobile/web apps or MediaQuery-only stretch — rejected by product DoD.

### 4. App upgrade: Settings/env + `GET /api/v1/app/version`
**Choice:** Backend reads `MIN_SUPPORTED_APP_VERSION`, `LATEST_APP_VERSION`, messages, and store URLs from Settings/env; client `core/app_upgrade/` SemVer-compares (ignore build metadata), maps to soft/force/OK; platform checkers open store URL or web reload. Default fail-open on network error. UI uses design-system dialog/sheet.  
**Why:** Matches `docs/app-versioning.md`; avoids hardcoding policy in release binaries.  
**Alternative:** Remote Config only / Play in-app updates only — deferred as optional enhancements behind the same policy model.

### 5. Ads: AdsProvider + AdMob + ENABLE_ADS + consent + premium suppress
**Choice:** Abstract `AdsProvider` in `core/ads/` with AdMob impl; gate on `ENABLE_ADS`; initialize only after UMP/consent (and ATT when required); `setAdsSuppressed` from subscription premium signal (works even when paywall flag is off). Test units in non-prod.  
**Why:** Architecture §2.6 / §3.3 and `docs/security.md`.  
**Alternative:** Feature-local AdMob calls — rejected; violates adapter rule.

### 6. OpenAPI: additive version route only
**Choice:** Add the version schema/route to OpenAPI and regenerate the client slice for that endpoint in the same PR; no codegen toolchain rewrite.  
**Why:** Proposal explicitly excludes OpenAPI codegen rewrite.  
**Alternative:** Hand-written Dio call — rejected by project “generated client only” rule for API calls.

## Risks / Trade-offs

- [Incomplete string migration] → Mitigation: foundation + migration checklist; gate “no new hardcoded strings” on PRs; migrate touched surfaces in Waves 1–2.
- [Adaptive layouts increase presentation file count] → Mitigation: shared providers; layouts compose design-system only; start with two features.
- [Version-check outage blocks users if fail-closed] → Mitigation: default fail-open; document explicit fail-closed only for security incidents.
- [Ads/consent complexity on web vs mobile] → Mitigation: no-op or limited placements on web if AdMob web unsupported; mobile-first placements; flag off until ready.
- [Premium signal while subscription flagged off] → Mitigation: expose suppress from entitlement/state already present; do not build paywall UI in this change.
- [AdMob policy / store rejection] → Mitigation: test IDs in dev; privacy policy URL before prod ads; consent before personalized ads.

## Migration Plan

1. Land `core/l10n/` + app root wiring; migrate shell/nav strings.
2. Land adaptive shell; keep existing feature screens compiling behind temporary single-layout wrappers if needed, then replace library + chat entries.
3. Ship backend version endpoint + client upgrade module; verify soft/force with Settings toggles in staging.
4. Land ads adapter behind `ENABLE_ADS=false` by default; enable in staging with test units; wire premium suppress.
5. Rollback: feature flags (`ENABLE_ADS`) and Settings MSV/latest; adaptive layouts are code-revert only (no schema migration).

## Open Questions

- Exact first-wave ad placement inventory (which screens get banner vs app-open) can be finalized during Wave 3 implementation against free-tier UX without changing adapter requirements.
- Whether web serves ads in v1 or remains ads-flag-gated off on web can be decided at Wave 3 without changing the AdsProvider contract.
