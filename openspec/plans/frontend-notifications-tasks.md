# Frontend Notifications — Task Plan
Capability: **notifications** (Flutter + thin backend notifications API → list/mark-read + job-complete emit via Master `notification` → NotificationStore + PushProvider)
Architecture: `spec/architecture.md` §2.1–§2.3 (feature-first clean architecture; `core/`; no cross-feature imports) + Notification Agent under Master (`run_master("notification")` only) + Push Protocol stub
OpenSpec: `openspec/specs/notifications/spec.md`
UI: compose **ONLY** from `core/design_system` (`Lexivo*` — especially `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoButton`, `LexivoSkeleton`, `LexivoSnackbar`, `LexivoBadge` if unread affordance). List load via shared `AsyncValueView`. Any new visual atom → Design System Agent first — never inline one-offs.
Product: Lexivo
Execution order: **STEP 3.7 next feature** after pdf-export PASS

**Prerequisite (completed)**
- [x] STEP 3.7 pdf-export DoD **PASS** (`openspec/reviews/frontend-pdf-export-step37-review.md`) — notifications may proceed; use named routes + core identity only; **do not** import `features/pdf_export` (or `rag_chat` / `translation` / `summarization` / `ocr` / `document_scan`) internals
- [x] Design-system DoD **PASS** — `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoButton`, `LexivoSnackbar`, `LexivoBadge` available
- [x] Specialized agents STEP 3.6 — Notification Agent (`name=notification`) wired in Master / `NodeRegistry`; `NotificationStore` + `PushProvider` Protocols; `StubPushProvider` under `adapters/push/` — **HTTP NotificationService + notifications CRUD / list / mark-read / job-complete emit still missing** (see §0)

**Out of scope for this file (later plans)**
- subscription / paywall gating
- Email delivery (forbidden in v1 — assert never)
- Scheduled / reminder notification product UI and scheduler (reserve `event_type` if needed; do not build reminder engine)
- Client FCM/APNs SDK wiring / production push credentials (server push stays Protocol + stub; real vendor adapter later)
- Device-token registration HTTP (defer until real PushProvider)
- Reimplementing Notification Agent, Master graph, or push Protocol shape beyond list/mark-read store methods
- Offline Drift sync for notifications; CI/CD; Cloud Run
- New design-system atoms unless a gap is flagged below for Design System Agent

**Product defaults (resolved)**

| Concern | Choice |
|---|---|
| Feature home | `lib/features/notifications/` — authenticated in-app inbox (list + mark-read) |
| Domain models | Feature-owned Freezed `AppNotification` under `features/notifications/domain` — **not** on core `Document` |
| Backend gap | **Include thin notifications API** — no `notifications` ORM, `NotificationService`, list/mark-read routers, or job-complete emit today; Notification Agent + Push stub exist only in agent tests / Master DI — **blocks Flutter** |
| Orchestration | Emit via **only** `run_master("notification", …)` from a thin helper / service called after async job success. **Do not** import `NotificationAgent` in routers/services/tasks. Push only through agent → `PushProvider` |
| Persist | ORM `notifications` (id, user_id, type/event_type, title, body, payload JSON, read_at nullable, created_at) — aligns backend-services “notifications” domain |
| NotificationStore | Extend Protocol beyond `create_notification`: `list_for_user(user_id, …)`, `mark_read(user_id, notification_id)` (and optionally `get`). SQLAlchemy adapter implements Protocol; keep `FakeNotificationStore` in tests |
| List | `GET /api/v1/notifications` (auth) → newest-first list for current user; optional `?unread_only=` |
| Mark read | `POST /api/v1/notifications/{id}/read` (auth + ownership) → sets `read_at`; idempotent if already read; wrong owner / missing → **404** |
| Emit on job complete | After OCR / summary / translation / export Celery success (status ready / job succeeded), call emit helper → Master `notification` with `event_type`/`job_type`, `title`, `body`, `document_id`, `job_id`, `push_enabled` (default **True**). Soft-fail: job success must not roll back if notification emit fails (log + continue) |
| Push | Agent already sends when `push_enabled=True` via Protocol; workers DI `StubPushProvider` (or injected fake in tests). **No** email fields / providers |
| No email | Reject / never call email; extend coupling/guard tests from agent suite into service path |
| Async UI | Inbox is **sync HTTP list** (no `JobPoller`). Refresh on open / pull-to-refresh / after mark-read |
| Empty UX | `LexivoEmptyState` when inbox empty |
| Failed UX | `LexivoErrorBanner` + retry reload |
| Unread UX | Visual unread affordance via layout + optional `LexivoBadge` / emphasis — no new DS atom required |
| Tap / deep link | If payload has `document_id`, navigate via **named** `RouteGuards` only (e.g. documents / OCR / summary / translation / chat / export as product chooses — prefer document library or most relevant ready route; document choice in implementation notes). No feature imports |
| Navigation | Named GoRouter: `/notifications` (`RouteGuards.notifications`). Entry from home / account / app bar via route constants only |
| State | Riverpod (current pin ^2.6.1; prefer 3 when pins allow) |
| Models | Freezed (+ json_serializable only for network DTOs) |
| HTTP | Typed `ApiClient` only — no `Dio(` / `package:dio` inside `features/notifications/` |

**Conventions**
- Loop per chunk: failing test → implement → (widget test where UI) → review vs OpenSpec notifications + architecture §2.1–§2.3 + Lexivo* composition → fix → commit.
- Prefer small sequential commits; never one giant “frontend-notifications” commit.
- Feature public surface = barrel `features/notifications/notifications.dart` only.
- Screens: layout + `Lexivo*` + `AsyncValueView` only. Grep guard: empty inbox **must** use `LexivoEmptyState`; errors **must** use `LexivoErrorBanner`.
- All HTTP via `core/network` `ApiClient`.
- Prefixes: package `lexivo`; UI `Lexivo*`; never `Nexora*`.
- Do **not** import `features/pdf_export/**`, `features/rag_chat/**`, `features/translation/**`, `features/summarization/**`, `features/ocr/**`, `features/document_scan/**`, or any other feature internals. Cross-feature wiring = named routes + injected screen builders only.

**Design-system gap flag**
- Expected composition: notifications screen = `AsyncValueView` for list load + rows (title/body/time + unread affordance via text style / `LexivoBadge`) + mark-read action (`LexivoButton` or row tap) + `LexivoEmptyState` + `LexivoErrorBanner`.
- If a true visual gap appears (e.g. dedicated notification row atom that cannot be layout + existing Lexivo*), **stop and flag Design System Agent** — do not invent feature-local atoms.

**Shared test fixtures (Test Agent ownership)**

| Location | Owns |
|---|---|
| `test/fixtures/notifications/` | JSON: empty list, mixed read/unread, processing-complete OCR/translation/export payloads, mark-read response, 404 wrong owner |
| `test/helpers/` | `FakeNotificationsRepository`, `MockApiClient` list/mark-read stubs |
| `test/core/network/` | `listNotifications` / `markNotificationRead` DTO + ErrorMapper tests |
| `test/features/notifications/` | Domain/data/presentation/flow tests (use helpers; no duplicate fakes) |
| `backend/tests/` | Thin NotificationService/router/store: list ownership, mark-read idempotent, emit → `run_master("notification")` only, job-complete hooks soft-fail, no email / no `NotificationAgent` imports in HTTP/task path |

---

## 0. Backend thin API — NotificationService + store + emit via Master (MISSING today)

OpenAPI / routers expose auth, documents, chats, exports, etc. **No** `notifications` model, **no** `NotificationService`, **no** list/mark-read HTTP path, **no** job-complete emit. Notification Agent + `StubPushProvider` exist; `NotificationStore` Protocol today is **create-only** (in-memory fake) — **blocks Flutter**.

### 0.A Model + schemas + OpenAPI

- [x] 0.1 **Decision gate:** document in this plan / `docs/api_client.md`: list `GET /api/v1/notifications`; mark-read `POST /api/v1/notifications/{id}/read`; emit only via `run_master("notification", …)` after job success; response fields `{ id, type, title, body, payload, read_at, created_at }`
- [x] 0.2 Add ORM model `Notification` (id, user_id FK, type, title, body, payload JSON, read_at nullable, created_at) — migration or create_all-compatible for tests; relationship from User optional
- [x] 0.3 Add Pydantic schemas + OpenAPI snapshot paths: `NotificationResponse`, `NotificationListResponse`; refresh `openapi/lexivo.openapi.json`
- [x] 0.4 Write failing backend tests for schema/serialization of notification list/item (read vs unread)

### 0.B NotificationStore Protocol + SQL adapter

- [x] 0.5 Extend `NotificationStore` Protocol: keep `create_notification`; add `list_for_user(user_id, *, unread_only: bool = False) -> list[dict]` and `mark_read(user_id, notification_id) -> dict | None` (None → not found / wrong owner)
- [x] 0.6 Update `FakeNotificationStore` (+ any Master/agent tests) for new methods; suite stays green for agent unit tests
- [x] 0.7 Write failing tests for SQL/in-DB store adapter: create → list newest-first; mark_read sets `read_at`; double mark-read idempotent; other user’s id → not found
- [x] 0.8 Implement SQLAlchemy `NotificationStore` adapter under `adapters/` or repositories used by the Protocol; wire create path used by Notification Agent to persist real rows when DI uses SQL store

### 0.C Thin NotificationService + job-complete emit (Master only)

- [x] 0.9 Write failing tests: `list_notifications(user_id)` returns only that user’s rows; `mark_read` ownership 404 semantics at service layer
- [x] 0.10 Write failing tests: `emit_job_complete_notification(...)` calls `run_master("notification", input={user_id, event_type/job_type, title, body, document_id, job_id, push_enabled, type?})` with NotificationStore + PushProvider available to Master factory; success creates in-app row (via agent → store)
- [x] 0.11 Write failing tests: emit soft-fails — Master/agent failure does **not** fail the parent job result path (helper returns partial / logs; caller continues)
- [x] 0.12 Assert service/router/task/helper source: **has** `run_master` for emit; **no** `NotificationAgent` / `notification_agent` import (extend coupling test); **no** email SDK / send_email
- [x] 0.13 Implement thin `NotificationService` (list + mark_read) + shared emit helper; Celery OCR / summary / translation / export **success** paths call emit (mirror job types called out in OpenSpec); do not emit on failed jobs
- [x] 0.14 Ensure worker/app DI can construct Master with SQL `NotificationStore` + `StubPushProvider` for emit path (tests may inject fakes)
- [x] 0.15 Review vs OpenSpec “In-app” / “Push” / “No email” / “Notification Agent coordination”; fix; commit backend service slice

### 0.D Router endpoints

- [x] 0.16 Write failing API tests: `GET /api/v1/notifications` auth required; returns user-scoped list (empty + populated)
- [x] 0.17 Write failing API tests: `POST /api/v1/notifications/{id}/read` auth + ownership; idempotent; 404 for missing/other user
- [x] 0.18 Implement thin `notifications` router — call `NotificationService` only; no agent imports
- [x] 0.19 Refresh OpenAPI snapshot; wire router in app; commit
- [x] 0.20 Optional: assert push still only via Protocol inside Notification Agent (HTTP path never calls `PushProvider` directly)

---

## 1. Typed client + fixtures (Flutter)

- [x] 1.1 Write failing `ApiClient` / DTO unit tests: `listNotifications`; `markNotificationRead`; parse id, type, title, body, payload, nullable `readAt`, `createdAt`
- [x] 1.2 Write failing tests: HTTP 404 mark-read → mapped failure; unauthenticated → existing auth error mapping
- [x] 1.3 Add Freezed DTOs (`NotificationDto`, `NotificationListDto`) aligned to OpenAPI
- [x] 1.4 Implement `ApiClient.listNotifications` / `markNotificationRead`; update `docs/api_client.md` (`TODO(openapi-codegen)` note)
- [x] 1.5 Add/update fixtures under `test/fixtures/notifications/`
- [x] 1.6 Review vs OpenSpec typed client / module boundaries; fix; commit

---

## 2. Feature scaffold (§2.1)

- [x] 2.1 Create `lib/features/notifications/` tree: `data/{datasources,repositories,models}/`, `domain/{entities,repositories,usecases}/`, `presentation/{screens,widgets,providers}/`, barrel `notifications.dart`
- [x] 2.2 Write failing barrel smoke: exports public inbox screen builder / providers needed by router — **not** data-layer types
- [x] 2.3 Review vs architecture §2.1 folder contract; fix; commit scaffold

---

## 3. Domain — repository + usecases

- [x] 3.1 Define abstract `NotificationsRepository`: `listNotifications()`, `markRead(id)` → `Result` + feature `AppNotification`
- [x] 3.2 Freezed domain `AppNotification` (id, type, title, body, payload map, readAt?, createdAt, helpers `isUnread`)
- [x] 3.3 Write failing usecase tests (fake repo): `ListNotifications`, `MarkNotificationRead`; success/failure `Result` shapes
- [x] 3.4 Write failing tests: empty list is valid success; mark-read updates unread → read
- [x] 3.5 Implement usecases — each single `call()`, returns `Result`
- [x] 3.6 Review vs OpenSpec in-app list + design-system empty scenario; fix; commit

---

## 4. Data layer — remote + repository impl

- [x] 4.1 Write failing tests for `NotificationsRemoteDatasource`: list / mark-read via `ApiClient` only; DTO→domain mapping; failures via `ErrorMapper`/`Result`
- [x] 4.2 Implement datasource + `NotificationsRepositoryImpl`
- [x] 4.3 Riverpod providers for repository + usecases (override-friendly)
- [x] 4.4 Assert no `package:dio` and no other `features/*` imports under `features/notifications/`; fix; commit

---

## 5. Presentation — providers (Riverpod)

- [x] 5.1 Write failing provider tests: open inbox → loading → data list `AsyncValue`
- [x] 5.2 Write failing tests: empty list → data empty (UI layer shows EmptyState)
- [x] 5.3 Write failing tests: load failure → error; retry reloads
- [x] 5.4 Write failing tests: mark-read on item → list updates (optimistic or refetch); 404 surfaces error without wiping inbox unless refetch fails
- [x] 5.5 Implement notifier(s) (`notificationsInboxProvider`, etc.) — **no** feature-local `JobPoller` / `Timer` poll loop
- [x] 5.6 Review vs OpenSpec in-app display; fix; commit

---

## 6. Presentation — inbox screen (LexivoEmptyState + LexivoErrorBanner)

- [x] 6.1 Write failing widget tests for **NotificationsScreen** (name flexible): loading → `AsyncValueView` / `LexivoSkeleton`; empty → **`LexivoEmptyState`**; failed → **`LexivoErrorBanner`**; data → list rows
- [x] 6.2 Write failing tests: unread vs read visual distinction; mark-read CTA / tap clears unread; processing-complete copy visible from fixture title/body
- [x] 6.3 Implement screen composing Lexivo* + layout only; **no** subscription CTAs; **no** email preference UI; **no** push-vendor settings beyond optional future stub
- [x] 6.4 Grep guard: production notifications UI uses `LexivoEmptyState` + `LexivoErrorBanner` for empty/error; Lexivo* for primary actions; fix; commit
- [x] 6.5 Review vs OpenSpec “Design-system presentation” + “Empty inbox”; fix; commit

---

## 7. Routing + navigation entry

- [x] 7.1 Write failing router tests: authenticated route `/notifications`; unauthenticated → sign-in; named routes only
- [x] 7.2 Extend `RouteGuards` + `app_router` with `notifications`; inject builders from `notifications` barrel — **no** importing `notifications/presentation` from other features’ data layers
- [x] 7.3 Wire home / account / app chrome CTA → `context.go(RouteGuards.notifications)` using **only** `core/routing` helpers
- [x] 7.4 Optional deep link: row with `document_id` → named document route only; ensure other features still have **zero** imports of `features/notifications/data` or internal widgets
- [x] 7.5 Review vs architecture §2.3 navigation contract; fix; commit

---

## 8. End-to-end feature flow (widget/integration-ish)

- [x] 8.1 Write failing flow test: open inbox → see processing-complete notification from fixture → mark read → unread cleared
- [x] 8.2 Write failing flow test: empty inbox → `LexivoEmptyState`
- [x] 8.3 Write failing flow test: list error → `LexivoErrorBanner` + retry recovers
- [x] 8.4 Wire providers in app bootstrap overrides alongside prior features; bearer token still injected; review full OpenSpec notifications **client** scenarios; fix; commit

---

## 9. Shared fixtures hygiene (Test Agent)

- [x] 9.1 Add/extend `FakeNotificationsRepository` + helpers under `test/helpers/`
- [x] 9.2 Add/update `test/fixtures/notifications/*.json` for empty / unread+read / OCR·translation·export complete / mark-read / 404
- [x] 9.3 Keep fixture map in this plan’s table updated; commit

---

## 10. Reviewer gate checkpoints (STEP 3.7 notifications slice)

Run after §§0–9 land; blockers must be fixed before declaring this slice done.

- [ ] 10.1 **Prerequisite gate:** pdf-export STEP 3.7 review still PASS; no regression in auth/core/document_scan/ocr/summarization/translation/rag_chat/pdf_export suites
- [ ] 10.2 **Backend Master gate:** job-complete emit enters only via `run_master("notification", …)`; no `NotificationAgent` imports in router/service/task; list/mark-read ownership correct; soft-fail emit does not break job success
- [ ] 10.3 **Push / no-email gate:** push only via `PushProvider` Protocol inside Notification Agent; Stub (or fake) in tests; **no** email delivery path
- [ ] 10.4 **In-app UI gate:** inbox list + mark-read; empty → `LexivoEmptyState`; error → `LexivoErrorBanner`; `AsyncValueView` + Lexivo*
- [ ] 10.5 **Agent coordination gate:** delivery coordinated under Master Notification Agent — HTTP path does not embed push SDKs
- [ ] 10.6 **Navigation gate:** entry via named `/notifications` only; optional doc deep link via `RouteGuards` only; no cross-feature widget/data imports
- [ ] 10.7 **Clean architecture gate:** §2.1 tree + barrel-only outside; no Dio inside feature; typed `ApiClient` only
- [ ] 10.8 **UI composition gate:** Lexivo* only; any DS gap flagged, not inlined
- [ ] 10.9 **Scope gate:** no subscription gating; no email; no reminder scheduler; no production FCM client required; backend limited to thin NotificationService/store/router + emit hooks + OpenAPI
- [ ] 10.10 **TDD / stack gate:** Freezed + Riverpod; `flutter test` green for core + notifications (+ prior features); backend notifications API + emit tests green
- [ ] 10.11 Final review vs `openspec/specs/notifications/spec.md` + architecture §2.1–§2.3; fix remaining gaps; commit “frontend notifications STEP 3.7 slice DoD met”

---

## Definition of Done (STEP 3.7 — notifications)

- [ ] Thin backend notifications API: list + mark-read; ORM persist; SQL `NotificationStore`; job-complete emit via `run_master("notification")` only; push via Protocol stub; no email
- [ ] `features/notifications/` clean architecture + barrel; typed API client only
- [ ] Inbox UI with empty/error via `LexivoEmptyState` / `LexivoErrorBanner`; mark-read works
- [ ] Navigate to inbox via named routes only; no cross-feature imports
- [ ] Reviewer gates 10.1–10.11 passed
- [ ] Out of scope preserved (subscription; email; reminder engine; production push SDKs)

---

## Coverage matrix (planner verification)

| Requirement (OpenSpec / architecture) | Plan section |
|---|---|
| In-app notifications for job completion (OCR, translation, export, similar) | §0.2, §0.10, §0.13, §3–6, §8.1, §10.2 / §10.4 |
| Processing complete appears in-app | §0.10–0.13, §6.2, §8.1 |
| Push on job complete (Protocol; enabled) | §0.10, §0.14, §0.20, §10.3 |
| No email in v1 | §0.12, Out of scope, §10.3 / §10.9 |
| Notification Agent coordination via Master | §0.10–0.12, §10.2 / §10.5 |
| Design-system EmptyState / ErrorBanner | §6, §8.2–8.3, §10.4 / §10.8 |
| Feature `notifications/` + typed client | §1–4, §10.7 |
| pdf-export prerequisite completed | Prerequisites (PASS review) |
| Out of scope: subscription / email | Out of scope, §10.9 |

**Client OpenSpec scenarios covered:** **Yes** — in-app list, empty inbox LexivoEmptyState, push coordinated via agent/Protocol (server), no email.

**Backend API tasks included:** **Yes** — dedicated §0 (notifications model + store list/mark-read + NotificationService + emit hooks + routers) because notifications endpoints and persist/list path are missing from current OpenAPI/routers.

**Task count:** **73** numbered TDD/gate tasks (0.1–0.20, 1.1–1.6, 2.1–2.3, 3.1–3.6, 4.1–4.4, 5.1–5.6, 6.1–6.5, 7.1–7.5, 8.1–8.4, 9.1–9.3, 10.1–10.11). Prerequisites (3) marked completed above and excluded. DoD summary list (6) is a roll-up of those gates, not extra work items.

---

## Reviewer

*(Leave blank for Reviewer Agent — fill after implementation.)*

| Field | Value |
|---|---|
| **Capability** | notifications (Flutter + thin notifications API) |
| **Reviewer** | |
| **Date** | |
| **Sources** | `openspec/specs/notifications/spec.md`, `spec/architecture.md` §2.1–§2.3, this plan §10, `openspec/reviews/frontend-pdf-export-step37-review.md` |
| **Verdict** | |

### Gate results

| # | Gate | Result |
|---|---|---|
| 10.1 | Prerequisite — pdf-export STEP 3.7 still PASS | |
| 10.2 | Backend Master — `run_master("notification")` only; list/mark-read; soft-fail emit | |
| 10.3 | Push Protocol + no email | |
| 10.4 | In-app UI — list/mark-read; LexivoEmptyState / LexivoErrorBanner | |
| 10.5 | Agent coordination — Master Notification Agent | |
| 10.6 | Navigation — named routes only | |
| 10.7 | Clean architecture — §2.1 + typed client | |
| 10.8 | UI composition — Lexivo* | |
| 10.9 | Scope — no subscription/email/reminder engine/FCM client | |
| 10.10 | TDD / stack — flutter + backend tests green | |
| 10.11 | Final vs OpenSpec + architecture | |

### Notes

-
