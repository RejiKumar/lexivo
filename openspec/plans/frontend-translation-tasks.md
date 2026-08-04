# Frontend Translation — Task Plan
Capability: **translation** (Flutter + thin backend API to invoke Master `translation` intent)
Architecture: `spec/architecture.md` §2.1–§2.3 (feature-first clean architecture; `core/`; shared `Document` in `core/entities`; no cross-feature imports; reuse `job_poller` + `AsyncValueView`)
OpenSpec: `openspec/specs/translation/spec.md`
UI: compose **ONLY** from `core/design_system` (`Lexivo*` — especially `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoButton`, `LexivoSnackbar`). Loading/error/data via shared `AsyncValueView`. Any new visual atom → Design System Agent first — never inline one-offs.
Product: Lexivo
Execution order: **STEP 3.7 next feature** after summarization PASS

**Prerequisite (completed)**
- [x] STEP 3.7 summarization DoD **PASS** (`openspec/reviews/frontend-summarization-step37-review.md`) — translation may proceed; shared `Document` + OCR/`JobPoller` / summary route pattern unblock this slice without importing `summarization`, `ocr`, or `document_scan` internals
- [x] Design-system DoD **PASS** — `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoButton` available
- [x] Master Translation Agent exists on backend (`TranslationAgent` name=`translation`, wired in `run_master` / `NodeRegistry`; STEP 3.6 specialized-agents) — **HTTP invoke + persist still missing** (see §0)

**Out of scope for this file (later plans)**
- rag_chat, pdf-export, notifications, subscription features
- Reimplementing Translation Agent / LLMProvider / Master graph / prompts (agent already done)
- Client-side LLM / vendor SDKs
- New design-system atoms unless a gap is flagged below for Design System Agent
- CI/CD, Cloud Run, Drift offline sync for translations
- Changing OCR document `status` lifecycle or summarization fields (translation must not flip OCR `ready` → `processing`; must not mutate `summary_status`)

**Product defaults (resolved)**

| Concern | Choice |
|---|---|
| Feature home | `lib/features/translation/` — language pair picker + translated text presentation + trigger |
| Shared identity | Core Freezed `Document` (+ `translatedText`, `sourceLang`, `targetLang`, `translationStatus`); never import `summarization` / `ocr` / `document_scan` data/presentation |
| Backend gap | **Include thin API** — no translation routes/fields today; land persist + enqueue before Flutter can call typed client |
| Orchestration | Thin service / Celery task calls **only** `run_master("translation", …)` — never import `TranslationAgent` in router/service/task |
| Languages (v1) | EN↔ES, FR, DE, HI, PT — codes `en`,`es`,`fr`,`de`,`hi`,`pt`; pair requires English on one side; reject same-lang and unsupported codes |
| Trigger | `POST /api/v1/documents/{id}/translation` (auth) body `{ source_lang, target_lang }` → enqueue translation job; **409** when OCR incomplete (`status != ready` or empty `extracted_text`) with clear not-ready `detail`; **422** (or validation error) for unsupported / invalid language pair |
| Persist | `translated_text`, `source_lang`, `target_lang` on Document model + OpenAPI `DocumentResponse`; `translation_status`: `idle` \| `processing` \| `ready` \| `failed` (separate from OCR `Document.status` and `summary_status`) |
| Poll | `GET /api/v1/documents/{id}/translation/status` → `{ id, translation_status }` (+ optional langs); client uses core `JobPoller` only — **no** feature-local poll loop |
| Fetch source | `GET /api/v1/documents/{id}` includes nullable `translated_text` / `source_lang` / `target_lang` (+ `translation_status`) after §0; list may omit or null text fields |
| Async | **Yes** — LLM latency → Celery `run_translation` (mirror `run_summary` / `run_ocr`) + JobPoller |
| Ready UX | Show translated text (+ source/target labels) when `translation_status == ready` and `translated_text` non-empty; empty ready → `LexivoEmptyState` |
| Processing UX | Skeleton / processing copy while `JobPoller` runs; do not show stale translation as success after a new request |
| Failed UX | `LexivoErrorBanner` (+ optional `LexivoEmptyState`); `onRetry` = re-POST enqueue + re-poll |
| Not-ready UX | Do **not** enqueue; surface clear not-ready error via `LexivoErrorBanner` (map HTTP 409 → `ValidationFailure` or dedicated message) |
| Unsupported lang UX | Surface validation error via `LexivoErrorBanner` / field-level copy (map 422); do not start poller |
| Navigation | Named GoRouter only: e.g. `/documents/:documentId/translation`. Summary / OCR / library navigate via route constants — **no** direct widget imports across features |
| State | Riverpod (current pin ^2.6.1; prefer 3 when pins allow — same note as prior features) |
| Models | Freezed (+ json_serializable only for network DTOs) |
| HTTP | Typed `ApiClient` only — no `Dio(` / `package:dio` inside `features/translation/` |

**Conventions**
- Loop per chunk: failing test → implement → (widget test where UI) → review vs OpenSpec translation + architecture §2.1–§2.3 + Lexivo* composition → fix → commit.
- Prefer small sequential commits; never one giant “frontend-translation” commit.
- Feature public surface = barrel `features/translation/translation.dart` only.
- Screens: layout + `Lexivo*` + `AsyncValueView` only. Grep guard: no ad-hoc Material buttons as interactive atoms.
- All HTTP via `core/network` `ApiClient`.
- Prefixes: package `lexivo`; UI `Lexivo*`; never `Nexora*`.
- Do **not** import `features/summarization/**`, `features/ocr/**`, `features/document_scan/**`, or any other feature internals. Cross-feature wiring = named routes + injected screen builders only.
- Thin summary (or OCR / library) change allowed: pass CTA / `onTap` → `context.go` translation route by id — still no `features/translation/...` imports inside those features beyond route constants in `core/routing`.

**Design-system gap flag**
- Expected composition: translation screen = `AsyncValueView` + skeletons / error banner / empty state + language selectors (layout + existing Lexivo controls / chips if available) + translated text using typography tokens; primary CTA via `LexivoButton`.
- If a true visual gap appears (e.g. dedicated language-picker atom that cannot be layout + Lexivo*), **stop and flag Design System Agent** — do not invent feature-local atoms.

**Shared test fixtures (Test Agent ownership)**

| Location | Owns |
|---|---|
| `test/fixtures/documents/` | Extend JSON: get-with-translation, translation status `idle`/`processing`/`ready`/`failed`, not-ready / 409 envelope, unsupported-lang / 422 envelope, empty translation ready |
| `test/helpers/` | `FakeTranslationRepository`, `MockApiClient` translation POST/status/get stubs, controllable `JobPoller` clock/fake reuse |
| `test/core/entities/` | `Document` + translation fields mapping tests |
| `test/core/network/` | `requestTranslation` / `getTranslationStatus` / DTO field tests; 409 → ValidationFailure; 422 unsupported lang |
| `test/features/translation/` | Domain/data/presentation/flow tests (use helpers; no duplicate fakes) |
| `backend/tests/` | Thin translation service/router/task: not-ready, unsupported langs, `run_master` only, persist translated text + langs |

---

## 0. Backend thin API — invoke Master `translation` + persist (MISSING today)

OpenAPI / routers currently expose documents create/list/get/status + summary. Model has `extracted_text` / summary fields but **no** `translated_text` / `source_lang` / `target_lang` / `translation_status`. Translation Agent is callable only via Master in tests — **blocks Flutter**.

### 0.A Model + schemas + OpenAPI

- [ ] 0.1 **Decision gate:** document in this plan / `docs/api_client.md`: translation from `GET /documents/{id}` fields `translated_text` / `source_lang` / `target_lang`; poll `GET /documents/{id}/translation/status`; trigger `POST /documents/{id}/translation` with `{ source_lang, target_lang }`; OCR readiness gate on document `status == ready` + non-empty `extracted_text`; language codes validated to EN↔ES,FR,DE,HI,PT
- [ ] 0.2 Add ORM columns: `translated_text` (nullable Text), `source_lang` / `target_lang` (nullable String), `translation_status` enum/string (`idle`\|`processing`\|`ready`\|`failed`, default `idle`) — migration or create_all-compatible for tests
- [ ] 0.3 Extend Pydantic `DocumentResponse` (+ OpenAPI snapshot `openapi/lexivo.openapi.json`) with the four fields; add `TranslationStatusResponse` (`id`, `translation_status`); add request body schema `TranslationRequest` (`source_lang`, `target_lang`)
- [ ] 0.4 Write failing backend tests for schema/serialization of new fields

### 0.B Thin service + Celery task (Master only)

- [ ] 0.5 Write failing tests: enqueue/service rejects when document missing, wrong owner, `status != ready`, or empty `extracted_text` → not-ready error (HTTP 409 at router); rejects unsupported / same-lang / non-EN-pair codes → validation error (HTTP 422)
- [ ] 0.6 Write failing tests: success path sets `translation_status=processing`, persists requested langs, creates/reuses Job `job_type=translation`, Celery `run_translation` calls `run_master("translation", input={text: …, source_lang, target_lang, document_id})` with LLM injected; on success persists `translated_text` (+ langs) and `translation_status=ready`; on agent failure → `failed`
- [ ] 0.7 Assert task/service source: **has** `run_master`; **no** `TranslationAgent` / `translation_agent` import (extend coupling test if needed)
- [ ] 0.8 Implement thin `TranslationService` (or methods on DocumentService) + `enqueue_translation` / `run_translation` in tasks — status updates stay at task/service layer, not inside the agent; do not mutate OCR `status` or summary fields
- [ ] 0.9 Review vs OpenSpec “Translation Agent orchestration” + supported pairs + not-ready; fix; commit backend slice

### 0.C Router endpoints

- [ ] 0.10 Write failing API tests: `POST /api/v1/documents/{id}/translation` auth + ownership; 409 not-ready; 422 unsupported lang; 202/200 when enqueued (`translation_status=processing`)
- [ ] 0.11 Write failing API tests: `GET .../translation/status` returns processing/ready/failed/idle; `GET /documents/{id}` returns persisted translation when ready
- [ ] 0.12 Implement thin router handlers (documents router or `translations` sub-routes) — call service only; no agent imports
- [ ] 0.13 Refresh OpenAPI snapshot; commit

---

## 1. Typed client + fixtures (Flutter)

- [ ] 1.1 Write failing `ApiClient` / DTO unit tests: parse nullable `translated_text` / `source_lang` / `target_lang` / `translation_status` on get-document; `getTranslationStatus`; `requestTranslation` (POST with langs)
- [ ] 1.2 Write failing tests: HTTP 409 not-ready maps to `ValidationFailure`; HTTP 422 unsupported lang maps to `ValidationFailure` (extend `ErrorMapper` if needed)
- [ ] 1.3 Extend Freezed `DocumentDto` (+ generated) and OpenAPI-aligned fields; add translation status DTO + request body DTO
- [ ] 1.4 Implement `ApiClient.requestTranslation` / `getTranslationStatus`; update `docs/api_client.md` (`TODO(openapi-codegen)` note)
- [ ] 1.5 Add/update fixtures under `test/fixtures/documents/`
- [ ] 1.6 Review vs OpenSpec “typed client exclusively” (feature isolation parallel); fix; commit

---

## 2. Core shared entity — extend `Document`

Architecture §2.3: translation depends on core entity, not `summarization` / `ocr` / `document_scan`.

- [ ] 2.1 Write failing unit tests: Freezed `Document` optional `translatedText`, `sourceLang`, `targetLang`, `translationStatus` (enum or string-aligned); equality/copyWith; mapper from DTO; OCR + summary fields unchanged
- [ ] 2.2 Implement fields on `lib/core/entities/document.dart` (+ `TranslationStatus` enum separate from OCR `DocumentStatus` and `SummaryStatus`)
- [ ] 2.3 Update `document_mapper` + any constructors/tests broken by new fields so suite stays green
- [ ] 2.4 Review vs architecture §2.3; fix; commit

---

## 3. Feature scaffold (§2.1)

- [ ] 3.1 Create `lib/features/translation/` tree: `data/{datasources,repositories,models}/`, `domain/{entities,repositories,usecases}/`, `presentation/{screens,widgets,providers}/`, barrel `translation.dart`
- [ ] 3.2 Write failing barrel smoke: exports public translation screen builder / providers needed by router — **not** data-layer types
- [ ] 3.3 Review vs architecture §2.1 folder contract; fix; commit scaffold

---

## 4. Domain — repository + usecases

- [ ] 4.1 Define abstract `TranslationRepository`: `getDocument(id)`, `getTranslationStatus(id)`, `requestTranslation(id, sourceLang, targetLang)` → `Result` + core `Document` / `TranslationStatus` — **no** other feature types
- [ ] 4.2 Optional domain view model / Freezed `TranslationView`: document id, translation status, langs, translated text, title — still backed by core `Document`
- [ ] 4.3 Write failing usecase tests (fake repo): `LoadTranslation`, `RequestTranslation`, `GetTranslationStatus` (names flexible); success/failure/`not ready`/unsupported-lang `Result` shapes
- [ ] 4.4 Write failing tests: poll terminal when `translation_status` is `ready` or `failed`; `processing` is non-terminal; `idle` may trigger request then poll; supported pair helper (EN↔ES/FR/DE/HI/PT)
- [ ] 4.5 Implement usecases — each single `call()`, returns `Result`
- [ ] 4.6 Review vs OpenSpec supported pairs + orchestration (domain does not embed a private poller); fix; commit

---

## 5. Data layer — remote + repository impl

- [ ] 5.1 Write failing tests for `TranslationRemoteDatasource`: get / translation-status / POST via `ApiClient` only; DTO→entity mapping including translation fields; failures via `ErrorMapper`/`Result`
- [ ] 5.2 Implement datasource + `TranslationRepositoryImpl`
- [ ] 5.3 Riverpod providers for repository + usecases (override-friendly)
- [ ] 5.4 Assert no `package:dio` and no `features/summarization` / `features/ocr` / `features/document_scan` imports under `features/translation/`; fix; commit

---

## 6. Presentation — providers (Riverpod + JobPoller)

- [ ] 6.1 Write failing provider tests: open translation for doc with `translation_status=ready` → `AsyncValue` data with translated text + langs
- [ ] 6.2 Write failing tests: `idle` → user selects langs → POST requestTranslation then poll; `processing` → core `JobPoller` on `getTranslationStatus`; terminal `ready` → fetch document text; `failed` → error view model
- [ ] 6.3 Write failing tests: OCR not ready / 409 → clear not-ready error **without** starting poller; unsupported lang / 422 → validation error **without** starting poller
- [ ] 6.4 Write failing tests: dispose/cancel stops polling; timeout → user-visible error path; retry re-POSTs or reloads as designed
- [ ] 6.5 Implement notifier(s) (`translationResultProvider` family by document id, etc.) wiring **only** `JobPoller` from `core/utils`
- [ ] 6.6 Review vs OpenSpec scenarios “Translate to supported language” + “Unsupported language” + async job polling; fix; commit

---

## 7. Presentation — translation screen (Lexivo* only)

- [ ] 7.1 Write failing widget tests for **TranslationScreen** (name flexible): loading → `AsyncValueView` / `LexivoSkeleton`; ready → translated text (+ lang labels) visible; failed → `LexivoErrorBanner` with retry; empty ready → `LexivoEmptyState`; not-ready → clear error copy; unsupported lang → validation copy
- [ ] 7.2 Write failing tests: processing state shows skeleton/processing affordance (not fabricated success text); language selection limited to v1 supported targets (EN↔ES/FR/DE/HI/PT)
- [ ] 7.3 Implement screen composing Lexivo* + layout only; **no** rag_chat / export / subscription CTAs
- [ ] 7.4 Review vs OpenSpec feature isolation + Lexivo composition; fix; commit

---

## 8. Routing + navigation from summary / OCR / library

- [ ] 8.1 Write failing router tests: authenticated route e.g. `/documents/:documentId/translation`; unauthenticated → sign-in; named routes only
- [ ] 8.2 Extend `RouteGuards` + `app_router` with translation route; inject builders from `translation` barrel (mirror summarization/ocr) — **no** importing `translation/presentation` from summary/OCR data
- [ ] 8.3 Wire summary screen and/or OCR result / library when appropriate: CTA / action → `context.go(RouteGuards.documentTranslation(id))` using **only** `core/routing` helpers
- [ ] 8.4 Ensure summarization / OCR / document_scan still have **zero** imports of `features/translation/data` or internal widgets
- [ ] 8.5 Review vs architecture §2.3 navigation contract; fix; commit

---

## 9. End-to-end feature flow (widget/integration-ish)

- [ ] 9.1 Write failing flow test: navigate to translation (idle) → select langs → POST → poll → ready → shows translated text from fixtures
- [ ] 9.2 Write failing flow test: already-ready translation → screen shows text without long poll (or single status check then get)
- [ ] 9.3 Write failing flow test: not-ready document → clear error; no successful translation content
- [ ] 9.4 Write failing flow test: unsupported language → validation error; no poll; poll → failed → error banner + retry re-enters request/poll path
- [ ] 9.5 Wire providers in app bootstrap overrides alongside summarization/ocr/document_scan; bearer token still injected; review full OpenSpec translation **client** scenarios; fix; commit

---

## 10. Shared fixtures hygiene (Test Agent)

- [ ] 10.1 Add/extend `FakeTranslationRepository` + poller test helpers under `test/helpers/`
- [ ] 10.2 Add/update `test/fixtures/documents/*.json` for get+translation and translation status transitions + 409 not-ready + 422 unsupported lang
- [ ] 10.3 Keep fixture map in this plan’s table updated; commit

---

## 11. Reviewer gate checkpoints (STEP 3.7 translation slice)

Run after §§0–10 land; blockers must be fixed before declaring this slice done.

- [ ] 11.1 **Prerequisite gate:** summarization STEP 3.7 review still PASS; no regression in auth/core/document_scan/ocr/summarization suites
- [ ] 11.2 **Backend Master gate:** translation HTTP path enters only via `run_master("translation", …)`; no specialist imports in router/service/task; not-ready rejected (409); langs validated (EN↔ES/FR/DE/HI/PT); translated text + langs persisted
- [ ] 11.3 **Polling gate:** feature uses shared `JobPoller` + translation status endpoint; **no** feature-local poll implementation
- [ ] 11.4 **Async UI gate:** loading/error/data via `AsyncValueView` + `LexivoSkeleton` / `LexivoErrorBanner` / data or `LexivoEmptyState`
- [ ] 11.5 **Shared entity gate:** uses `core/entities` `Document` (+ translation fields); barrel does not force other features to import `translation` internals
- [ ] 11.6 **Navigation gate:** summary/OCR/library → translation via named routes only; no cross-feature widget/data imports
- [ ] 11.7 **Clean architecture gate:** §2.1 tree + barrel-only outside; no Dio inside feature; typed `ApiClient` only
- [ ] 11.8 **UI composition gate:** Lexivo* only; any DS gap flagged, not inlined
- [ ] 11.9 **Scope gate:** no rag_chat/export UIs; no Translation Agent reimplementation; no CI/CD; backend limited to thin router/service/task + persist/OpenAPI
- [ ] 11.10 **TDD / stack gate:** Freezed + Riverpod; `flutter test` green for core + translation (+ prior features); backend translation API tests green
- [ ] 11.11 Final review vs `openspec/specs/translation/spec.md` + architecture §2.1–§2.3; fix remaining gaps; commit “frontend translation STEP 3.7 slice DoD met”

---

## Definition of Done (STEP 3.7 — translation)

- [ ] Thin backend API: POST translation + translation status + persisted translated text/langs via `run_master("translation", …)` only; not-ready when OCR incomplete; unsupported langs rejected
- [ ] `features/translation/` clean architecture + barrel; typed API client only
- [ ] Translation UI with EN↔ES/FR/DE/HI/PT selection; processing / ready / failed / not-ready / unsupported via Lexivo* + `AsyncValueView` + core `JobPoller`
- [ ] Navigate from summary (and/or OCR/library) via named routes only
- [ ] Shared `Document` in `core/entities` with translation fields; no cross-feature imports
- [ ] Reviewer gates 11.1–11.11 passed
- [ ] Out of scope preserved (rag_chat and later features; no Translation Agent reimplementation)

---

## Coverage matrix (planner verification)

| Requirement (OpenSpec / architecture) | Plan section |
|---|---|
| Supported language pairs EN↔ES,FR,DE,HI,PT | §0.1, §0.5, §0.10, §4.4, §6.3, §7.2, §11.2 |
| Unsupported language validation error | §0.5, §0.10, §1.2, §6.3, §7.1, §9.4 |
| Translation Agent only via Master / `run_master` | §0.6–0.8, §11.2 |
| Async jobs + JobPoller + progress UX | §6, §7, §9, §11.3–11.4 |
| Persist translated text + status | §0, §1–2, §7, §9 |
| Not-ready (OCR incomplete) → 409 | §0.5, §0.10, §6.3, §7.1, §9.3, §11.2 |
| Feature isolation + typed ApiClient | §1, §5, §11.7 |
| Lexivo* composition only | §7, §11.8 |
| Clean architecture §2.1 + barrel | §3, §11.7 |
| Shared Document in core (§2.3) | §2, §11.5 |
| JobPoller for async job shape (§2.2) | §6, §9, §11.3 |
| No cross-feature imports; named routes | §8, §11.6 |
| Summarization prerequisite completed | Prerequisites (PASS review) |
| Out of scope: rag_chat / later; no agent rewrite | Out of scope, §11.9 |

**Client OpenSpec scenarios covered:** **Yes** — supported pair, unsupported language, Master orchestration (backend), async poll UX.

**Backend API tasks included:** **Yes** — dedicated §0 (model/persist + thin service/Celery + routers) because endpoints and translation fields are missing from current OpenAPI/routers.

**Task count:** **70** numbered TDD/gate tasks (0.1–11.11). Prerequisites (3) marked completed above and excluded. DoD summary list (7) is a roll-up of those gates, not extra work items.

---

## Reviewer

*(Leave blank for Reviewer Agent — fill after implementation.)*

| Field | Value |
|---|---|
| **Capability** | translation (Flutter + thin API) |
| **Reviewer** | |
| **Date** | |
| **Sources** | `openspec/specs/translation/spec.md`, `spec/architecture.md` §2.1–§2.3, this plan §11, `openspec/reviews/frontend-summarization-step37-review.md` |
| **Verdict** | |

### Gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Prerequisite — summarization STEP 3.7 still PASS | |
| 11.2 | Backend Master — `run_master("translation")` only; langs; not-ready; persist | |
| 11.3 | Polling — shared JobPoller + translation status | |
| 11.4 | Async UI — AsyncValueView + Lexivo* | |
| 11.5 | Shared entity — core Document + translation fields | |
| 11.6 | Navigation — named routes only | |
| 11.7 | Clean architecture — §2.1 + typed client | |
| 11.8 | UI composition — Lexivo* only | |
| 11.9 | Scope — no rag_chat/later; thin backend only | |
| 11.10 | TDD / stack — flutter + backend tests green | |
| 11.11 | Final vs OpenSpec + architecture | |

### Notes

-
