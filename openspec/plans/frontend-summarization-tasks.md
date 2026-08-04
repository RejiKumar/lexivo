# Frontend Summarization — Task Plan
Capability: **summarization** (Flutter + thin backend API to invoke Master `summary` intent)
Architecture: `spec/architecture.md` §2.1–§2.3 (feature-first clean architecture; `core/`; shared `Document` in `core/entities`; no cross-feature imports; reuse `job_poller` + `AsyncValueView`)
OpenSpec: `openspec/specs/summarization/spec.md`
UI: compose **ONLY** from `core/design_system` (`Lexivo*` — especially `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoButton`, `LexivoSnackbar`). Loading/error/data via shared `AsyncValueView`. Any new visual atom → Design System Agent first — never inline one-offs.
Product: Lexivo
Execution order: **STEP 3.7 next feature** after OCR result-view PASS

**Prerequisite (completed)**
- [x] STEP 3.7 OCR result-view DoD **PASS** (`openspec/reviews/frontend-ocr-step37-review.md`) — summarization may proceed; shared `Document.extractedText` + OCR route/`JobPoller` pattern unblock this slice without importing `ocr` or `document_scan` internals
- [x] Design-system DoD **PASS** — `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoButton` available
- [x] Master Summary Agent exists on backend (`SummaryAgent` name=`summary`, wired in `run_master` / `NodeRegistry`; STEP 3.6 specialized-agents **PASS**) — **HTTP invoke + persist still missing** (see §0)

**Out of scope for this file (later plans)**
- Translation, rag-chat, pdf-export, notifications, subscription features
- Reimplementing Summary Agent / LLMProvider / Master graph / prompts (agent already done)
- Client-side LLM / vendor SDKs
- New design-system atoms unless a gap is flagged below for Design System Agent
- CI/CD, Cloud Run, Drift offline sync for summaries
- Changing OCR document `status` lifecycle (summarization must not flip OCR `ready` → `processing`)

**Product defaults (resolved)**

| Concern | Choice |
|---|---|
| Feature home | `lib/features/summarization/` — short + detailed summary presentation + trigger |
| Shared identity | Core Freezed `Document` (+ `shortSummary`, `detailedSummary`, `summaryStatus`); never import `ocr` / `document_scan` data/presentation |
| Backend gap | **Include thin API** — no summary routes/fields today; land persist + enqueue before Flutter can call typed client |
| Orchestration | Thin service / Celery task calls **only** `run_master("summary", …)` — never import `SummaryAgent` in router/service/task |
| Trigger | `POST /api/v1/documents/{id}/summary` (auth) → enqueue summary job; **409** when OCR incomplete (`status != ready` or empty `extracted_text`) with clear not-ready `detail` |
| Persist | `short_summary`, `detailed_summary` on Document model + OpenAPI `DocumentResponse`; `summary_status`: `idle` \| `processing` \| `ready` \| `failed` (separate from OCR `Document.status`) |
| Poll | `GET /api/v1/documents/{id}/summary/status` → `{ id, summary_status }`; client uses core `JobPoller` only — **no** feature-local poll loop |
| Fetch source | `GET /api/v1/documents/{id}` includes nullable `short_summary` / `detailed_summary` (+ `summary_status`) after §0; list may omit or null text fields |
| Async | **Yes** — LLM latency → Celery `run_summary` (mirror `run_ocr` pattern) + JobPoller |
| Ready UX | Show **short** then **detailed** summary sections when `summary_status == ready` and both texts non-empty; empty ready → `LexivoEmptyState` |
| Processing UX | Skeleton / processing copy while `JobPoller` runs; do not show stale summaries as success |
| Failed UX | `LexivoErrorBanner` (+ optional `LexivoEmptyState`); `onRetry` = re-POST enqueue + re-poll |
| Not-ready UX | Do **not** enqueue; surface clear not-ready error via `LexivoErrorBanner` (map HTTP 409 → `ValidationFailure` or dedicated message) |
| Navigation | Named GoRouter only: e.g. `/documents/:documentId/summary`. OCR result / library navigate via route constants — **no** direct widget imports across features |
| State | Riverpod (current pin ^2.6.1; prefer 3 when pins allow — same note as prior features) |
| Models | Freezed (+ json_serializable only for network DTOs) |
| HTTP | Typed `ApiClient` only — no `Dio(` / `package:dio` inside `features/summarization/` |

**Conventions**
- Loop per chunk: failing test → implement → (widget test where UI) → review vs OpenSpec summarization + architecture §2.1–§2.3 + Lexivo* composition → fix → commit.
- Prefer small sequential commits; never one giant “frontend-summarization” commit.
- Feature public surface = barrel `features/summarization/summarization.dart` only.
- Screens: layout + `Lexivo*` + `AsyncValueView` only. Grep guard: no ad-hoc Material buttons as interactive atoms.
- All HTTP via `core/network` `ApiClient`.
- Prefixes: package `lexivo`; UI `Lexivo*`; never `Nexora*`.
- Do **not** import `features/ocr/**`, `features/document_scan/**`, or any other feature internals. Cross-feature wiring = named routes + injected screen builders only.
- Thin OCR (or library) change allowed: pass CTA / `onTap` → `context.go` summary route by id — still no `features/summarization/...` imports inside OCR data/widgets beyond route constants in `core/routing`.

**Design-system gap flag**
- Expected composition: summary screen = `AsyncValueView` + skeletons / error banner / empty state + two text sections (short + detailed) using typography tokens; primary CTA via `LexivoButton` if explicit generate/retry is needed.
- If a true visual gap appears (e.g. dedicated “short vs detailed” chrome that cannot be layout + Lexivo*), **stop and flag Design System Agent** — do not invent feature-local atoms.

**Shared test fixtures (Test Agent ownership)**

| Location | Owns |
|---|---|
| `test/fixtures/documents/` | Extend JSON: get-with-summaries, summary status `idle`/`processing`/`ready`/`failed`, not-ready / 409 envelope, empty summaries ready |
| `test/helpers/` | `FakeSummarizationRepository`, `MockApiClient` summary POST/status/get stubs, controllable `JobPoller` clock/fake reuse |
| `test/core/entities/` | `Document` + summary fields mapping tests |
| `test/core/network/` | `requestSummary` / `getSummaryStatus` / DTO field tests; 409 → ValidationFailure |
| `test/features/summarization/` | Domain/data/presentation/flow tests (use helpers; no duplicate fakes) |
| `backend/tests/` | Thin summary service/router/task: not-ready, `run_master` only, persist short/detailed |

---

## 0. Backend thin API — invoke Master `summary` + persist (MISSING today)

OpenAPI / routers currently expose only documents create/list/get/status. Model has `extracted_text` but **no** `short_summary` / `detailed_summary` / `summary_status`. Summary Agent is callable only via Master in tests — **blocks Flutter**.

### 0.A Model + schemas + OpenAPI

- [x] 0.1 **Decision gate:** document in this plan / `docs/api_client.md`: summaries from `GET /documents/{id}` fields `short_summary` / `detailed_summary`; poll `GET /documents/{id}/summary/status`; trigger `POST /documents/{id}/summary`; OCR readiness gate on document `status == ready` + non-empty `extracted_text`
- [x] 0.2 Add ORM columns: `short_summary`, `detailed_summary` (nullable Text), `summary_status` enum/string (`idle`\|`processing`\|`ready`\|`failed`, default `idle`) — migration or create_all-compatible for tests
- [x] 0.3 Extend Pydantic `DocumentResponse` (+ OpenAPI snapshot `openapi/lexivo.openapi.json`) with the three fields; add `SummaryStatusResponse` (`id`, `summary_status`)
- [x] 0.4 Write failing backend tests for schema/serialization of new fields

### 0.B Thin service + Celery task (Master only)

- [x] 0.5 Write failing tests: enqueue/service rejects when document missing, wrong owner, `status != ready`, or empty `extracted_text` → not-ready error (HTTP 409 at router)
- [x] 0.6 Write failing tests: success path sets `summary_status=processing`, creates/reuses Job `job_type=summary`, Celery `run_summary` calls `run_master("summary", input={text: …, document_id})` with LLM injected; on success persists `short_summary`/`detailed_summary` and `summary_status=ready`; on agent failure → `failed`
- [x] 0.7 Assert task/service source: **has** `run_master`; **no** `SummaryAgent` / `summary_agent` import (extend coupling test if needed)
- [x] 0.8 Implement thin `SummaryService` (or methods on DocumentService) + `enqueue_summary` / `run_summary` in tasks — status updates stay at task/service layer, not inside the agent
- [x] 0.9 Review vs OpenSpec “Summary Agent via orchestrator” + “Document not ready”; fix; commit backend slice

### 0.C Router endpoints

- [x] 0.10 Write failing API tests: `POST /api/v1/documents/{id}/summary` auth + ownership; 409 not-ready; 202/200 when enqueued (`summary_status=processing`)
- [x] 0.11 Write failing API tests: `GET .../summary/status` returns processing/ready/failed/idle; `GET /documents/{id}` returns persisted summaries when ready
- [x] 0.12 Implement thin router handlers (documents router or `summaries` sub-routes) — call service only; no agent imports
- [x] 0.13 Refresh OpenAPI snapshot; commit

---

## 1. Typed client + fixtures (Flutter)

- [x] 1.1 Write failing `ApiClient` / DTO unit tests: parse nullable `short_summary` / `detailed_summary` / `summary_status` on get-document; `getSummaryStatus`; `requestSummary` (POST)
- [x] 1.2 Write failing tests: HTTP 409 not-ready maps to `ValidationFailure` (extend `ErrorMapper` if 409 currently falls through as generic NetworkFailure)
- [x] 1.3 Extend Freezed `DocumentDto` (+ generated) and OpenAPI-aligned fields; add summary status DTO
- [x] 1.4 Implement `ApiClient.requestSummary` / `getSummaryStatus`; update `docs/api_client.md` (`TODO(openapi-codegen)` note)
- [x] 1.5 Add/update fixtures under `test/fixtures/documents/`
- [x] 1.6 Review vs OpenSpec “typed client exclusively”; fix; commit

---

## 2. Core shared entity — extend `Document`

Architecture §2.3: summarization depends on core entity, not `ocr` / `document_scan`.

- [x] 2.1 Write failing unit tests: Freezed `Document` optional `shortSummary`, `detailedSummary`, `summaryStatus` (enum or string-aligned); equality/copyWith; mapper from DTO; OCR fields unchanged
- [x] 2.2 Implement fields on `lib/core/entities/document.dart` (+ `SummaryStatus` enum if not reused from OCR `DocumentStatus`)
- [x] 2.3 Update `document_mapper` + any constructors/tests broken by new fields so suite stays green
- [x] 2.4 Review vs architecture §2.3; fix; commit

---

## 3. Feature scaffold (§2.1)

- [x] 3.1 Create `lib/features/summarization/` tree: `data/{datasources,repositories,models}/`, `domain/{entities,repositories,usecases}/`, `presentation/{screens,widgets,providers}/`, barrel `summarization.dart`
- [x] 3.2 Write failing barrel smoke: exports public summary screen builder / providers needed by router — **not** data-layer types
- [x] 3.3 Review vs architecture §2.1 folder contract; fix; commit scaffold

---

## 4. Domain — repository + usecases

- [x] 4.1 Define abstract `SummarizationRepository`: `getDocument(id)`, `getSummaryStatus(id)`, `requestSummary(id)` → `Result` + core `Document` / `SummaryStatus` — **no** OCR feature types
- [x] 4.2 Optional domain view model / Freezed `SummaryView`: document id, summary status, short + detailed text, title — still backed by core `Document`
- [x] 4.3 Write failing usecase tests (fake repo): `LoadSummary`, `RequestSummary`, `GetSummaryStatus` (names flexible); success/failure/`not ready` `Result` shapes
- [x] 4.4 Write failing tests: poll terminal when `summary_status` is `ready` or `failed`; `processing` is non-terminal; `idle` may trigger request then poll
- [x] 4.5 Implement usecases — each single `call()`, returns `Result`
- [x] 4.6 Review vs OpenSpec short/detailed + not-ready requirements (domain does not embed a private poller); fix; commit

---

## 5. Data layer — remote + repository impl

- [x] 5.1 Write failing tests for `SummarizationRemoteDatasource`: get / summary-status / POST via `ApiClient` only; DTO→entity mapping including summaries; failures via `ErrorMapper`/`Result`
- [x] 5.2 Implement datasource + `SummarizationRepositoryImpl`
- [x] 5.3 Riverpod providers for repository + usecases (override-friendly)
- [x] 5.4 Assert no `package:dio` and no `features/ocr` / `features/document_scan` imports under `features/summarization/`; fix; commit

---

## 6. Presentation — providers (Riverpod + JobPoller)

- [x] 6.1 Write failing provider tests: open summary for doc with `summary_status=ready` → `AsyncValue` data with short + detailed text
- [x] 6.2 Write failing tests: `idle` → POST requestSummary then poll; `processing` → core `JobPoller` on `getSummaryStatus`; terminal `ready` → fetch document texts; `failed` → error view model
- [x] 6.3 Write failing tests: OCR not ready / 409 → clear not-ready error **without** starting poller
- [x] 6.4 Write failing tests: dispose/cancel stops polling; timeout → user-visible error path; retry re-POSTs or reloads as designed
- [x] 6.5 Implement notifier(s) (`summaryResultProvider` family by document id, etc.) wiring **only** `JobPoller` from `core/utils`
- [x] 6.6 Review vs OpenSpec scenarios “Request summaries” + “Document not ready”; fix; commit

---

## 7. Presentation — summary screen (Lexivo* only)

- [x] 7.1 Write failing widget tests for **SummaryScreen** (name flexible): loading → `AsyncValueView` / `LexivoSkeleton`; ready → short + detailed sections visible; failed → `LexivoErrorBanner` with retry; empty ready → `LexivoEmptyState`; not-ready → clear error copy
- [x] 7.2 Write failing tests: processing state shows skeleton/processing affordance (not fabricated success text)
- [x] 7.3 Implement screen composing Lexivo* + layout only; **no** translation / RAG / export CTAs
- [x] 7.4 Review vs OpenSpec feature isolation + Lexivo composition; fix; commit

---

## 8. Routing + navigation from OCR / library

- [x] 8.1 Write failing router tests: authenticated route e.g. `/documents/:documentId/summary`; unauthenticated → sign-in; named routes only
- [x] 8.2 Extend `RouteGuards` + `app_router` with summary route; inject builders from `summarization` barrel (mirror ocr/document_scan) — **no** importing `summarization/presentation` from OCR data
- [x] 8.3 Wire OCR result screen (and/or library when appropriate): CTA / action → `context.go(RouteGuards.documentSummary(id))` using **only** `core/routing` helpers
- [x] 8.4 Ensure OCR / document_scan still have **zero** imports of `features/summarization/data` or internal widgets
- [x] 8.5 Review vs architecture §2.3 navigation contract; fix; commit

---

## 9. End-to-end feature flow (widget/integration-ish)

- [x] 9.1 Write failing flow test: navigate to summary (idle) → POST → poll → ready → shows short + detailed from fixtures
- [x] 9.2 Write failing flow test: already-ready summaries → screen shows texts without long poll (or single status check then get)
- [x] 9.3 Write failing flow test: not-ready document → clear error; no successful summary content
- [x] 9.4 Write failing flow test: poll → failed → error banner + retry re-enters request/poll path
- [x] 9.5 Wire providers in app bootstrap overrides alongside ocr/document_scan; bearer token still injected; review full OpenSpec summarization **client** scenarios; fix; commit

---

## 10. Shared fixtures hygiene (Test Agent)

- [x] 10.1 Add/extend `FakeSummarizationRepository` + poller test helpers under `test/helpers/`
- [x] 10.2 Add/update `test/fixtures/documents/*.json` for get+summaries and summary status transitions + 409 not-ready
- [x] 10.3 Keep fixture map in this plan’s table updated; commit

---

## 11. Reviewer gate checkpoints (STEP 3.7 summarization slice)

Run after §§0–10 land; blockers must be fixed before declaring this slice done.

- [ ] 11.1 **Prerequisite gate:** OCR STEP 3.7 review still PASS; no regression in auth/core/document_scan/ocr suites
- [ ] 11.2 **Backend Master gate:** summary HTTP path enters only via `run_master("summary", …)`; no specialist imports in router/service/task; not-ready rejected; short+detailed persisted
- [ ] 11.3 **Polling gate:** feature uses shared `JobPoller` + summary status endpoint; **no** feature-local poll implementation
- [ ] 11.4 **Async UI gate:** loading/error/data via `AsyncValueView` + `LexivoSkeleton` / `LexivoErrorBanner` / data or `LexivoEmptyState`
- [ ] 11.5 **Shared entity gate:** uses `core/entities` `Document` (+ summary fields); barrel does not force other features to import `summarization` internals
- [ ] 11.6 **Navigation gate:** OCR/library → summary via named routes only; no cross-feature widget/data imports
- [ ] 11.7 **Clean architecture gate:** §2.1 tree + barrel-only outside; no Dio inside feature; typed `ApiClient` only
- [ ] 11.8 **UI composition gate:** Lexivo* only; any DS gap flagged, not inlined
- [ ] 11.9 **Scope gate:** no translation/rag/export UIs; no Summary Agent reimplementation; no CI/CD; backend limited to thin router/service/task + persist/OpenAPI
- [ ] 11.10 **TDD / stack gate:** Freezed + Riverpod; `flutter test` green for core + summarization (+ prior features); backend summary API tests green
- [ ] 11.11 Final review vs `openspec/specs/summarization/spec.md` + architecture §2.1–§2.3; fix remaining gaps; commit “frontend summarization STEP 3.7 slice DoD met”

---

## Definition of Done (STEP 3.7 — summarization)

- [x] Thin backend API: POST summary + summary status + persisted short/detailed via `run_master("summary", …)` only; not-ready when OCR incomplete
- [x] `features/summarization/` clean architecture + barrel; typed API client only
- [x] Short + detailed summary UI; processing / ready / failed / not-ready via Lexivo* + `AsyncValueView` + core `JobPoller`
- [x] Navigate from OCR result (and/or library) via named routes only
- [x] Shared `Document` in `core/entities` with summary fields; no cross-feature imports
- [ ] Reviewer gates 11.1–11.11 passed
- [x] Out of scope preserved (translation and later features; no Summary Agent reimplementation)

---

## Coverage matrix (planner verification)

| Requirement (OpenSpec / architecture) | Plan section |
|---|---|
| Short + detailed summaries persisted / syncable | §0, §1–2, §7, §9 |
| Not-ready error if OCR incomplete | §0.5, §0.10, §6.3, §7.1, §9.3, §11.2 |
| Summary Agent only via Master / `run_master` | §0.6–0.8, §11.2 |
| Feature isolation + typed ApiClient | §1, §5, §11.7 |
| Lexivo* composition only | §7, §11.8 |
| Clean architecture §2.1 + barrel | §3, §11.7 |
| Shared Document in core (§2.3) | §2, §11.5 |
| JobPoller for async job shape (§2.2) | §6, §9, §11.3 |
| No cross-feature imports; named routes | §8, §11.6 |
| OCR prerequisite completed | Prerequisites (PASS review) |
| Out of scope: translation / later; no agent rewrite | Out of scope, §11.9 |

**Client OpenSpec “Feature module isolation” covered:** **Yes** — §1, §5, §7, §11.7–11.8.

**Backend API tasks included:** **Yes** — dedicated §0 (model/persist + thin service/Celery + routers) because endpoints and summary fields are missing from current OpenAPI/routers.

**Task count:** **70** numbered TDD/gate tasks (0.1–11.11). Prerequisites (3) marked completed above and excluded. DoD summary list (7) is a roll-up of those gates, not extra work items.

---

## Reviewer

*(Leave blank for Reviewer Agent — fill after implementation.)*

| Field | Value |
|---|---|
| **Capability** | summarization (Flutter + thin API) |
| **Reviewer** | |
| **Date** | |
| **Sources** | `openspec/specs/summarization/spec.md`, `spec/architecture.md` §2.1–§2.3, this plan §11, `openspec/reviews/frontend-ocr-step37-review.md` |
| **Verdict** | |

### Gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Prerequisite — OCR STEP 3.7 still PASS | |
| 11.2 | Backend Master — `run_master("summary")` only; not-ready; persist | |
| 11.3 | Polling — shared JobPoller + summary status | |
| 11.4 | Async UI — AsyncValueView + Lexivo* | |
| 11.5 | Shared entity — core Document + summary fields | |
| 11.6 | Navigation — named routes only | |
| 11.7 | Clean architecture — §2.1 + typed client | |
| 11.8 | UI composition — Lexivo* only | |
| 11.9 | Scope — no translation/later; thin backend only | |
| 11.10 | TDD / stack — flutter + backend tests green | |
| 11.11 | Final vs OpenSpec + architecture | |

### Notes

-
