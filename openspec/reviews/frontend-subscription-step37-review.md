# Frontend Subscription STEP 3.7 Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | subscription (Flutter + backend QuotaService / subscriptions API) + architecture §2.1–§2.3 |
| **Reviewer** | Reviewer Agent (independent) |
| **Date** | 2026-08-04 |
| **Sources** | `openspec/specs/subscription/spec.md`, `spec/architecture.md` §2.1–§2.3, `openspec/plans/frontend-subscription-tasks.md` §11, prior `openspec/reviews/frontend-notifications-step37-review.md` |
| **Claimed** | QuotaService + APIs + `features/subscription` flag-gated; commits `b4d3f68`…`18f575a`; §11 open |
| **Verdict** | **PASS** |

---

## Verdict

**PASS** — STEP 3.7 subscription slice Definition of Done is met. Plan gates 11.1–11.11 all pass. Independent runs: backend **340 passed** (1 skipped); `flutter test` **413 passed**. No findings that block DoD or CI/CD (STEP 3.8) follow-on.

**Is STEP 3.7 subscription DoD met?** **Yes.**

**May CI/CD (STEP 3.8) proceed?** **Yes.** Caps enforce with paywall flag off; upgrade stub returns **403** when flag off; Flutter paywall/upgrade are behind `SUBSCRIPTION_PAYWALL_ENABLED` (default false). Real payment SDKs and email billing remain correctly out of scope.

---

## Findings

No findings.

### Soft notes (non-blocking)

1. HTTP API coverage for over-cap **429** is explicit for document create; chat/OCR rely on `QuotaService` unit tests + shared exception handler + service/task wiring (`ChatService`, `DocumentService.create_with_upload`, `enqueue_document_processing`). Shape is identical via `QuotaExceededError.to_detail()`.
2. `usageSummary` builder is registered on `SubscriptionScreenBuilders` but **not** composed into `AccountSettingsScreen` / home shell — optional usage is proven in widget tests (`UsageSummary` with flag off, no upgrade CTA). Paywall routes redirect when flag off, so in-app usage with flag off is not on the account surface yet.
3. No home/account entry CTA to `/subscription` when flag **on** (plan §7.5) — routes + screens work when navigated; discoverability is incomplete.
4. `LexivoErrorBanner` on load failure is composed via `AsyncValueView` (same pattern as prior STEP 3.7 features).
5. DoD commit message “frontend subscription STEP 3.7 slice DoD met” not yet present — expected post-review by implementer (same pattern as notifications).

---

## Gate-by-gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Prerequisite — notifications STEP 3.7 still PASS; no auth/core/document_scan/ocr/summarization/translation/rag_chat/pdf_export/notifications regression | **PASS** |
| 11.2 | Config caps — Settings defaults 20 / 100 / 500 | **PASS** |
| 11.3 | Enforcement — create / chat / OCR + consistent 429 `quota_exceeded`; paid bypass | **PASS** (soft note: chat/OCR HTTP 429 not separately API-tested) |
| 11.4 | Flag off hides paywall; upgrade disabled (403); caps still enforce | **PASS** |
| 11.5 | Shared QuotaService / gateway reuse + exception handler | **PASS** |
| 11.6 | Flutter paywall behind flag; optional usage without upgrade CTA when flag off | **PASS** (soft note: account shell not wired) |
| 11.7 | Navigation + clean architecture + typed client | **PASS** |
| 11.8 | UI composition — Lexivo* | **PASS** (soft notes) |
| 11.9 | Scope — no CI/CD / real payments / email billing; caps not weakened when flag off | **PASS** |
| 11.10 | TDD / stack — flutter + backend tests green | **PASS** |
| 11.11 | Final vs OpenSpec subscription + architecture §2.1–§2.3 | **PASS** |
| — | CI/CD (STEP 3.8) may proceed | **Yes** |

---

## Evidence

### 11.1 Prerequisite gate

- Notifications STEP 3.7 review remains **PASS** (`openspec/reviews/frontend-notifications-step37-review.md`); subscription was cleared to proceed.
- Independent full Flutter suite **413 passed** — includes auth, core, document_scan, ocr, summarization, translation, rag_chat, pdf_export, notifications, and subscription; no regression observed (prior notifications baseline was 388).
- Full backend pytest **340 passed**, 1 skipped — prior notifications baseline was 324; net growth matches quota/subscription coverage.

### 11.2 Config caps gate

- `Settings`: `free_tier_docs_per_month=20`, `free_tier_chat_messages_per_day=100`, `free_tier_ocr_pages_per_month=500`; `subscription_paywall_enabled=False` (`backend/app/core/config.py`, `.env.example`).
- Caps read only via Settings in `QuotaService` / `usage_snapshot`; routers do not embed limit integers.
- `tests/test_subscription_settings.py` asserts defaults and env overrides.

### 11.3 Enforcement gate

- Commits: `b4d3f68` (Settings-driven quotas + subscriptions API), covered by `test_quota_service.py` + `test_subscription_api.py`.
- Document create / chat message / OCR estimate paths call `QuotaService.enforce_*`; paid tier short-circuits all enforces.
- `QuotaExceededError` → FastAPI handler → HTTP **429** with `detail: { code: "quota_exceeded", resource, limit, period, message }`.
- API: document over-cap → 429 + shape; unit: chat daily + OCR monthly + paid bypass + OCR idempotent ceiling.

### 11.4 Flag vs caps gate

- Backend `subscription_paywall_enabled=false` (default): `POST /subscriptions/upgrade` → **403**, tier stays free (`test_upgrade_disabled_when_flag_off`).
- Caps still reject when paywall flag false (`test_quota_service` + document create 429 with flag off defaults).
- Flutter: `LexivoSubscriptionFlags.subscriptionPaywallEnabled` defaults **false**; `subscriptionGuard` redirects `/subscription` and `/subscription/upgrade` to account when flag off (router tests).

### 11.5 Shared quota gate

- Single `QuotaService` module; deps inject into `DocumentService` / `ChatService`; OCR re-check in `document_processing.enqueue`.
- One `register_exception_handlers` path for `QuotaExceededError` — no per-router 429 string bodies for quota.

### 11.6 Flutter paywall gate

- `features/subscription/` PaywallScreen / UpgradeScreen; upgrade CTA only when `subscriptionPaywallEnabledProvider` is true.
- Flag default off via dart-define `SUBSCRIPTION_PAYWALL_ENABLED`.
- `UsageSummary` shows used/limit with **no** upgrade button when flag off (widget test); soft note on account injection above.

### 11.7 Navigation / architecture gate

- Named routes `/subscription`, `/subscription/upgrade` + `RouteGuards.subscriptionGuard`; wired via `subscriptionCoreOverrides()` in `main.dart` (barrel only).
- Tree: `data/` / `domain/` / `presentation/` + barrel; architecture guard: **no** `package:dio`, **no** other `features/*` imports under `features/subscription`.
- Datasource uses typed `ApiClient.getSubscriptionMe` / `upgradeSubscription` only; `QuotaFailure` mapped in `ErrorMapper` for 429 + `quota_exceeded`.

### 11.8 UI composition gate

- Compose uses `LexivoButton`, `LexivoErrorBanner`, `LexivoBadge`, `LexivoTypography` / `LexivoSpacing`, `AsyncValueView` → skeleton/error.
- No payment SDK widgets; no feature-local visual atoms beyond layout `Text` + DS tokens (same as prior features).

### 11.9 Scope gate

- No CI/CD pipeline work in subscription commits.
- No Stripe / Play Billing / IAP / RevenueCat dependencies; upgrade is stub API only.
- No email billing / receipts.
- Caps not gated on paywall flag (Settings comment + tests).

### 11.10 TDD / stack gate

- Freezed `SubscriptionStatus` / DTOs + Riverpod providers/notifier.
- Independent: `pytest` **340 passed**, 1 skipped; `flutter test` **413 passed**.
- Fixtures under `test/fixtures/subscription/`; `FakeSubscriptionRepository` + harness helpers.

### 11.11 Final vs OpenSpec + architecture

- OpenSpec scenarios covered: flag off hides paywall UI; flag on reveals upgrade paths (screens + stub); config caps 20/100/500; shared quota + consistent error.
- Architecture §2.1 layering + §2.3 named routes/guards satisfied; subscription listed in feature tree.
- Implementer may land DoD commit after this PASS.

---

## Claimed commits (verified)

| Commit | Summary |
|---|---|
| `b4d3f68` | Settings-driven free-tier quotas + subscriptions API + QuotaService |
| `a8ebf45` | Subscription DTOs, `QuotaFailure` mapping, typed client methods |
| `18f575a` | `features/subscription` paywall behind dart-define (off by default) |

---

## CI/CD proceed?

**Yes.** Subscription STEP 3.7 DoD is met; out-of-scope items (CI/CD, real payments, email billing) were correctly deferred and are appropriate for STEP 3.8 / later work.
