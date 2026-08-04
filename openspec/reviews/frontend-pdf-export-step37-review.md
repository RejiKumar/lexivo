# Frontend PDF Export STEP 3.7 Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | pdf-export (Flutter + thin export API) + architecture §2.1–§2.3 |
| **Reviewer** | Reviewer Agent (independent) |
| **Date** | 2026-08-04 |
| **Sources** | `openspec/specs/pdf-export/spec.md`, `spec/architecture.md` §2.1–§2.3, `openspec/plans/frontend-pdf-export-tasks.md` §11, prior `openspec/reviews/frontend-rag-chat-step37-review.md` |
| **Claimed** | export APIs + `features/pdf_export`; commits `d0dd615`, `192af29`; §11 open |
| **Verdict** | **PASS** |

---

## Verdict

**PASS** — STEP 3.7 pdf-export slice Definition of Done is met. Plan gates 11.1–11.11 all pass. Independent runs: backend **311 passed** (1 skipped); `flutter test` **364 passed**. No findings that block DoD or notifications follow-on.

**Is STEP 3.7 pdf-export DoD met?** **Yes.**

**May notifications feature proceed?** **Yes.** Export completes via `JobPoller` in this slice; processing-complete push/in-app notification remains deferred to the notifications plan. Do not import `features/pdf_export` (or prior feature) internals from notifications — use named routes + core identity only.

---

## Findings

No findings.

---

## Gate-by-gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Prerequisite — rag-chat STEP 3.7 still PASS; no auth/core/document_scan/ocr/summarization/translation/rag_chat regression | **PASS** |
| 11.2 | Backend Master — `run_master("export")` only; toggles/readiness; signed_url; failure | **PASS** |
| 11.3 | Storage — StorageProvider signed URL; no public bucket | **PASS** |
| 11.4 | Async UI — JobPoller + AsyncValueView + Lexivo*; notifications deferred | **PASS** |
| 11.5 | Shared entity — core Document identity; barrel does not force pdf_export internals | **PASS** |
| 11.6 | Navigation — chat → export via named routes only; no cross-feature widget/data imports | **PASS** |
| 11.7 | Clean architecture — §2.1 tree + barrel-only outside; no Dio in feature; typed `ApiClient` | **PASS** |
| 11.8 | UI composition — section toggles + Lexivo* CTAs | **PASS** (soft notes) |
| 11.9 | Scope — no notifications/subscription; thin backend only; no Export Agent rewrite | **PASS** |
| 11.10 | TDD / stack — Freezed + Riverpod; flutter + backend tests green | **PASS** |
| 11.11 | Final vs OpenSpec pdf-export + architecture §2.1–§2.3 | **PASS** |
| — | notifications may proceed | **Yes** |

---

## Evidence

### 11.1 Prerequisite gate

- Rag-chat STEP 3.7 review remains **PASS** (`openspec/reviews/frontend-rag-chat-step37-review.md`); pdf_export was cleared to proceed.
- Independent full Flutter suite **364 passed** — includes auth, core, document_scan, ocr, summarization, translation, rag_chat, and pdf_export; no regression observed (prior rag-chat baseline was 341).
- Full backend pytest **311 passed**, 1 skipped — prior claim baseline was 291; net growth matches export API + related coverage.

### 11.2 Backend Master gate

- Commits: `d0dd615` (thin export API via Master export intent), covered by `backend/tests/test_export_api.py` + coupling guards in `test_agent_coupling.py` / export module source asserts.
- Router `POST /api/v1/documents/{doc_id}/export` → `ExportService.request_export` only; zero toggles → **HTTP 422**; section not ready / empty content → **HTTP 409**; missing/wrong-owner doc → **404**; enqueue → **202** with `export_status=processing`.
- Status: `GET .../export/status` (latest) and `GET /api/v1/exports/{export_id}`; ready includes `signed_url`; failure marks `failed` and allows retry via new POST.
- Celery `run_export` assembles section content server-side then `await run_master("export", …, storage=storage)`; on success persists `storage_key` + `signed_url` + `ready`; on agent failure → `failed`.
- Source guards: router + service + task have **no** `ExportAgent` / `export_agent` / `app.agents.export_agent` imports; task has `from app.agents.master_agent import run_master`. Summary-only path omits other section payloads in Master input.

### 11.3 Storage gate

- PDF upload + signed URL live in Export Agent via `StorageProvider` (`export_agent.py`: `upload` + `signed_url`). Thin ExportService/router do not call R2/boto3 or StorageProvider directly.
- Client receives time-limited `signed_url` on ready status; Flutter opens via `url_launcher` — no public bucket requirement.

### 11.4 Async UI gate

- `PdfExportScreen` wraps `pdfExportProvider` in `AsyncValueView`:
  - loading / processing → `LexivoSkeleton` + “Preparing PDF…”
  - error (409/422/failed/timeout) → `LexivoErrorBanner` via `AsyncValueView` (+ retry → re-POST with last toggles)
  - idle → section toggles + export CTA
  - ready → `LexivoButton` “Download PDF” when `signedUrl` present
- `PdfExportNotifier` polls exclusively via core `JobPoller` (`pdfExportJobPollerProvider`); grep under `lib/features/pdf_export/`: **no** feature-local `Timer` poll loop.
- Notifications UI / preference not present (deferred by plan).

### 11.5 Shared entity gate

- Document identity is the route `documentId` string; readiness hints read existing API document fields (`summaryStatus` / `translationStatus` / OCR `status`) without importing other features.
- `lib/core/entities/document.dart` **unchanged** in this slice (no new export pointer fields).
- Export domain stays feature-owned Freezed (`ExportJob`, `ExportSectionToggles`); ChatMessage not promoted to core.
- Barrel `pdf_export.dart` exports providers / screen / entities / terminal helper only — not data-layer types.

### 11.6 Navigation gate

- Chat CTA → `context.go(RouteGuards.documentExport(documentId))` using **only** `core/routing` (no `features/pdf_export` import inside rag_chat).
- Core route `/documents/:documentId/export` wired via `pdfExportScreenBuildersProvider` override from barrel (`pdfExportCoreOverrides`) — same pattern as prior features.
- No imports of rag_chat / translation / summarization / ocr / document_scan internals from `pdf_export`; other features do not import `pdf_export` data/widgets (only `main.dart` barrel + route bridge).

### 11.7 Clean architecture gate

- Tree: `data/` (datasource, mappers, repository_impl) / `domain/` (entities, repository, usecases) / `presentation/` (providers, screen) + barrel.
- Datasource uses typed `ApiClient.requestExport` / `getExportStatus` / `getExport` only; **no** `package:dio` under `features/pdf_export`.
- Paths align with OpenAPI `/api/v1/documents/{id}/export`, `/export/status`, `/exports/{id}`. ErrorMapper maps 409/422 → `ValidationFailure`.

### 11.8 UI composition gate

- Three section toggles (summary / translation / chat annotations); export CTA validates locally when none selected; download CTA when ready.
- Compose uses `LexivoButton`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoTypography` / `LexivoSpacing` / `LexivoColors`, `AsyncValueView`.
- Soft notes (non-blocking, same class as prior STEP 3.7 reviews):
  1. `IconButton` back affordance (not a Lexivo* control).
  2. Section rows use Material `SwitchListTile` themed with `LexivoColors.brandPrimary` — plan explicitly allows themed `Switch` without a dedicated `LexivoSwitch` atom.
  3. Soft readiness hints fetch `DocumentDto` via `ApiClient.getDocument` rather than mapping through `core/entities` `Document`; acceptable for hints; identity remains document id only.

### 11.9 Scope gate

- No notifications feature UI; no subscription/paywall gating on export.
- No Export Agent / StorageProvider / Master graph rewrite in this slice — thin ExportService + router + Celery task + OpenAPI only.
- Export Agent PDF builder remains the STEP 3.6 specialist path.

### 11.10 TDD / stack gate

- Freezed entities + Riverpod `AsyncNotifierProvider.family`.
- Independent: `pytest` **311 passed**, 1 skipped; `flutter test` **364 passed**.
- Focused: `tests/test_export_api.py` + coupling + export agent **40 passed**; Flutter `test/features/pdf_export` + `api_client_export_test` **23 passed**.
- Fixtures under `test/fixtures/exports/` + `FakePdfExportRepository` / harness present.

### 11.11 Final vs OpenSpec + architecture

| OpenSpec / architecture requirement | Met? |
|---|---|
| Multi-section PDF + per-section toggles | Yes |
| Export subset (e.g. summary only) | Yes |
| Export Agent via Master + StorageProvider signed URL | Yes |
| Async job + JobPoller; failure + retry | Yes |
| Processing-complete notification | Deferred by plan (explicit out of scope); poller completes UX |
| Typed client; feature `pdf_export/` §2.1 | Yes |
| Core Document identity; no cross-feature imports | Yes |
| Lexivo* composition | Yes (soft notes above) |

---

## Residual risk / test gaps

- Signed URL expiry refresh is not client-driven beyond re-POST / re-poll — acceptable for this slice.
- Soft Document-hint path uses DTO strings, not `documentFromDto` → core entity; low risk.
- Plan §11.11 “DoD met” commit is an author follow-up after this PASS; not a gate failure.

---

## May notifications proceed?

**Yes.** STEP 3.7 pdf-export DoD is met. Notifications may begin with the understanding that export UX already completes via JobPoller; push/in-app “processing complete” is additive and must not break Master-only export or cross-feature import rules.
