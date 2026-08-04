# Frontend Subscription — Task Plan
Capability: **subscription** (Flutter paywall/upgrade behind feature flag + backend config-driven free-tier caps + shared quota enforcement)
Architecture: `spec/architecture.md` §2.1–§2.3 (feature-first clean architecture; `core/`; no cross-feature imports) + §3.1 `subscriptions` router/domain + gateway-layer quota reuse (`spec/nexora_spec.md` §10)
OpenSpec: `openspec/specs/subscription/spec.md`
UI: compose **ONLY** from `core/design_system` (`Lexivo*` — especially `LexivoButton`, `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoSnackbar`, `LexivoBadge` for tier/usage affordance). Load via shared `AsyncValueView`. Any new visual atom → Design System Agent first — never inline one-offs.
Product: Lexivo
Execution order: **STEP 3.7 next feature** after notifications PASS; **CI/CD is the next step after this plan** (out of scope here)

**Prerequisite (completed)**
- [x] STEP 3.7 notifications DoD **PASS** (`openspec/reviews/frontend-notifications-step37-review.md`) — subscription may proceed; use named routes + core identity only; **do not** import `features/notifications` (or `pdf_export` / `rag_chat` / `translation` / `summarization` / `ocr` / `document_scan` / `auth` internals)
- [x] Design-system DoD **PASS** — `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoButton`, `LexivoSnackbar`, `LexivoBadge` available
- [x] Backend core domains for documents / chats / OCR jobs already exist — **quota config, shared enforcer, consistent quota error, subscriptions domain/router, and Flutter `features/subscription/` are missing** (see §0)

**Out of scope for this file (later plans)**
- CI/CD, Cloud Run, store release pipelines (next STEP after this slice)
- Real payment-provider checkout (Stripe/Play Billing/App Store) — ship upgrade/paywall **UI + stub upgrade API**; vendor adapter later
- Email receipts / billing portal / invoice history
- Changing free-tier defaults away from OpenSpec (20 / 100 / 500) without config
- Softening or bypassing caps when the feature flag is off (caps **always** enforce)
- Rebuilding OCR / chat / document agents; only wrap create / message / OCR enqueue with shared quota checks
- Offline Drift sync for subscription state
- New design-system atoms unless a gap is flagged below for Design System Agent

**Product defaults (resolved)**

| Concern | Choice |
|---|---|
| Feature home | `lib/features/subscription/` — paywall + upgrade screens (+ optional usage) behind flag |
| Feature flag (launch) | **Off by default.** Backend: `Settings.subscription_paywall_enabled: bool = False` (env `SUBSCRIPTION_PAYWALL_ENABLED`). Flutter: compile-time / flavor `subscriptionPaywallEnabled` default **false** (e.g. `--dart-define=SUBSCRIPTION_PAYWALL_ENABLED=false` or `AppConfig` constant). Flag controls **UI visibility only** |
| Caps always on | Free-tier caps enforce whether the flag is on or off. Flag flip later reveals upgrade paths without changing limit logic |
| Cap values (config, not constants) | `free_tier_docs_per_month=20`, `free_tier_chat_messages_per_day=100`, `free_tier_ocr_pages_per_month=500` on `Settings` / env — defaults match OpenSpec |
| Paid tier | ORM `subscriptions` row per user: `tier` `free`\|`paid`, `status` active/canceled (minimal), timestamps. Paid users **skip** free-tier caps. Stub `POST …/upgrade` (auth) sets `tier=paid` when paywall flag is on; when flag off, upgrade HTTP may return **404/403 feature-disabled** or no-op — Flutter never shows the CTA |
| Quota error shape | Shared `QuotaExceededError` → HTTP **429** with consistent body: `{ "detail": { "code": "quota_exceeded", "resource": "documents"|"chat_messages"|"ocr_pages", "limit": <int>, "period": "month"|"day", "message": "<human>" } }` (or equivalent nested `detail` that OpenAPI documents once). Same shape for all three caps |
| Enforcement locus | Shared **quota gateway** module (`QuotaService` / `enforce_quota` dependency) used by DocumentService create, ChatService post-message, and OCR enqueue — **not** copied per router. Register FastAPI exception handler (+ optional thin middleware that only normalizes response / metrics). Do **not** invent per-endpoint limit math |
| Document cap | Count documents created by user in **UTC calendar month**; reject further `POST /documents` when count ≥ cap |
| Chat cap | Count **user-role** chat messages created in **UTC calendar day**; reject further message posts when count ≥ cap |
| OCR pages cap | Before enqueueing OCR (document processing path), estimate pages (PDF page count via lightweight parser; **1** for single-image uploads). Reject when `used + estimate > cap`. After OCR success, persist actual `page_count` on Document (from OCR agent `pages` length / provider metadata) and bill usage to **actual** pages for that job (adjust estimate vs actual in the same month ledger — prefer a small `usage_events` or running counters table; see §0). Re-OCR of same doc must not double-count beyond actual pages for that document in-period (idempotent per document+month) |
| Usage API | Thin `GET /api/v1/subscriptions/me` (or `/usage`) → `{ tier, paywall_enabled, usage: { documents: {used, limit, period}, chat_messages: {…}, ocr_pages: {…} } }` — always available to client for optional display; does not require flag |
| Flutter ErrorMapper | Map `429` + `code=quota_exceeded` → new core `QuotaFailure` (resource/limit/message). Existing features surface message via existing error banners — **no** cross-feature import of subscription UI when flag off |
| Paywall UI | When flag **on**: named routes `/subscription`, `/subscription/upgrade` (names flexible); entry from account / quota error CTA. When flag **off**: routes not registered **or** guard redirects away; **no** upgrade CTAs anywhere |
| Route guard | Flesh out `RouteGuards.subscriptionGuard`: if location is paywall/upgrade and flag off → redirect home/account; if flag on, auth still required via `authGuard` |
| Optional usage display | Account or subscription screen shows used/limit when data loads — allowed with flag **off** (informational only, no upgrade button). Prefer composing inside `features/subscription/` and injecting a small usage widget/builder into account via **named route / shell slot**, not importing subscription internals from auth |
| State | Riverpod (current pin; prefer 3 when pins allow) |
| Models | Freezed (+ json_serializable only for network DTOs) |
| HTTP | Typed `ApiClient` only — no `Dio(` / `package:dio` inside `features/subscription/` |

**Conventions**
- Loop per chunk: failing test → implement → (widget test where UI) → review vs OpenSpec subscription + architecture §2.1–§2.3 + Lexivo* composition → fix → commit.
- Prefer small sequential commits; never one giant “frontend-subscription” commit.
- Feature public surface = barrel `features/subscription/subscription.dart` only.
- Screens: layout + `Lexivo*` + `AsyncValueView` only. Grep guard: empty → `LexivoEmptyState` if applicable; errors → `LexivoErrorBanner`; primary actions → `LexivoButton`.
- All HTTP via `core/network` `ApiClient`.
- Prefixes: package `lexivo`; UI `Lexivo*`; never `Nexora*`.
- Do **not** import other `features/*/data` or presentation internals. Cross-feature wiring = named routes + injected screen builders only.
- Caps remain enforced in backend tests with flag **false** (regression: paywall hidden ≠ unlimited).

**Design-system gap flag**
- Expected composition: paywall/upgrade = headline + supporting copy + `LexivoButton` CTAs + optional usage rows (`LexivoBadge` / text + progress via layout); loading/error via `AsyncValueView` + `LexivoSkeleton` / `LexivoErrorBanner`.
- If a true visual gap appears (e.g. dedicated progress meter atom that cannot be layout + tokens), **stop and flag Design System Agent** — do not invent feature-local atoms.

**Shared test fixtures (Test Agent ownership)**

| Location | Owns |
|---|---|
| `test/fixtures/subscription/` | JSON: usage under/at/over limits; free vs paid tier; quota 429 envelope; upgrade stub success; paywall-disabled response |
| `test/helpers/` | `FakeSubscriptionRepository`, `MockApiClient` usage/upgrade stubs; flag override helper |
| `test/core/network/` | usage DTO + ErrorMapper `QuotaFailure` (429 quota_exceeded) tests |
| `test/features/subscription/` | Domain/data/presentation/flow tests (use helpers; no duplicate fakes) |
| `test/core/routing/` | `subscriptionGuard` flag on/off redirect tests |
| `backend/tests/` | Settings defaults; QuotaService unit; document/chat/OCR over-cap API; consistent error shape; paid bypass; flag-off still enforces caps; usage endpoint |

---

## 0. Backend — config caps + shared quota gateway + subscriptions (MISSING today)

OpenAPI / routers expose auth, documents, chats, exports, notifications. **No** free-tier Settings fields, **no** shared quota enforcer, **no** consistent quota error, **no** `subscriptions` ORM/router, **no** usage endpoint. Document create / chat message / OCR enqueue are uncapped — **blocks OpenSpec subscription + safe Flutter paywall**.

### 0.A Config + feature flag + OpenAPI error contract

- [ ] 0.1 **Decision gate:** document in this plan / `docs/api_client.md`: caps from Settings (20/100/500 defaults); `SUBSCRIPTION_PAYWALL_ENABLED` default false; quota HTTP **429** + `code=quota_exceeded` shape; paid skips caps; enforcement via shared `QuotaService` (not per-router math)
- [ ] 0.2 Add Settings fields: `subscription_paywall_enabled: bool = False`, `free_tier_docs_per_month: int = 20`, `free_tier_chat_messages_per_day: int = 100`, `free_tier_ocr_pages_per_month: int = 500`
- [ ] 0.3 Write failing tests: Settings defaults match OpenSpec; env overrides change caps / flag
- [ ] 0.4 Document OpenAPI component for quota error `detail`; refresh snapshot after endpoints land

### 0.B QuotaExceededError + consistent handler

- [ ] 0.5 Add `QuotaExceededError` (resource, limit, period, message) alongside existing service errors in `services/base.py` (or `services/quota.py`)
- [ ] 0.6 Write failing API/unit tests: raising `QuotaExceededError` maps to **one** HTTP status + body shape for documents / chat / OCR resources
- [ ] 0.7 Register FastAPI exception handler (and/or thin middleware) so all quota failures share that shape — no ad-hoc `HTTPException(429, "…")` strings per router

### 0.C Subscriptions model + usage ledger

- [ ] 0.8 Add ORM `Subscription` (user_id unique FK, tier free\|paid, status, timestamps) — migration or create_all-compatible for tests; ensure user gets free tier on first access (lazy create)
- [ ] 0.9 Add usage tracking strategy (prefer `usage_events` or counters keyed by user+resource+period_start): documents/month, chat_messages/day, ocr_pages/month; write failing repo tests for increment + read used
- [ ] 0.10 Persist Document `page_count` (nullable int) updated from OCR success (`pages` from Master/OCR agent result); write failing test that OCR success stores page_count

### 0.D Shared QuotaService (gateway logic)

- [ ] 0.11 Write failing unit tests: free user under limit → allow; at/over docs monthly → reject; chat daily → reject; OCR pages monthly (estimate) → reject
- [ ] 0.12 Write failing tests: `tier=paid` bypasses all three caps
- [ ] 0.13 Write failing tests: caps still enforce when `subscription_paywall_enabled=False`
- [ ] 0.14 Implement `QuotaService` / `enforce_*` helpers reading Settings + subscription tier + usage ledger — **single module** imported by services (not duplicated in routers)
- [ ] 0.15 OCR idempotency: second OCR on same document in-period does not inflate page usage beyond that document’s actual pages

### 0.E Wire enforcement into create / chat / OCR

- [ ] 0.16 Write failing API tests: `POST /documents` at monthly doc cap → 429 quota shape; under cap → 201 and usage increments
- [ ] 0.17 Write failing API tests: chat message post at daily cap → 429; under cap → success and usage increments
- [ ] 0.18 Write failing API/service tests: OCR enqueue / processing start at page cap → 429 before work; under cap with estimate → proceeds; success records pages
- [ ] 0.19 Implement hooks: `DocumentService.create_with_upload`, `ChatService` user-message path, OCR enqueue (`enqueue_document_processing` / DocumentService processing entry) call shared QuotaService only
- [ ] 0.20 Grep/coupling guard: routers do not embed limit integers; only Settings + QuotaService; commit backend enforcement slice

### 0.F Thin subscriptions router + stub upgrade

- [ ] 0.21 Write failing API tests: `GET /api/v1/subscriptions/me` (auth) returns tier + usage used/limit/period + `paywall_enabled` from Settings
- [ ] 0.22 Write failing API tests: `POST /api/v1/subscriptions/upgrade` when flag **on** → stub sets `tier=paid`; when flag **off** → feature-disabled error (403/404) without changing tier
- [ ] 0.23 Implement `SubscriptionService` + `subscriptions` router; wire in `main.py`; refresh OpenAPI; commit
- [ ] 0.24 Review vs OpenSpec “Feature-flagged subscription” / “Configurable free-tier caps” / “Quota middleware reuse”; fix; commit backend §0 DoD

---

## 1. Typed client + QuotaFailure (Flutter core)

- [ ] 1.1 Write failing `ApiClient` / DTO unit tests: `getSubscriptionMe` / usage parse (tier, paywall_enabled, three usage buckets)
- [ ] 1.2 Write failing tests: upgrade stub DTO; paywall-disabled mapping
- [ ] 1.3 Write failing `ErrorMapper` tests: 429 + `quota_exceeded` → `QuotaFailure` with resource/limit/message; unrelated 429 stays NetworkFailure (or documented fallback)
- [ ] 1.4 Add Freezed DTOs aligned to OpenAPI; implement `ApiClient` methods; update `docs/api_client.md` (`TODO(openapi-codegen)` note)
- [ ] 1.5 Add `QuotaFailure` to `core/utils/result.dart` (or adjacent); ensure equality/hash consistent with other Failures
- [ ] 1.6 Add/update fixtures under `test/fixtures/subscription/`; review vs OpenSpec typed client; fix; commit

---

## 2. Feature scaffold (§2.1)

- [ ] 2.1 Create `lib/features/subscription/` tree: `data/{datasources,repositories,models}/`, `domain/{entities,repositories,usecases}/`, `presentation/{screens,widgets,providers}/`, barrel `subscription.dart`
- [ ] 2.2 Write failing barrel smoke: exports public paywall/upgrade/usage builders + providers needed by router — **not** data-layer types
- [ ] 2.3 Review vs architecture §2.1 folder contract; fix; commit scaffold

---

## 3. Domain — repository + usecases

- [ ] 3.1 Define abstract `SubscriptionRepository`: `getMe()`, `upgrade()` → `Result` + feature entities
- [ ] 3.2 Freezed domain `SubscriptionStatus` / `UsageBucket` (tier, paywallEnabled, used/limit/period per resource)
- [ ] 3.3 Write failing usecase tests (fake repo): `GetSubscriptionMe`, `UpgradeSubscription`; success/failure `Result` shapes
- [ ] 3.4 Write failing tests: free at limit still returns data; upgrade failure when flag off surfaces failure
- [ ] 3.5 Implement usecases — each single `call()`, returns `Result`
- [ ] 3.6 Review vs OpenSpec flag + caps scenarios (client-side models); fix; commit

---

## 4. Data layer — remote + repository impl

- [ ] 4.1 Write failing tests for `SubscriptionRemoteDatasource`: getMe / upgrade via `ApiClient` only; DTO→domain; failures via `ErrorMapper`/`Result`
- [ ] 4.2 Implement datasource + `SubscriptionRepositoryImpl`
- [ ] 4.3 Riverpod providers for repository + usecases (override-friendly)
- [ ] 4.4 Assert no `package:dio` and no other `features/*` imports under `features/subscription/`; fix; commit

---

## 5. Presentation — providers (Riverpod)

- [ ] 5.1 Write failing provider tests: load me → loading → data `AsyncValue`
- [ ] 5.2 Write failing tests: load failure → error; retry reloads
- [ ] 5.3 Write failing tests: upgrade (flag on) → tier becomes paid; refresh usage
- [ ] 5.4 Implement notifier(s) (`subscriptionMeProvider`, etc.)
- [ ] 5.5 Review vs OpenSpec usage/paywall data needs; fix; commit

---

## 6. Presentation — paywall / upgrade screens (flag-gated UI)

- [ ] 6.1 Write failing widget tests for **PaywallScreen** / **UpgradeScreen** (names flexible): loading → skeleton; error → `LexivoErrorBanner`; data → tier + limits copy + upgrade CTA when flag on
- [ ] 6.2 Write failing tests: flag **off** → screens not reachable / not shown (builder not used; no upgrade CTA in tree)
- [ ] 6.3 Write failing tests: flag **on** + at limit copy → upgrade CTA visible; tap triggers upgrade usecase (stub success)
- [ ] 6.4 Implement screens composing Lexivo* + layout only; **no** real payment SDK UI
- [ ] 6.5 Grep guard: production subscription UI uses Lexivo* for primary actions/empty/error; fix; commit
- [ ] 6.6 Review vs OpenSpec “Flag off hides paywall UI” / “Flag on reveals paywall”; fix; commit

---

## 7. Feature flag + routing + subscriptionGuard

- [ ] 7.1 Centralize Flutter `subscriptionPaywallEnabled` (AppConfig / dart-define) default **false**; write failing tests that default is false
- [ ] 7.2 Write failing router tests: flag off → `/subscription` and `/subscription/upgrade` redirect or absent; flag on → authenticated access works
- [ ] 7.3 Implement `RouteGuards.subscriptionGuard` for real (replace pass-through stub): hide paywall routes when flag off; keep authGuard primary
- [ ] 7.4 Extend `RouteGuards` + `app_router` with subscription routes; inject builders from `subscription` barrel only when flag on (or always register + guard redirect)
- [ ] 7.5 Wire account/home entry CTA to paywall **only if flag on** — named routes / core routing helpers only; no feature-internal imports from auth
- [ ] 7.6 Review vs architecture §2.3 navigation contract; fix; commit

---

## 8. Optional usage display + quota error UX

- [ ] 8.1 Write failing widget/flow tests: usage summary shows used/limit for docs, chats, OCR pages (allowed with flag off; **no** upgrade button when flag off)
- [ ] 8.2 Implement usage widget/screen section via Lexivo* inside subscription feature; expose via barrel builder for account shell injection
- [ ] 8.3 Write failing core/widget tests: `QuotaFailure` message can render in `LexivoErrorBanner` / snackbar path used by existing AsyncValue error UI (no subscription import required in other features)
- [ ] 8.4 Optional: when flag **on**, quota error surfaces secondary “Upgrade” via named route only — do not import subscription screens from document_scan/rag_chat/ocr
- [ ] 8.5 Review vs OpenSpec clear quota errors + optional usage; fix; commit

---

## 9. End-to-end feature flow (widget/integration-ish)

- [ ] 9.1 Write failing flow test: flag off → open app account/usage → see limits, **no** upgrade CTA; paywall route blocked
- [ ] 9.2 Write failing flow test: flag on → open paywall → upgrade stub → tier paid reflected
- [ ] 9.3 Write failing flow test: simulated 429 quota on getMe path → `LexivoErrorBanner` + retry
- [ ] 9.4 Wire providers in app bootstrap overrides alongside prior features; bearer token still injected; review full OpenSpec subscription **client** scenarios; fix; commit

---

## 10. Shared fixtures hygiene (Test Agent)

- [ ] 10.1 Add/extend `FakeSubscriptionRepository` + helpers under `test/helpers/`
- [ ] 10.2 Add/update `test/fixtures/subscription/*.json` for under/at/over limit, paid, quota 429, upgrade, flag-disabled
- [ ] 10.3 Keep fixture map in this plan’s table updated; commit

---

## 11. Reviewer gate checkpoints (STEP 3.7 subscription slice)

Run after §§0–10 land; blockers must be fixed before declaring this slice done.

- [ ] 11.1 **Prerequisite gate:** notifications STEP 3.7 review still PASS; no regression in auth/core/document_scan/ocr/summarization/translation/rag_chat/pdf_export/notifications suites
- [ ] 11.2 **Config caps gate:** defaults 20 docs/mo, 100 chats/day, 500 OCR pages/mo from Settings; not hardcoded in routers/services beyond Settings reads
- [ ] 11.3 **Enforcement gate:** document create / chat message / OCR enqueue reject over-cap with **identical** quota error shape; paid bypass works
- [ ] 11.4 **Flag vs caps gate:** `subscription_paywall_enabled=false` hides upgrade UI and disables stub upgrade; **caps still enforce**
- [ ] 11.5 **Shared quota gate:** single QuotaService/gateway path; no per-endpoint reinvented limit math; exception handler consistency
- [ ] 11.6 **Flutter paywall gate:** `features/subscription/` screens behind flag (off by default); optional usage without upgrade CTA when flag off
- [ ] 11.7 **Navigation / architecture gate:** named routes + `subscriptionGuard`; §2.1 tree + barrel-only outside; no Dio inside feature; typed `ApiClient` only; no cross-feature data imports
- [ ] 11.8 **UI composition gate:** Lexivo* only; any DS gap flagged, not inlined
- [ ] 11.9 **Scope gate:** no CI/CD; no real payment SDK; no email billing; no weakening caps when flag off
- [ ] 11.10 **TDD / stack gate:** Freezed + Riverpod; `flutter test` green for core + subscription (+ prior features); backend quota + subscription API tests green
- [ ] 11.11 Final review vs `openspec/specs/subscription/spec.md` + architecture §2.1–§2.3; fix remaining gaps; commit “frontend subscription STEP 3.7 slice DoD met”

---

## Definition of Done (STEP 3.7 — subscription)

- [ ] Backend: Settings-driven caps (20/100/500); shared QuotaService + consistent 429 quota_exceeded; enforce on document create / chat message / OCR; subscriptions + usage (+ stub upgrade); paywall flag off by default
- [ ] Flutter: `features/subscription/` clean architecture + barrel; paywall/upgrade behind flag (off); optional usage display; `QuotaFailure` mapping; `subscriptionGuard` real
- [ ] Caps enforce with flag off; paid bypass when tier paid
- [ ] Reviewer gates 11.1–11.11 passed
- [ ] Out of scope preserved (CI/CD; real payments; email billing)

---

## Coverage matrix (planner verification)

| Requirement (OpenSpec / architecture) | Plan section |
|---|---|
| Feature flag off hides paywall UI | §0.2, §0.22, §6.2, §7, §9.1, §11.4 / §11.6 |
| Feature flag on reveals upgrade paths | §0.22, §6.3, §7.2, §9.2, §11.6 |
| Caps still enforce when flag off | §0.13, §0.16–0.18, §11.4 |
| Config caps 20 / 100 / 500 | §0.2–0.3, §0.11, §11.2 |
| Document monthly cap | §0.16, §0.19 |
| Chat daily cap | §0.17, §0.19 |
| OCR pages monthly cap | §0.10, §0.15, §0.18–0.19 |
| Shared quota middleware / gateway reuse | §0.5–0.7, §0.11–0.14, §0.20, §11.5 |
| Consistent quota-exceeded error | §0.5–0.7, §1.3, §8.3, §11.3 |
| Flutter `features/subscription/` + typed client | §1–5, §11.7 |
| Optional usage display | §8.1–8.2, §9.1 |
| notifications prerequisite completed | Prerequisites (PASS review) |
| Out of scope: CI/CD / real payments | Out of scope, §11.9 |

**Client OpenSpec scenarios covered:** **Yes** — flag off/on paywall visibility; caps enforced server-side with clear quota errors; optional usage.

**Backend API tasks included:** **Yes** — dedicated §0 (Settings caps + QuotaService + subscriptions/usage/upgrade stub + wire create/chat/OCR + OpenAPI) because quota enforcement and subscriptions domain are missing today.

**Task count:** **83** numbered TDD/gate tasks (0.1–0.24, 1.1–1.6, 2.1–2.3, 3.1–3.6, 4.1–4.4, 5.1–5.5, 6.1–6.6, 7.1–7.6, 8.1–8.5, 9.1–9.4, 10.1–10.3, 11.1–11.11). Prerequisites (3) marked completed above and excluded. DoD summary list (5) is a roll-up of those gates, not extra work items.

---

## Reviewer

*(Leave blank for Reviewer Agent — fill after implementation.)*

| Field | Value |
|---|---|
| **Capability** | subscription (Flutter + backend quota / subscriptions API) |
| **Reviewer** | |
| **Date** | |
| **Sources** | `openspec/specs/subscription/spec.md`, `spec/architecture.md` §2.1–§2.3, this plan §11, `openspec/reviews/frontend-notifications-step37-review.md` |
| **Verdict** | |

### Gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Prerequisite — notifications STEP 3.7 still PASS | |
| 11.2 | Config caps — Settings 20/100/500 | |
| 11.3 | Enforcement — create / chat / OCR + consistent error | |
| 11.4 | Flag off hides paywall; caps still enforce | |
| 11.5 | Shared QuotaService / gateway reuse | |
| 11.6 | Flutter paywall behind flag; optional usage | |
| 11.7 | Navigation + clean architecture + typed client | |
| 11.8 | UI composition — Lexivo* | |
| 11.9 | Scope — no CI/CD / real payments / email billing | |
| 11.10 | TDD / stack — flutter + backend tests green | |
| 11.11 | Final vs OpenSpec + architecture | |

### Notes

-
