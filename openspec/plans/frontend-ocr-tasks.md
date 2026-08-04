# Frontend OCR Result View — Task Plan
Capability: **ocr** (Flutter result presentation)
Architecture: `spec/architecture.md` §2.1–§2.3 (feature-first clean architecture; `core/`; shared `Document` in `core/entities`; no cross-feature imports; reuse `job_poller` + `AsyncValueView`)
OpenSpec: `openspec/specs/ocr/spec.md` (client/async job polling + result UX; agent/backend OCR already landed)
UI: compose **ONLY** from `core/design_system` (`Lexivo*` — especially `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoButton`, `LexivoSnackbar`). Loading/error/data via shared `AsyncValueView`. Any new visual atom → Design System Agent first — never inline one-offs.
Product: Lexivo
Execution order: **STEP 3.7 next feature** after document-scan PASS

**Prerequisite (completed)**
- [x] STEP 3.7 document-scan DoD **PASS** (`openspec/reviews/frontend-document-scan-step37-review.md`) — `ocr` result view may proceed; shared `Document` in `core/entities` unblocks identity without importing `document_scan` internals
- [x] Design-system DoD **PASS** — `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoDocumentCard` (with `onTap`) available
- [x] Backend document status + Celery OCR via Master already exists (`GET /api/v1/documents/{id}/status`, `run_ocr` → Master → OCR Agent); `extracted_text` persisted on document model (RAG STEP 3.5) — **client poll uses status endpoint**; text fetch via get-document once OpenAPI exposes it (see §0.B)

**Out of scope for this file (later plans)**
- Summarization, translation, rag-chat, pdf-export, notifications, subscription features
- Reimplementing OCR Agent / OCRProvider / Master graph / Celery `run_ocr` (backend already done)
- Client-side OCR / ML / vendor SDKs
- New design-system atoms unless a gap is flagged below for Design System Agent
- CI/CD, Cloud Run, Drift offline sync for OCR
- Inventing a retry-enqueue API unless Backend lands one (see Product defaults)

**Product defaults (resolved)**

| Concern | Choice |
|---|---|
| Feature home | `lib/features/ocr/` — OCR **result presentation** only (not scan/upload) |
| Shared identity | Core Freezed `Document` (+ optional `extractedText`); never import `document_scan` data/presentation |
| Polling | Core `JobPoller` + `ApiClient.getDocumentStatus` only — **no** feature-local poll loop |
| Async UI | `AsyncValueView` for loading (`LexivoSkeleton`) / error (`LexivoErrorBanner`) / data |
| Ready UX | Show extracted text when status is `ready` and text is non-empty; empty ready → `LexivoEmptyState` |
| Processing UX | Skeleton / processing copy while `JobPoller` runs; do not show stale text |
| Failed UX | `LexivoErrorBanner` (+ optional `LexivoEmptyState`); `onRetry` = re-fetch status + document (re-poll). No client-invented re-enqueue unless Backend adds an endpoint |
| Text source | `GET /api/v1/documents/{id}` includes nullable `extracted_text` after §0.B OpenAPI/schema alignment; list responses may omit or null the field |
| Status source | `GET /api/v1/documents/{id}/status` remains the poll tick (`processing` \| `ready` \| `failed`) |
| Navigation | Named GoRouter only: e.g. `/documents/:documentId/ocr`. Library/detail navigate when user opens a document that is processing, ready, or failed — **no** direct widget imports across features |
| State | Riverpod (current pin ^2.6.1; prefer 3 when pins allow — same note as auth/scan) |
| Models | Freezed (+ json_serializable only for network DTOs) |
| HTTP | Typed `ApiClient` only — no `Dio(` / `package:dio` inside `features/ocr/` |

**Conventions**
- Loop per chunk: failing test → implement → (widget test where UI) → review vs OpenSpec ocr + architecture §2.1–§2.3 + Lexivo* composition → fix → commit.
- Prefer small sequential commits; never one giant “frontend-ocr” commit.
- Feature public surface = barrel `features/ocr/ocr.dart` only.
- Screens: layout + `Lexivo*` + `AsyncValueView` only. Grep guard: no ad-hoc Material buttons as interactive atoms.
- All HTTP via `core/network` `ApiClient`.
- Prefixes: package `lexivo`; UI `Lexivo*`; never `Nexora*`.
- Do **not** import `features/document_scan/**` or any other feature internals. Cross-feature wiring = named routes + injected screen builders only.
- Thin `document_scan` library change allowed: pass `onTap` → `context.go` OCR route by id — still no `features/ocr/...` imports inside scan data/widgets beyond route constants in `core/routing`.

**Design-system gap flag**
- Expected composition: result screen = `AsyncValueView` + skeletons / error banner / empty state + scrollable text body (typography tokens). Card navigation uses existing `LexivoDocumentCard.onTap`.
- If a true visual gap appears (e.g. dedicated selectable OCR text chrome that cannot be layout + Lexivo*), **stop and flag Design System Agent** — do not invent feature-local atoms.

**Shared test fixtures (Test Agent ownership)**

| Location | Owns |
|---|---|
| `test/fixtures/documents/` | Extend JSON: get-with-`extracted_text`, status `processing`/`ready`/`failed`, empty text ready, error envelopes |
| `test/helpers/` | `FakeOcrRepository` (or extend document fakes without coupling to scan feature types), `MockApiClient` status/get stubs, `ProviderContainer` harness reuse, controllable `JobPoller` clock/fake |
| `test/core/entities/` | `Document` + `extractedText` mapping tests |
| `test/core/network/` | `getDocument` / DTO field tests for `extracted_text` |
| `test/features/ocr/` | Domain/data/presentation/flow tests (use helpers; no duplicate fakes) |

---

## 0. OpenAPI / ApiClient gap — `extracted_text`

Backend persists `extracted_text` but `DocumentResponse` / interim Flutter `DocumentDto` currently omit it — **blocks ready-state text**.

### 0.A Decision + blocker

- [x] 0.1 **Decision gate:** document in this plan / `docs/api_client.md`: OCR result text comes from `GET /documents/{id}` field `extracted_text` (snake_case API → `extractedText` domain); status polling stays on `GET /documents/{id}/status`
- [x] 0.2 Backend OpenAPI/`DocumentResponse` omitted `extracted_text` — **Frontend fixed thin exposure**: Pydantic `DocumentResponse.extracted_text` + OpenAPI snapshot + Flutter `DocumentDto` (Backend Agent gap closed in-slice; no parallel client-only endpoint)
- [x] 0.3 Optional soft: expose `error_message` on status or document for failed OCR — if absent, failed UI uses generic copy; do not block slice on job-table coupling

### 0.B Typed client + fixtures

- [x] 0.4 Write failing `ApiClient` / DTO unit tests: `getDocument` parses nullable `extracted_text`; ready fixture returns non-null text; processing/failed may be null
- [x] 0.5 Extend Freezed `DocumentDto` (+ generated) and OpenAPI snapshot `DocumentResponse.properties.extracted_text` to match backend
- [x] 0.6 Update `documentFromDto` mapper + fixtures under `test/fixtures/documents/`
- [x] 0.7 Assert feature code will call only `getDocument` / `getDocumentStatus` for this slice — never storage/OCR SDKs; update `docs/api_client.md` `TODO(openapi-codegen)` note
- [x] 0.8 Review vs OpenSpec “Async job polling reuse” + architecture typed-client rule; fix; commit

---

## 1. Core shared entity — extend `Document`

Architecture §2.3: OCR depends on core entity, not `document_scan`.

- [x] 1.1 Write failing unit tests: Freezed `Document` optional `extractedText`; equality/copyWith; mapper from DTO; status helpers unchanged
- [x] 1.2 Implement `extractedText` on `lib/core/entities/document.dart` (nullable `String?`)
- [x] 1.3 Update `document_mapper` + any existing document_scan tests that construct `Document` (positional/named) so suite stays green
- [x] 1.4 Review vs architecture §2.3; fix; commit

---

## 2. Feature scaffold (§2.1)

- [x] 2.1 Create `lib/features/ocr/` tree: `data/{datasources,repositories,models}/`, `domain/{entities,repositories,usecases}/`, `presentation/{screens,widgets,providers}/`, barrel `ocr.dart`
- [x] 2.2 Write failing barrel smoke: exports public OCR result screen builder / providers needed by router — **not** data-layer types
- [x] 2.3 Review vs architecture §2.1 folder contract; fix; commit scaffold

---

## 3. Domain — repository + usecases

- [x] 3.1 Define abstract `OcrRepository` (name flexible): `getDocument(id)`, `getStatus(id)` → `Result` + core `Document` / `DocumentStatus` — **no** scan feature types
- [x] 3.2 Optional domain view model / Freezed `OcrResultView` if useful: document id, status, extracted text, title — still backed by core `Document`
- [x] 3.3 Write failing usecase tests (fake repo): `GetOcrDocument`, `GetOcrStatus` (or single `LoadOcrResult`); success/failure `Result` shapes
- [x] 3.4 Write failing tests: poll terminal when status is `ready` or `failed`; processing is non-terminal
- [x] 3.5 Implement usecases — each single `call()`, returns `Result`
- [x] 3.6 Review vs OpenSpec “Async job polling reuse” (domain does not embed a private poller); fix; commit

---

## 4. Data layer — remote + repository impl

- [x] 4.1 Write failing tests for `OcrRemoteDatasource`: `get`/`status` via `ApiClient` only; DTO→entity mapping including `extractedText`; failures via `ErrorMapper`/`Result`
- [x] 4.2 Implement datasource + `OcrRepositoryImpl`
- [x] 4.3 Riverpod providers for repository + usecases (override-friendly)
- [x] 4.4 Assert no `package:dio` and no `features/document_scan` imports under `features/ocr/`; fix; commit

---

## 5. Presentation — providers (Riverpod + JobPoller)

- [x] 5.1 Write failing provider tests: open result for `ready` doc → `AsyncValue` data with extracted text
- [x] 5.2 Write failing tests: `processing` → starts core `JobPoller` on `getDocumentStatus`; on terminal `ready` → fetch document text into data; on `failed` → error or failed view model without inventing feature-local polling
- [x] 5.3 Write failing tests: dispose/cancel stops polling (`JobPollerCancelled` / flag); timeout maps to user-visible error via `LexivoErrorBanner` path
- [x] 5.4 Implement notifier(s) (`ocrResultProvider` family by document id, etc.) wiring **only** `JobPoller` from `core/utils`
- [x] 5.5 Review vs OpenSpec scenario “Client waits for OCR”; fix; commit

---

## 6. Presentation — OCR result screen (Lexivo* only)

- [x] 6.1 Write failing widget tests for **OcrResultScreen** (name flexible): loading → `AsyncValueView` / `LexivoSkeleton`; ready → scrollable extracted text; failed → `LexivoErrorBanner` with retry; empty ready text → `LexivoEmptyState`
- [x] 6.2 Write failing tests: processing state shows skeleton/processing affordance (not fabricated success text)
- [x] 6.3 Implement screen composing Lexivo* + layout only; no summarization CTAs
- [x] 6.4 Review vs OpenSpec ocr client scenarios + Lexivo composition; fix; commit

---

## 7. Routing + library/detail navigation

- [x] 7.1 Write failing router tests: authenticated route e.g. `/documents/:documentId/ocr`; unauthenticated → sign-in; named routes only
- [x] 7.2 Extend `RouteGuards` + `app_router` with OCR result route; inject builders from `ocr` barrel (mirror document_scan pattern) — **no** importing `ocr/presentation` from scan data
- [x] 7.3 Wire document library (and detail if present): `LexivoDocumentCard.onTap` → navigate to OCR route for processing / ready / failed documents
- [x] 7.4 Ensure scan feature still has **zero** imports of `features/ocr/data` or internal widgets; only `core/routing` path helpers
- [x] 7.5 Review vs architecture §2.3 navigation contract; fix; commit

---

## 8. End-to-end feature flow (widget/integration-ish)

- [x] 8.1 Write failing flow test: library card tap (processing) → OCR screen polls → ready → shows extracted text from fixtures
- [x] 8.2 Write failing flow test: already-ready document → OCR screen shows text without unnecessary long poll (or single status check then get)
- [x] 8.3 Write failing flow test: poll → failed → error banner + retry re-enters load/poll path
- [x] 8.4 Wire providers in app bootstrap overrides alongside document_scan; bearer token still injected; review full OpenSpec ocr **client** scenarios; fix; commit

---

## 9. Shared fixtures hygiene (Test Agent)

- [x] 9.1 Add/extend `FakeOcrRepository` + poller test helpers under `test/helpers/`
- [x] 9.2 Add/update `test/fixtures/documents/*.json` for get+extracted_text and status transitions
- [x] 9.3 Keep fixture map in this plan’s table updated; commit

---

## 10. Reviewer gate checkpoints (STEP 3.7 ocr result slice)

Run after §§0–9 land; blockers must be fixed before declaring this slice done.

- [ ] 10.1 **Prerequisite gate:** document-scan STEP 3.7 review still PASS; no regression in auth/core/document_scan suites
- [ ] 10.2 **Polling gate:** OCR result uses shared `JobPoller` + status endpoint; **no** feature-local poll implementation
- [ ] 10.3 **Async UI gate:** loading/error/data via `AsyncValueView` + `LexivoSkeleton` / `LexivoErrorBanner` / data or `LexivoEmptyState`
- [ ] 10.4 **Shared entity gate:** uses `core/entities` `Document` (+ `extractedText`); barrel does not force other features to import `ocr` internals
- [ ] 10.5 **Navigation gate:** library/detail → OCR via named routes only; no cross-feature widget/data imports
- [ ] 10.6 **Clean architecture gate:** §2.1 tree + barrel-only outside; no Dio inside feature; typed `ApiClient` only
- [ ] 10.7 **UI composition gate:** Lexivo* only; any DS gap flagged, not inlined
- [ ] 10.8 **Scope gate:** no summarization/rag/export UIs; no OCR Agent reimplementation; no CI/CD; backend changes limited to exposing `extracted_text` (and optional error field) if still missing
- [ ] 10.9 **TDD / stack gate:** Freezed + Riverpod; `flutter test` green for core + ocr (+ prior features)
- [ ] 10.10 Final review vs `openspec/specs/ocr/spec.md` (client scenarios) + architecture §2.1–§2.3; fix remaining gaps; commit “frontend ocr STEP 3.7 result-view slice DoD met”

---

## Definition of Done (STEP 3.7 — ocr result view)

- [ ] `features/ocr/` clean architecture + barrel; typed API client only
- [ ] OCR result view: processing / ready (extracted text) / failed via LexivoEmptyState, ErrorBanner, Skeleton, `AsyncValueView`, core `JobPoller`
- [ ] Navigate from document library (and detail if any) when processing or ready (and failed)
- [ ] Shared `Document` in `core/entities` with text field; no cross-feature imports
- [ ] Reviewer gates 10.1–10.10 passed
- [ ] Out of scope preserved (summarization/later features; no OCR Agent reimplementation)

---

## Coverage matrix (planner verification)

| Requirement (OpenSpec / architecture) | Plan section |
|---|---|
| Async job polling via shared job poller | §5, §8, §10.2 |
| Loading/error/data via shared async UI | §6, §10.3 |
| OCR failure surfaced + retry where configured | §5.2–5.3, §6.1, §8.3 (re-poll retry) |
| Shared Document in core entities | §1, §10.4 |
| Clean architecture + barrel; no cross-feature imports | §2, §4.4, §7, §10.5–10.6 |
| Lexivo* composition only | §6, §10.7 |
| Typed ApiClient; poll status endpoint | §0, §4, Product defaults |
| Navigate from library/detail | §7, §8.1 |
| document-scan prerequisite completed | Prerequisites (PASS review) |
| Out of scope: summarization; no OCR Agent rewrite | Out of scope, §10.8 |

**Client OpenSpec “Async job polling reuse” covered:** **Yes** — dedicated §5 + gates §10.2 + E2E §8.

**Task count:** **56** numbered TDD/gate tasks (0.1–10.10). Prerequisites (3) marked completed above and excluded. DoD summary list (6) is a roll-up of those gates, not extra work items.
