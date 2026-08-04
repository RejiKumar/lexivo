# Frontend Notifications STEP 3.7 Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | notifications (Flutter + thin notifications API) + architecture §2.1–§2.3 |
| **Reviewer** | Reviewer Agent (independent) |
| **Date** | 2026-08-04 |
| **Sources** | `openspec/specs/notifications/spec.md`, `spec/architecture.md` §2.1–§2.3, `openspec/plans/frontend-notifications-tasks.md` §10, prior `openspec/reviews/frontend-pdf-export-step37-review.md` |
| **Claimed** | notifications API + `features/notifications`; commits `109dfdf`, `71484b2`, `6a9aba6`; §10 open |
| **Verdict** | **PASS** |

---

## Verdict

**PASS** — STEP 3.7 notifications slice Definition of Done is met. Plan gates 10.1–10.11 all pass. Independent runs: backend **324 passed** (1 skipped); `flutter test` **388 passed**. No findings that block DoD or subscription follow-on.

**Is STEP 3.7 notifications DoD met?** **Yes.**

**May subscription feature proceed?** **Yes.** In-app inbox + Master emit + PushProvider stub are in place; email remains forbidden; subscription/paywall gating was correctly deferred. Do not import `features/notifications` (or prior feature) internals from subscription — use named routes + core identity only.

---

## Findings

No findings.

### Soft notes (non-blocking)

1. Inbox row with `document_id` deep-links to `RouteGuards.documentOcr(docId)` for all job types — plan allows that product choice; named route only (no cross-feature imports).
2. `LexivoErrorBanner` is composed via shared `AsyncValueView` (not a direct import on `NotificationsScreen`) — same pattern as prior STEP 3.7 features; widget/flow tests assert the banner.
3. Production FCM/APNs client and device-token HTTP remain out of scope (Protocol + `StubPushProvider` only) — as planned.

---

## Gate-by-gate results

| # | Gate | Result |
|---|---|---|
| 10.1 | Prerequisite — pdf-export STEP 3.7 still PASS; no auth/core/document_scan/ocr/summarization/translation/rag_chat/pdf_export regression | **PASS** |
| 10.2 | Backend Master — `run_master("notification")` only; list/mark-read; soft-fail emit | **PASS** |
| 10.3 | Push Protocol + no email | **PASS** |
| 10.4 | In-app UI — list/mark-read; LexivoEmptyState / LexivoErrorBanner | **PASS** |
| 10.5 | Agent coordination — Master Notification Agent | **PASS** |
| 10.6 | Navigation — named routes only | **PASS** |
| 10.7 | Clean architecture — §2.1 + typed client | **PASS** |
| 10.8 | UI composition — Lexivo* | **PASS** (soft notes) |
| 10.9 | Scope — no subscription/email/reminder engine/FCM client | **PASS** |
| 10.10 | TDD / stack — flutter + backend tests green | **PASS** |
| 10.11 | Final vs OpenSpec notifications + architecture §2.1–§2.3 | **PASS** |
| — | subscription may proceed | **Yes** |

---

## Evidence

### 10.1 Prerequisite gate

- Pdf-export STEP 3.7 review remains **PASS** (`openspec/reviews/frontend-pdf-export-step37-review.md`); notifications was cleared to proceed.
- Independent full Flutter suite **388 passed** — includes auth, core, document_scan, ocr, summarization, translation, rag_chat, pdf_export, and notifications; no regression observed (prior pdf-export baseline was 364).
- Full backend pytest **324 passed**, 1 skipped — prior claim baseline was 311; net growth matches notifications API + related coverage.

### 10.2 Backend Master gate

- Commits: `109dfdf` (thin notifications API with Master emit and SQL store), covered by `backend/tests/test_notification_api.py` + agent unit tests.
- `emit_job_complete_notification` calls `await run_master("notification", …)` with `notification_store` + `push`; soft-fails (log + `None`) on Master/agent errors so parent job success is preserved.
- Celery success paths in `document_processing` (OCR), `summary`, `translation`, and `export` call the emit helper **after** job success; failed-job paths do not emit.
- `NotificationService` list/mark-read ownership: wrong owner / missing → `NotFoundError` → HTTP **404**; mark-read idempotent when already read.
- Source guards: service/router/tasks have **no** `NotificationAgent` / `notification_agent` imports; service has `run_master`; tasks import emit helper only.

### 10.3 Push / no-email gate

- Push only inside `NotificationAgent` via `PushProvider.send` when `push_enabled=True`; workers/tests use `StubPushProvider` / `FakePushProvider`.
- HTTP router never references `PushProvider`.
- Agent rejects `email` / `send_email` input; result always `email_sent: False`; coupling/source asserts exclude `send_email` / `smtplib` on service, router, and task modules.

### 10.4 In-app UI gate

- `NotificationsScreen` wraps `notificationsInboxProvider` in `AsyncValueView`:
  - empty → **`LexivoEmptyState`** (“No notifications yet”)
  - error → **`LexivoErrorBanner`** (+ retry → refresh)
  - loading → `LexivoSkeleton` via `AsyncValueView`
  - data → list rows with unread emphasis + optional `LexivoBadge` “New”; tap mark-read
- Sync HTTP list only — **no** feature-local `JobPoller` / `Timer` poll loop; pull-to-refresh + refresh after mark-read.

### 10.5 Agent coordination gate

- Delivery coordinated under Master Notification Agent (`name=notification` in registry); emit path never embeds push vendor SDKs in routers/services/tasks.
- Agent returns `AgentResult` with in-app + push outcome; does not call other agents.

### 10.6 Navigation gate

- Authenticated route `/notifications` (`RouteGuards.notifications`); unauthenticated → sign-in (router tests).
- Home shell CTA → `context.go(RouteGuards.notifications)` via `LexivoButton` + `core/routing` only (auth does not import notifications feature).
- Core route wired via `notificationsScreenBuildersProvider` / `notificationsCoreOverrides()` from barrel in `main.dart`.
- Optional deep link: payload `document_id` → named OCR route only; no imports of other features’ data/widgets from notifications; other features do not import notifications internals.

### 10.7 Clean architecture gate

- Tree: `data/` (datasource, mappers, repository_impl) / `domain/` (entities, repository, usecases) / `presentation/` (providers, screen) + barrel `notifications.dart`.
- Datasource uses typed `ApiClient.listNotifications` / `markNotificationRead` only; architecture guard: **no** `package:dio` and **no** other `features/*` imports under `features/notifications`.
- Freezed domain `AppNotification` (+ DTOs on core network); OpenAPI paths `/api/v1/notifications` and `.../{id}/read` present.

### 10.8 UI composition gate

- Compose uses `LexivoEmptyState`, `LexivoBadge`, `LexivoTypography` / `LexivoSpacing`, `AsyncValueView` → `LexivoErrorBanner` / `LexivoSkeleton`.
- No feature-local visual atoms; no subscription CTAs; no email preference UI.
- Soft notes above (OCR-only deep link choice; ErrorBanner via `AsyncValueView`).

### 10.9 Scope gate

- No subscription/paywall gating on inbox.
- No email delivery; no reminder scheduler product UI.
- No production FCM/APNs client or device-token registration HTTP.
- Backend limited to thin NotificationService + SQL `NotificationStore` + router + emit hooks + OpenAPI; Notification Agent / Push Protocol shape not rewritten beyond list/mark-read store methods.

### 10.10 TDD / stack gate

- Freezed entities + Riverpod `AsyncNotifierProvider` for inbox.
- Independent: `pytest` **324 passed**, 1 skipped; `flutter test` **388 passed**.
- Focused: `tests/test_notification_api.py` + `test_notification_agent.py` **19 passed**; Flutter `test/features/notifications` + network notifications client tests green in suite.
- Fixtures under `test/fixtures/notifications/` + `FakeNotificationsRepository` / harness present.

### 10.11 Final vs OpenSpec + architecture

| OpenSpec / architecture requirement | Evidence |
|---|---|
| In-app notifications for job completion | Persist via agent → store; list UI; emit after OCR/summary/translation/export success |
| Processing complete appears in-app | Emit + inbox list/mark-read; flow widget tests |
| Push on job complete (Protocol) | Agent → `PushProvider`; stub in workers/tests |
| No email in v1 | Agent reject + source guards + `email_sent: False` |
| Notification Agent under Master | `run_master("notification")` only from emit helper |
| Empty → LexivoEmptyState; error → LexivoErrorBanner | Screen + flow/widget tests |
| Feature `notifications/` + typed client | §2.1 tree + barrel; `ApiClient` only |
| Named routes; no cross-feature internals | `/notifications` + RouteGuards deep link |
| pdf-export prerequisite | Prior review PASS; suites green |

---

## Commits reviewed

| Commit | Summary |
|---|---|
| `109dfdf` | Thin notifications API: ORM/migration, SQL store, NotificationService + Master emit, router, OpenAPI, Celery hooks |
| `71484b2` | Typed notification DTOs + `ApiClient` list/mark-read + fixtures/helpers |
| `6a9aba6` | `features/notifications` inbox (Lexivo empty/error), routing, Riverpod, feature tests |

---

## Definition of Done checklist

- [x] Thin backend notifications API: list + mark-read; ORM persist; SQL `NotificationStore`; job-complete emit via `run_master("notification")` only; push via Protocol stub; no email
- [x] `features/notifications/` clean architecture + barrel; typed API client only
- [x] Inbox UI with empty/error via `LexivoEmptyState` / `LexivoErrorBanner`; mark-read works
- [x] Navigate to inbox via named routes only; no cross-feature imports
- [x] Reviewer gates 10.1–10.11 passed
- [x] Out of scope preserved (subscription; email; reminder engine; production push SDKs)
