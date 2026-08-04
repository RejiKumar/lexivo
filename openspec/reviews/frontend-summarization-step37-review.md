# Frontend Summarization STEP 3.7 Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | summarization (Flutter + thin backend API) + architecture §2.1–§2.3 |
| **Reviewer** | Reviewer Agent (independent) |
| **Date** | 2026-08-04 |
| **Sources** | `openspec/specs/summarization/spec.md`, `spec/architecture.md` §2.1–§2.3, `openspec/plans/frontend-summarization-tasks.md` §11, prior `openspec/reviews/frontend-ocr-step37-review.md` |
| **Claimed** | POST/GET summary APIs, `features/summarization`, JobPoller, commits `665633e` / `27d114b` / `b0edd16`; §11 open |
| **Verdict** | **PASS** |

---

## Verdict

**PASS** — STEP 3.7 summarization slice Definition of Done is met. Plan gates 11.1–11.11 all pass. Independent runs: backend summary-related **35 passed**; `flutter test` **276 passed**. No findings that block DoD or translation follow-on.

**Is STEP 3.7 summarization DoD met?** **Yes.**

**May translation feature proceed?** **Yes.** Use named routes + core `Document` summary fields; do not import `features/summarization` (or `ocr` / `document_scan`) internals.

---

## Gate-by-gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Prerequisite — OCR STEP 3.7 still PASS; no auth/core/document_scan/ocr regression | **PASS** |
| 11.2 | Backend Master — `run_master("summary")` only; not-ready; persist short+detailed | **PASS** |
| 11.3 | Polling — shared `JobPoller` + summary status endpoint; no feature-local poll | **PASS** |
| 11.4 | Async UI — `AsyncValueView` + `LexivoSkeleton` / `LexivoErrorBanner` / data or `LexivoEmptyState` | **PASS** |
| 11.5 | Shared entity — `core/entities` `Document` (+ summary fields); barrel does not force summarization internals | **PASS** |
| 11.6 | Navigation — OCR → summary via named routes only; no cross-feature widget/data imports | **PASS** |
| 11.7 | Clean architecture — §2.1 tree + barrel-only outside; no Dio in feature; typed `ApiClient` | **PASS** |
| 11.8 | UI composition — Lexivo* only; any DS gap flagged, not inlined | **PASS** (soft note) |
| 11.9 | Scope — no translation/rag/export UIs; no Summary Agent rewrite; thin backend only | **PASS** |
| 11.10 | TDD / stack — Freezed + Riverpod; flutter + backend summary tests green | **PASS** |
| 11.11 | Final vs OpenSpec summarization + architecture §2.1–§2.3 | **PASS** |
| — | Translation may proceed | **Yes** |

---

## Evidence

### 11.1 Prerequisite gate

- OCR STEP 3.7 review remains **PASS** (`openspec/reviews/frontend-ocr-step37-review.md`); summarization was cleared to proceed.
- Independent full Flutter suite **276 passed** — includes auth, core, document_scan, ocr, and summarization; no regression observed.

### 11.2 Backend Master gate

- Commits: `665633e` (thin summary API + persist), covered by `backend/tests/test_summary_api.py` + coupling guards.
- Router `POST /api/v1/documents/{id}/summary` → `SummaryService.request_summary` only; `ConflictError` → **HTTP 409** when OCR `status != ready` or empty `extracted_text`.
- Celery `run_summary` calls `await run_master("summary", {text, document_id}, …)` then persists `short_summary` / `detailed_summary` and `summary_status=ready` (failure → `failed`).
- Source guards: `test_summary_task_enters_via_master_only` + `test_summary_api` assert task has `run_master` and **no** `SummaryAgent` / `summary_agent` imports. Router/service have no specialist or direct LLM imports; LLM is injected only in the task via `get_task_llm_provider` into Master.
- OCR lifecycle untouched: service updates `summary_status` (+ clears prior summary texts on enqueue), not document OCR `status`.

### 11.3 Polling gate

- `SummaryResultNotifier` uses `summaryJobPollerProvider` → core `JobPoller` while status is `processing`.
- Ticks call `GetSummaryStatus` → `ApiClient.getSummaryStatus`; terminal `ready` then `LoadSummary` / get document for texts; `failed` / timeout / 409 → failure for error UI.
- Grep under `lib/features/summarization/`: **no** `package:dio`, **no** feature-local `Timer` / poll loop; only `poller.poll(...)`.
- Covered by `summarization_providers_test.dart` (ready / poll→ready / 409 / failed+retry / dispose cancel) and flow tests.

### 11.4 Async UI gate

- `SummaryScreen` wraps `summaryResultProvider` in `AsyncValueView`:
  - loading → `LexivoSkeleton` lines + processing copy
  - error → `LexivoErrorBanner` (+ `onRetry` → notifier.retry → re-POST + re-poll)
  - ready empty (missing short or detailed) → `LexivoEmptyState`
  - ready with both texts → short then detailed `SelectableText` sections
- Widget + flow tests assert skeleton / empty / error+retry / short+detailed / not-ready paths.

### 11.5 Shared entity gate

- Freezed `Document.shortSummary` / `detailedSummary` / `summaryStatus` (`SummaryStatus` enum separate from OCR `DocumentStatus`) in `lib/core/entities/document.dart`; mapper + `DocumentDto` / `SummaryStatusDto` aligned (`@JsonKey` snake_case).
- Backend `DocumentResponse` + migration `0003_document_summaries` + OpenAPI snapshot; fixtures (`get_with_summaries`, status idle/processing/ready/failed, 409 envelope, empty ready).
- Feature view model `SummaryView` is backed by core `Document` (requires both short + detailed non-empty for `hasSummaries`).
- Production outside-feature import: `main.dart` → `features/summarization/summarization.dart` barrel only. `ocr` / `document_scan` do **not** import `features/summarization/**`.

### 11.6 Navigation gate

- Named route `/documents/:documentId/summary` (`RouteGuards.documentSummary`, GoRouter name `document-summary`).
- Builders injected via `summarizationCoreOverrides()` / `summaryScreenBuildersProvider` (stub in core, real screen from barrel) — mirrors ocr/document_scan.
- `OcrResultScreen`: `LexivoButton` “View summary” → `context.go(RouteGuards.documentSummary(documentId))` — route constant only; **no** summarization widget/data imports under `features/ocr/`.
- Unauthenticated summary path → sign-in (`summarization_router_test.dart`).

### 11.7 Clean architecture gate

- Tree: `data/{datasources,repositories,models}/`, `domain/{entities,repositories,usecases}/`, `presentation/{screens,widgets,providers}/`, barrel `summarization.dart`.
- Datasource: `ApiClient.getDocument` / `requestSummary` / `getSummaryStatus` only; `Result` + mappers.
- No Dio imports under `features/summarization/`. No `features/ocr` or `features/document_scan` imports under `features/summarization/`.
- HTTP 409 mapped to `ValidationFailure` in `ErrorMapper` (api_client + error_mapper tests).

### 11.8 UI composition gate

- Summary chrome composes design-system tokens/components + `AsyncValueView`; no feature-local visual atoms (widgets folder is placeholder).
- Screen/flow tests cover Lexivo* loading/error/empty paths; no ad-hoc Material primary action buttons as interactive atoms.

**Soft note (non-blocking):** back control is Material `IconButton`, not `LexivoButton`. Same acceptance as OCR review (navigation chrome; no Lexivo icon-button atom). Prefer Lexivo* if a back pattern is standardized later — not a DoD blocker.

### 11.9 Scope gate

- No translation / rag / export CTAs or screens in summarization feature.
- No Summary Agent / LLMProvider reimplementation on client; backend limited to thin router/service/Celery + model/OpenAPI persist (planned §0).
- Commits match claimed slice: `665633e` backend, `27d114b` core DTO/client, `b0edd16` feature + OCR route CTA.

### 11.10 TDD / stack gate

| Check | Evidence | Result |
|---|---|---|
| Freezed | Core `Document`, `DocumentDto`, `SummaryStatusDto` (+ generated) | **PASS** |
| Riverpod | `summaryResultProvider` family AsyncNotifier; overrides | **PASS** |
| Backend tests | `pytest` on `test_summary_api` + coupling/schemas/celery: **35 passed** | **PASS** |
| `flutter test` | **276 passed** (independent run) | **PASS** |

### 11.11 Final / OpenSpec + architecture

| OpenSpec / architecture requirement | Status |
|---|---|
| Short + detailed summaries persisted / syncable | **PASS** |
| Not-ready error if OCR incomplete (409 + clear detail) | **PASS** |
| Summary Agent only via Master / `run_master("summary")` | **PASS** |
| Feature isolation + typed ApiClient | **PASS** |
| Lexivo* composition for feature chrome | **PASS** (IconButton soft note) |
| Clean architecture §2.1 + barrel | **PASS** |
| Shared Document in core (§2.3) + summary fields | **PASS** |
| JobPoller for async job shape (§2.2) | **PASS** |
| No cross-feature imports; named routes | **PASS** |
| Out of scope preserved (translation later; no agent rewrite) | **PASS** |

---

## Soft notes (non-blocking)

1. `IconButton` back affordance — see §11.8; not a gate fail.
2. `SummaryView` is a plain equality class (plan allowed optional Freezed) — fine for this slice.
3. Empty `data/models/` and `presentation/widgets/` placeholders — scaffold only.
4. Plan §11 checkboxes / DoD roll-up and optional “slice DoD met” commit remain for planner after this PASS (reviewer does not edit plan or commit).

---

## Proceed decision

| Next work | Allowed? |
|---|---|
| Translation feature (next OpenSpec capability after summarization) | **Yes** — use core `Document` / named routes; do not import `features/summarization` internals |
| Plan §11 checkboxes / DoD roll-up | May be marked complete by planner after this PASS |
| Design-system Lexivo back/icon control | Optional polish; not required to unlock translation |
