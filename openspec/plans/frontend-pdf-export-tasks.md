# Frontend PDF Export — Task Plan
Capability: **pdf-export** (Flutter + thin backend export API → Master `export` → StorageProvider signed URL)
Architecture: `spec/architecture.md` §2.1–§2.3 (feature-first clean architecture; `core/`; shared `Document` in `core/entities`; no cross-feature imports; reuse `job_poller` + `AsyncValueView`) + exports service/router + StorageProvider
OpenSpec: `openspec/specs/pdf-export/spec.md`
UI: compose **ONLY** from `core/design_system` (`Lexivo*` — especially `LexivoButton`, `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoSnackbar`, `LexivoDialog` / bottom sheet if used for confirm). Loading/error/data via shared `AsyncValueView`. Any new visual atom → Design System Agent first — never inline one-offs.
Product: Lexivo
Execution order: **STEP 3.7 next feature** after rag-chat PASS

**Prerequisite (completed)**
- [x] STEP 3.7 rag-chat DoD **PASS** (`openspec/reviews/frontend-rag-chat-step37-review.md`) — pdf_export may proceed; use named routes + core `Document` identity; **do not** import `features/rag_chat` (or `translation` / `summarization` / `ocr` / `document_scan`) internals
- [x] Design-system DoD **PASS** — `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoButton`, `LexivoSnackbar` (and related) available
- [x] Specialized agents STEP 3.6 — Export Agent (`name=export`) wired in Master / `NodeRegistry`; StorageProvider signed URL path covered in agent tests — **HTTP ExportService + exports CRUD / job status still missing** (see §0)

**Out of scope for this file (later plans)**
- notifications feature (push / in-app “processing complete” via Notification Agent) — UI completes via `JobPoller` only in this slice
- subscription / paywall gating of export
- Reimplementing Export Agent, StorageProvider adapters, Master graph, or PDF builder internals
- Client-side PDF generation / vendor storage SDKs
- Promoting `ChatMessage` to `core/entities` (server assembles chat annotations; Flutter sends toggles only)
- Offline Drift sync for exports; CI/CD; Cloud Run
- New design-system atoms unless a gap is flagged below for Design System Agent

**Product defaults (resolved)**

| Concern | Choice |
|---|---|
| Feature home | `lib/features/pdf_export/` — per-document section toggles + export trigger + download when ready |
| Shared identity | Core Freezed `Document` for document id / title / readiness signals already on Document (`summaryStatus`, `translationStatus`, OCR `status`); never import other features’ data/presentation |
| Export domain models | Feature-owned `ExportJob` / section-toggle value objects under `features/pdf_export/domain` — **not** new fields on core `Document` unless OpenAPI forces a pointer (prefer separate export resource) |
| Backend gap | **Include thin export API** — no `exports` ORM, `ExportService`, `exports` router, or Celery `run_export` today; Export Agent callable only via Master in tests — **blocks Flutter** |
| Orchestration | Thin `ExportService` / Celery task calls **only** `run_master("export", …)` with section toggles + **assembled content** (summary / translation / chat text). **Do not** import `ExportAgent` in router/service/task. Agent uses StorageProvider only (already) |
| Content assembly | **Service layer** loads from DB: summary ← `short_summary`/`detailed_summary` (prefer detailed, or short+detailed joined); translation ← `translated_text`; chat annotations ← format owned chat messages (`User:` / `Assistant:` lines). Client does **not** upload PDF body text |
| Trigger | `POST /api/v1/documents/{doc_id}/export` (auth) body `{ include_summary, include_translation, include_chat }` → create Export row + Job `job_type=export` + enqueue; returns export id + `export_status=processing` |
| Poll | `GET /api/v1/documents/{doc_id}/export/status` (latest for doc) **or** `GET /api/v1/exports/{export_id}` → `{ id, document_id, export_status, include_*, signed_url? }`; client uses core `JobPoller` only — **no** feature-local poll loop |
| Persist | ORM `exports` (id, user_id, document_id, include_* bools, status `idle`\|`processing`\|`ready`\|`failed`, storage_key nullable, signed_url nullable/ephemeral, error nullable, timestamps) + Job row; refresh OpenAPI |
| Signed URL | On success persist `storage_key` + `signed_url` from Master/`AgentResult.data`; client downloads via URL — **no** public bucket |
| Validation | ≥1 toggle true else **422**; `include_summary` requires `summary_status=ready` + non-empty summary text else **409**; same for translation; `include_chat` requires ≥1 chat message for user+doc else **409**; wrong owner / missing doc → **404** |
| Async | **Yes** — PDF + storage latency → Celery `run_export` (mirror summary/translation) + JobPoller |
| Ready UX | When `export_status == ready` and `signed_url` present → primary CTA opens/downloads URL (`url_launcher` or equivalent platform launch; add dep if missing). Do not require public bucket |
| Processing UX | Skeleton / processing copy while `JobPoller` runs; do not treat stale prior export as success after a new request |
| Failed UX | `LexivoErrorBanner` / snackbar; `onRetry` = re-POST with same toggles + re-poll |
| Empty toggles UX | Disable export CTA or surface validation before POST; map 422 clearly |
| Navigation | Named GoRouter: `/documents/:documentId/export` (`RouteGuards.documentExport`). Chat / translation / summary / OCR / library navigate via route constants only |
| State | Riverpod (current pin ^2.6.1; prefer 3 when pins allow) |
| Models | Freezed (+ json_serializable only for network DTOs) |
| HTTP | Typed `ApiClient` only — no `Dio(` / `package:dio` inside `features/pdf_export/` |
| Notifications | Spec mentions processing-complete notification — **deferred** to notifications plan; this slice Completes UX via poller |

**Conventions**
- Loop per chunk: failing test → implement → (widget test where UI) → review vs OpenSpec pdf-export + architecture §2.1–§2.3 + Lexivo* composition → fix → commit.
- Prefer small sequential commits; never one giant “frontend-pdf-export” commit.
- Feature public surface = barrel `features/pdf_export/pdf_export.dart` only.
- Screens: layout + `Lexivo*` + `AsyncValueView` only. Grep guard: no ad-hoc primary buttons as interactive atoms; no feature-local `Timer` poll loops.
- All HTTP via `core/network` `ApiClient`.
- Prefixes: package `lexivo`; UI `Lexivo*`; never `Nexora*`.
- Do **not** import `features/rag_chat/**`, `features/translation/**`, `features/summarization/**`, `features/ocr/**`, `features/document_scan/**`, or any other feature internals. Cross-feature wiring = named routes + injected screen builders only.
- Thin CTA from chat (and/or translation / summary / OCR / library): `context.go` export route by id — still no `features/pdf_export/...` imports inside those features beyond route constants in `core/routing`.

**Design-system gap flag**
- Expected composition: export screen = section toggle rows (label + themed `Switch` / selectable `LexivoButton` or `LexivoBadge` + layout — no rag/summary models in DS) + export `LexivoButton` + `AsyncValueView` for job state (`LexivoSkeleton` / `LexivoErrorBanner` / ready download CTA).
- If a true visual gap appears (e.g. dedicated `LexivoSwitch` / `LexivoToggleRow` that cannot be Switch-themed via LexivoTheme + tokens), **stop and flag Design System Agent** — do not invent feature-local atoms.

**Shared test fixtures (Test Agent ownership)**

| Location | Owns |
|---|---|
| `test/fixtures/exports/` (or `documents/`) | JSON: export processing/ready/failed; all-sections / summary-only; 409 section-not-ready; 422 no toggles; signed_url ready envelope |
| `test/helpers/` | `FakePdfExportRepository`, `MockApiClient` export POST/status stubs, controllable `JobPoller` clock/fake reuse |
| `test/core/network/` | `requestExport` / `getExportStatus` DTO + ErrorMapper (409/422) tests |
| `test/features/pdf_export/` | Domain/data/presentation/flow tests (use helpers; no duplicate fakes) |
| `backend/tests/` | Thin ExportService/router/task: toggles validation, section readiness, `run_master("export")` only, signed_url persist, failure → failed |

---

## 0. Backend thin API — ExportService + Master export + job status (MISSING today)

OpenAPI / routers expose documents + summary + translation + chats. **No** `exports` model, **no** `ExportService`, **no** export HTTP path, **no** Celery `run_export`. Export Agent is callable only via Master in agent tests — **blocks Flutter**.

### 0.A Model + schemas + OpenAPI

- [x] 0.1 **Decision gate:** document in this plan / `docs/api_client.md`: trigger `POST /api/v1/documents/{doc_id}/export` body `{ include_summary, include_translation, include_chat }`; poll `GET /api/v1/documents/{doc_id}/export/status` (latest) and/or `GET /api/v1/exports/{export_id}`; readiness per selected section; Master intent `export`; response includes `signed_url` when ready
- [x] 0.2 Add ORM model `Export` (id, user_id, document_id, include_summary/translation/chat, status enum, storage_key, signed_url nullable, error_message nullable, timestamps) — migration or create_all-compatible for tests; relationship from Document optional
- [x] 0.3 Add Pydantic schemas + OpenAPI snapshot paths: `ExportRequest`, `ExportResponse` / `ExportStatusResponse` (status + toggles + optional `signed_url`); refresh `openapi/lexivo.openapi.json`
- [x] 0.4 Write failing backend tests for schema/serialization of export request/response

### 0.B Thin ExportService + Celery task (Master only)

- [x] 0.5 Write failing tests: enqueue rejects missing/wrong-owner doc → not found; zero toggles → validation (HTTP 422); `include_summary` without ready summary content → conflict (HTTP 409); same for translation; `include_chat` with empty chat → 409
- [x] 0.6 Write failing tests: success path creates Export `processing` + Job `job_type=export`; Celery `run_export` assembles section content then calls `run_master("export", input={document_id, include_*, summary?, translation?, chat?, …})` with StorageProvider available to Master factory; on success persists `storage_key` + `signed_url` + `ready`; on agent failure → `failed`
- [x] 0.7 Write failing tests: summary-only toggle → Master input has only summary content / flags; omitted sections not required
- [x] 0.8 Assert service/router/task source: **has** `run_master`; **no** `ExportAgent` / `export_agent` import (extend coupling test)
- [x] 0.9 Implement thin `ExportService` + `enqueue_export` / `run_export` in tasks — status updates at task/service layer; do not mutate OCR/summary/translation fields; chat formatting in service only
- [x] 0.10 Review vs OpenSpec “Export Agent and storage” + “Multi-section PDF export”; fix; commit backend service slice

### 0.C Router endpoints

- [x] 0.11 Write failing API tests: `POST /api/v1/documents/{doc_id}/export` auth + ownership; 422 no toggles; 409 section not ready; 202/200 when enqueued (`export_status=processing`)
- [x] 0.12 Write failing API tests: status GET returns processing/ready/failed; ready includes time-limited `signed_url`; failed allows retry via new POST
- [x] 0.13 Implement thin exports router (or documents sub-routes per architecture `exports.py`) — call `ExportService` only; no agent imports
- [x] 0.14 Refresh OpenAPI snapshot; wire router in app; commit
- [x] 0.15 Optional: assert StorageProvider still used only inside Export Agent (service does not call R2/boto3 directly)

---

## 1. Typed client + fixtures (Flutter)

- [x] 1.1 Write failing `ApiClient` / DTO unit tests: `requestExport` (POST toggles); `getExportStatus` (or get-by-id); parse status, toggles, nullable `signed_url`
- [x] 1.2 Write failing tests: HTTP 409 section-not-ready → `ValidationFailure` (or dedicated); HTTP 422 no toggles → `ValidationFailure`; extend `ErrorMapper` if needed
- [x] 1.3 Add Freezed DTOs (`ExportRequestDto`, `ExportDto` / `ExportStatusDto`) aligned to OpenAPI
- [x] 1.4 Implement `ApiClient.requestExport` / `getExportStatus`; update `docs/api_client.md` (`TODO(openapi-codegen)` note)
- [x] 1.5 Add/update fixtures under `test/fixtures/exports/` (or documents)
- [x] 1.6 Review vs OpenSpec “Generated client and module boundaries” / typed client exclusively; fix; commit

---

## 2. Core shared entity — `Document` identity only

Architecture §2.3: pdf_export depends on core `Document` for document identity / existing readiness fields. Export job entity stays feature-owned.

- [x] 2.1 Write failing unit tests (if gaps): feature may read `Document.summaryStatus` / `translationStatus` / `status` for **UI hints** (disable toggle when section empty) without importing other features; no required new Document fields
- [x] 2.2 Confirm `lib/core/entities/document.dart` unchanged **or** only additive if a documented export pointer is required — do not break chat/translation/summary/OCR fields
- [x] 2.3 Update any broken constructors/tests if Document touched; suite stays green
- [x] 2.4 Review vs architecture §2.3; fix; commit

---

## 3. Feature scaffold (§2.1)

- [x] 3.1 Create `lib/features/pdf_export/` tree: `data/{datasources,repositories,models}/`, `domain/{entities,repositories,usecases}/`, `presentation/{screens,widgets,providers}/`, barrel `pdf_export.dart`
- [x] 3.2 Write failing barrel smoke: exports public export screen builder / providers needed by router — **not** data-layer types
- [x] 3.3 Review vs architecture §2.1 folder contract; fix; commit scaffold

---

## 4. Domain — repository + usecases

- [x] 4.1 Define abstract `PdfExportRepository` (name flexible): `requestExport(docId, toggles)`, `getExportStatus(docId|exportId)` → `Result` + feature `ExportJob`
- [x] 4.2 Freezed domain `ExportJob` + `ExportSectionToggles` (includeSummary / includeTranslation / includeChat) — feature domain only
- [x] 4.3 Write failing usecase tests (fake repo): `RequestPdfExport`, `Watch/GetExportStatus`; success/failure/409/422 `Result` shapes
- [x] 4.4 Write failing tests: ready job exposes `signedUrl`; failed job exposes error for retry
- [x] 4.5 Implement usecases — each single `call()`, returns `Result`
- [x] 4.6 Review vs OpenSpec multi-section + signed download + failure/retry; fix; commit

---

## 5. Data layer — remote + repository impl

- [x] 5.1 Write failing tests for `PdfExportRemoteDatasource`: POST / status via `ApiClient` only; DTO→domain mapping including `signedUrl`; failures via `ErrorMapper`/`Result`
- [x] 5.2 Implement datasource + `PdfExportRepositoryImpl`
- [x] 5.3 Riverpod providers for repository + usecases (override-friendly)
- [x] 5.4 Assert no `package:dio` and no `features/rag_chat` / `translation` / `summarization` / `ocr` / `document_scan` imports under `features/pdf_export/`; fix; commit

---

## 6. Presentation — providers (Riverpod + JobPoller)

- [x] 6.1 Write failing provider tests: open export for doc → initial idle / prior status `AsyncValue`
- [x] 6.2 Write failing tests: submit toggles → processing → core `JobPoller` polls until ready with `signedUrl`
- [x] 6.3 Write failing tests: 409 / 422 → clear error **without** starting poller; failed terminal status → error + retry
- [x] 6.4 Write failing tests: summary-only vs all-sections request bodies match toggles
- [x] 6.5 Implement notifier(s) (`pdfExportProvider` family by document id, etc.) — **must** use shared `JobPoller` (mirror summarization/translation); no feature-local `Timer` loop
- [x] 6.6 Review vs OpenSpec “Async export jobs” + failure/retry; fix; commit

---

## 7. Presentation — export screen (Lexivo* + section toggles)

- [x] 7.1 Write failing widget tests for **PdfExportScreen** (name flexible): loading → `AsyncValueView` / `LexivoSkeleton`; idle toggles UI; failed → `LexivoErrorBanner`; ready → download/open CTA
- [x] 7.2 Write failing tests: three section toggles (summary / translation / chat annotations); export CTA disabled or validates when none selected; processing shows skeleton/processing affordance
- [x] 7.3 Implement screen composing Lexivo* + layout only; **no** subscription CTAs; **no** notification preference UI
- [x] 7.4 Grep guard: production pdf_export UI uses Lexivo* for primary actions; no feature-local JobPoller clone; fix; commit
- [x] 7.5 Review vs OpenSpec per-section toggles + Lexivo composition; fix; commit

---

## 8. Routing + navigation from chat / translation / summary / OCR / library

- [x] 8.1 Write failing router tests: authenticated route `/documents/:documentId/export`; unauthenticated → sign-in; named routes only
- [x] 8.2 Extend `RouteGuards` + `app_router` with `documentExport`; inject builders from `pdf_export` barrel (mirror rag_chat) — **no** importing `pdf_export/presentation` from other features’ data layers
- [x] 8.3 Wire chat screen and/or translation / summary / OCR / library when appropriate: CTA → `context.go(RouteGuards.documentExport(id))` using **only** `core/routing` helpers
- [x] 8.4 Ensure rag_chat / translation / summarization / OCR / document_scan still have **zero** imports of `features/pdf_export/data` or internal widgets
- [x] 8.5 Review vs architecture §2.3 navigation contract; fix; commit

---

## 9. End-to-end feature flow (widget/integration-ish)

- [x] 9.1 Write failing flow test: navigate to export → enable all sections → confirm → poll → ready → signed URL CTA present
- [x] 9.2 Write failing flow test: summary-only → request body / success path omits other sections (fixture-level)
- [x] 9.3 Write failing flow test: section not ready → 409 banner; no successful download fabricated
- [x] 9.4 Write failing flow test: export failure → banner + retry re-POSTs; JobPoller timeout surfaces error
- [x] 9.5 Wire providers in app bootstrap overrides alongside prior features; bearer token still injected; review full OpenSpec pdf-export **client** scenarios; fix; commit

---

## 10. Shared fixtures hygiene (Test Agent)

- [x] 10.1 Add/extend `FakePdfExportRepository` + helpers under `test/helpers/`
- [x] 10.2 Add/update `test/fixtures/exports/*.json` for processing / ready+signed_url / failed / 409 / 422 / summary-only
- [x] 10.3 Keep fixture map in this plan’s table updated; commit

---

## 11. Reviewer gate checkpoints (STEP 3.7 pdf-export slice)

Run after §§0–10 land; blockers must be fixed before declaring this slice done.

- [ ] 11.1 **Prerequisite gate:** rag-chat STEP 3.7 review still PASS; no regression in auth/core/document_scan/ocr/summarization/translation/rag_chat suites
- [ ] 11.2 **Backend Master gate:** export HTTP path enters only via `run_master("export", …)`; no `ExportAgent` imports in router/service/task; section readiness rejected (409); ≥1 toggle (422); signed_url persisted on success; failure → failed
- [ ] 11.3 **Storage gate:** PDF stored via Export Agent StorageProvider; client receives signed URL (no public bucket requirement)
- [ ] 11.4 **Async UI gate:** export job via core `JobPoller` + `AsyncValueView` + Lexivo*; **no** feature-local poll loop; notifications feature not required for DoD
- [ ] 11.5 **Shared entity gate:** uses `core/entities` `Document` for document identity; barrel does not force other features to import `pdf_export` internals; ChatMessage not required in core
- [ ] 11.6 **Navigation gate:** chat/summary/translation/OCR/library → export via named routes only; no cross-feature widget/data imports
- [ ] 11.7 **Clean architecture gate:** §2.1 tree + barrel-only outside; no Dio inside feature; typed `ApiClient` only
- [ ] 11.8 **UI composition gate:** per-section toggles + Lexivo* CTAs; any DS gap flagged, not inlined
- [ ] 11.9 **Scope gate:** no notifications UI; no subscription gating; no Export Agent rewrite; backend limited to thin ExportService/router/task + OpenAPI
- [ ] 11.10 **TDD / stack gate:** Freezed + Riverpod; `flutter test` green for core + pdf_export (+ prior features); backend export API tests green
- [ ] 11.11 Final review vs `openspec/specs/pdf-export/spec.md` + architecture §2.1–§2.3; fix remaining gaps; commit “frontend pdf-export STEP 3.7 slice DoD met”

---

## Definition of Done (STEP 3.7 — pdf-export)

- [x] Thin backend export API: POST with section toggles → enqueue → `run_master("export")` only; assemble content server-side; persist status + signed URL; 409/422 gates
- [x] `features/pdf_export/` clean architecture + barrel; typed API client only; core `JobPoller`
- [x] Export UI with per-section toggles (summary, translation, chat annotations); processing / ready / failed via Lexivo* + `AsyncValueView`
- [x] Navigate from chat (and/or other features) via named routes only
- [x] Shared `Document` in `core/entities` for identity; no cross-feature imports
- [ ] Reviewer gates 11.1–11.11 passed
- [x] Out of scope preserved (notifications, subscription; no agent rewrite)

---

## Coverage matrix (planner verification)

| Requirement (OpenSpec / architecture) | Plan section |
|---|---|
| Multi-section PDF + per-section toggles | §0.1, §0.5–0.7, §0.11, §4, §6.4, §7, §9.1–9.2, §11.2 / §11.8 |
| Export subset (e.g. summary only) | §0.7, §6.4, §9.2 |
| Export Agent via Master + StorageProvider signed URL | §0.6, §0.8, §0.15, §11.2–11.3 |
| Async job + JobPoller; failure + retry | §0.6, §0.12, §6, §9.4, §11.4 |
| Typed client; feature `pdf_export/` | §1, §3–5, §11.7 |
| Core Document identity; no cross-feature imports | §2, §5.4, §8, §11.5–11.6 |
| Architecture job_poller shared for export | §6.5, §11.4 |
| rag-chat prerequisite completed | Prerequisites (PASS review) |
| Out of scope: notifications / subscription | Out of scope, §11.9 |

**Client OpenSpec scenarios covered:** **Yes** — all sections, subset, signed download, async failure/retry (notification delivery deferred).

**Backend API tasks included:** **Yes** — dedicated §0 (exports model + ExportService + Celery + routers) because export endpoints and `ExportService` are missing from current OpenAPI/routers.

**Task count:** **73** numbered TDD/gate tasks (0.1–0.15, 1.1–11.11). Prerequisites (3) marked completed above and excluded. DoD summary list (7) is a roll-up of those gates, not extra work items.

---

## Reviewer

*(Leave blank for Reviewer Agent — fill after implementation.)*

| Field | Value |
|---|---|
| **Capability** | pdf-export (Flutter + thin export API) |
| **Reviewer** | |
| **Date** | |
| **Sources** | `openspec/specs/pdf-export/spec.md`, `spec/architecture.md` §2.1–§2.3, this plan §11, `openspec/reviews/frontend-rag-chat-step37-review.md` |
| **Verdict** | |

### Gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Prerequisite — rag-chat STEP 3.7 still PASS | |
| 11.2 | Backend Master — `run_master("export")` only; toggles/readiness; signed_url; failure | |
| 11.3 | Storage — StorageProvider signed URL; no public bucket | |
| 11.4 | Async UI — JobPoller + AsyncValueView + Lexivo*; notifications deferred | |
| 11.5 | Shared entity — core Document identity | |
| 11.6 | Navigation — named routes only | |
| 11.7 | Clean architecture — §2.1 + typed client | |
| 11.8 | UI composition — section toggles + Lexivo* | |
| 11.9 | Scope — no notifications/subscription; thin backend only | |
| 11.10 | TDD / stack — flutter + backend tests green | |
| 11.11 | Final vs OpenSpec + architecture | |

### Notes

-
