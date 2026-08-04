# Frontend Translation STEP 3.7 Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | translation (Flutter + thin backend API) + architecture §2.1–§2.3 |
| **Reviewer** | Reviewer Agent (independent) |
| **Date** | 2026-08-04 |
| **Sources** | `openspec/specs/translation/spec.md`, `spec/architecture.md` §2.1–§2.3, `openspec/plans/frontend-translation-tasks.md` §11, prior `openspec/reviews/frontend-summarization-step37-review.md` |
| **Claimed** | translation APIs + `features/translation`; pytest 272; flutter 308; §11 open |
| **Verdict** | **PASS** |

---

## Verdict

**PASS** — STEP 3.7 translation slice Definition of Done is met. Plan gates 11.1–11.11 all pass. Independent runs: backend **272 passed** (1 skipped); `flutter test` **308 passed**. No findings that block DoD or rag_chat follow-on.

**Is STEP 3.7 translation DoD met?** **Yes.**

**May rag_chat feature proceed?** **Yes.** Use named routes + core `Document` translation fields; do not import `features/translation` (or `summarization` / `ocr` / `document_scan`) internals.

---

## Gate-by-gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Prerequisite — summarization STEP 3.7 still PASS; no auth/core/document_scan/ocr/summarization regression | **PASS** |
| 11.2 | Backend Master — `run_master("translation")` only; langs; not-ready 409; unsupported 422; persist | **PASS** |
| 11.3 | Polling — shared `JobPoller` + translation status endpoint; no feature-local poll | **PASS** |
| 11.4 | Async UI — `AsyncValueView` + `LexivoSkeleton` / `LexivoErrorBanner` / data or `LexivoEmptyState` | **PASS** |
| 11.5 | Shared entity — `core/entities` `Document` (+ translation fields); barrel does not force translation internals | **PASS** |
| 11.6 | Navigation — summary → translation via named routes only; no cross-feature widget/data imports | **PASS** |
| 11.7 | Clean architecture — §2.1 tree + barrel-only outside; no Dio in feature; typed `ApiClient` | **PASS** |
| 11.8 | UI composition — Lexivo* only; any DS gap flagged, not inlined | **PASS** (soft notes) |
| 11.9 | Scope — no rag_chat/export UIs; no Translation Agent rewrite; thin backend only | **PASS** |
| 11.10 | TDD / stack — Freezed + Riverpod; flutter + backend tests green | **PASS** |
| 11.11 | Final vs OpenSpec translation + architecture §2.1–§2.3 | **PASS** |
| — | rag_chat may proceed | **Yes** |

---

## Evidence

### 11.1 Prerequisite gate

- Summarization STEP 3.7 review remains **PASS** (`openspec/reviews/frontend-summarization-step37-review.md`); translation was cleared to proceed.
- Independent full Flutter suite **308 passed** — includes auth, core, document_scan, ocr, summarization, and translation; no regression observed.
- Full backend pytest **272 passed**, 1 skipped — claim matched.

### 11.2 Backend Master gate

- Commits: `895e428` (thin translation API + persist), covered by `backend/tests/test_translation_api.py` + coupling guards.
- Router `POST /api/v1/documents/{id}/translation` → `TranslationService.request_translation` only; `ConflictError` → **HTTP 409** when OCR `status != ready` or empty `extracted_text`; `ValidationError` / unsupported `SupportedLangLiteral` → **HTTP 422**.
- Language pair rules: codes `en|es|fr|de|hi|pt`; English on one side; same-lang rejected (`validate_language_pair`).
- Celery `run_translation` calls `await run_master("translation", {text, source_lang, target_lang, document_id}, …)` then persists `translated_text` (+ langs) and `translation_status=ready` (failure → `failed`).
- Source guards: `test_translation_task_enters_via_master_only` + API tests assert task has `run_master` and **no** `TranslationAgent` / `translation_agent` imports. Router/service have no specialist imports (comment-only mention in service docstring).
- OCR / summary lifecycle untouched: service/task update `translation_status` (+ langs / `translated_text`), not document OCR `status` or `summary_status`.

### 11.3 Polling gate

- `TranslationResultNotifier` uses `translationJobPollerProvider` → core `JobPoller` while status is `processing`.
- Ticks call `GetTranslationStatus` → `ApiClient.getTranslationStatus`; terminal `ready` then load document for text; `failed` / timeout / 409 → failure for error UI.
- Grep under `lib/features/translation/`: **no** `package:dio`, **no** feature-local `Timer` poll loop; only `poller.poll(...)`.
- Covered by `translation_providers_test.dart` (409 without polling, etc.) and flow tests.

### 11.4 Async UI gate

- `TranslationScreen` wraps `translationResultProvider` in `AsyncValueView`:
  - loading → `LexivoSkeleton` lines + processing copy
  - error → `LexivoErrorBanner` via `AsyncValueView` (+ `onRetry` → notifier.retry → re-POST + re-poll)
  - ready empty → `LexivoEmptyState`
  - ready with text → lang labels + `SelectableText`
  - client-side unsupported pair → `LexivoErrorBanner` before enqueue (no poller)
- Widget + flow tests assert idle → select → POST → poll → ready; failed+retry; not-ready paths.

### 11.5 Shared entity gate

- Freezed `Document.translatedText` / `sourceLang` / `targetLang` / `translationStatus` (`TranslationStatus` enum separate from OCR `DocumentStatus` and `SummaryStatus`) in `lib/core/entities/document.dart`; mapper + `DocumentDto` / `TranslationStatusDto` / `TranslationRequestDto` aligned.
- Backend `DocumentResponse` + model columns + OpenAPI snapshot (`TranslationRequest`, status response); fixtures (`get_with_translation`, status idle/processing/ready/failed, 409 envelope, empty ready).
- Feature view model `TranslationView` is backed by core `Document`.
- Production outside-feature import: `main.dart` → `features/translation/translation.dart` barrel only. `summarization` / `ocr` / `document_scan` do **not** import `features/translation/**`.

### 11.6 Navigation gate

- Named route `/documents/:documentId/translation` (`RouteGuards.documentTranslation`, GoRouter name `document-translation`).
- Builders injected via `translationCoreOverrides()` / `translationScreenBuildersProvider` (stub in core, real screen from barrel) — mirrors summarization/ocr/document_scan.
- `SummaryScreen`: `LexivoButton` “Translate” → `context.go(RouteGuards.documentTranslation(documentId))` — route constant only; **no** translation widget/data imports under `features/summarization/`.
- Unauthenticated translation path → sign-in (`translation_router_test.dart`).

### 11.7 Clean architecture gate

- Tree: `data/{datasources,repositories}/`, `domain/{entities,repositories,usecases}/`, `presentation/{screens,providers}/`, barrel `translation.dart`.
- Datasource: `ApiClient.getDocument` / `requestTranslation` / `getTranslationStatus` only; `Result` + mappers.
- No Dio imports under `features/translation/`. No `features/summarization` / `ocr` / `document_scan` imports under `features/translation/`.
- HTTP 409 / 422 mapped to `ValidationFailure` in `ErrorMapper`.

### 11.8 UI composition gate

- Translation chrome composes design-system tokens/components + `AsyncValueView`; primary CTA via `LexivoButton`; no feature-local visual atom files.
- Screen/flow tests cover Lexivo* loading/error/empty paths.

**Soft notes (non-blocking):**
1. Back control is Material `IconButton`, not `LexivoButton` — same acceptance as summarization/OCR reviews (navigation chrome).
2. Language selectors use Material `DropdownButtonFormField` + Lexivo typography/spacing (layout + existing controls; no invented feature-local atom). Prefer a Lexivo picker if Design System later standardizes one — not a DoD blocker.

### 11.9 Scope gate

- No rag_chat / pdf-export CTAs or screens in translation feature.
- No Translation Agent / LLMProvider reimplementation on client; backend limited to thin router/service/Celery + model/OpenAPI persist (planned §0).
- Commits match claimed slice: `895e428` backend, `c5f7dc1` core DTO/client, `e6bddfb` feature + summary route CTA.

### 11.10 TDD / stack gate

| Check | Evidence | Result |
|---|---|---|
| Freezed | Core `Document`, `DocumentDto`, translation DTOs (+ generated) | **PASS** |
| Riverpod | `translationResultProvider` family AsyncNotifier; overrides | **PASS** |
| Backend tests | Full `pytest`: **272 passed**, 1 skipped; translation slice (`test_translation_api` + coupling/celery): **40 passed** | **PASS** |
| `flutter test` | **308 passed** (independent run) | **PASS** |

### 11.11 Final / OpenSpec + architecture

| OpenSpec / architecture requirement | Status |
|---|---|
| Supported pairs EN↔ES,FR,DE,HI,PT + unsupported validation | **PASS** |
| Not-ready error if OCR incomplete (409 + clear detail) | **PASS** |
| Translation Agent only via Master / `run_master("translation")` | **PASS** |
| Persist translated text + langs + `translation_status` | **PASS** |
| Feature isolation + typed ApiClient | **PASS** |
| Lexivo* composition for feature chrome | **PASS** (soft notes) |
| Clean architecture §2.1 + barrel | **PASS** |
| Shared Document in core (§2.3) + translation fields | **PASS** |
| JobPoller for async job shape (§2.2) | **PASS** |
| No cross-feature imports; named routes | **PASS** |
| Out of scope preserved (rag_chat later; no agent rewrite) | **PASS** |

---

## Soft notes (non-blocking)

1. `IconButton` back affordance — see §11.8; not a gate fail.
2. Material `DropdownButtonFormField` language pickers — see §11.8; not a gate fail.
3. ORM translation columns exist on the model and are create_all-compatible for tests; no dedicated Alembic revision beyond summarization `0003` (plan allowed create_all for tests; CI/Cloud Run out of scope). Add a migration before production deploy if not using create_all.
4. Plan §11 checkboxes / DoD roll-up and optional “slice DoD met” commit remain for planner after this PASS (reviewer does not edit plan or commit).

---

## Proceed decision

| Next work | Allowed? |
|---|---|
| rag_chat feature (next OpenSpec capability after translation) | **Yes** — use core `Document` / named routes; do not import `features/translation` internals |
| Plan §11 checkboxes / DoD roll-up | May be marked complete by planner after this PASS |
| Design-system Lexivo back / language-picker atoms | Optional polish; not required to unlock rag_chat |
| Alembic migration for translation columns | Recommended before production DB upgrade; not a STEP 3.7 Flutter DoD blocker |
