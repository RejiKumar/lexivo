# Frontend Document Scan — Task Plan
Capability: **document-scan** (Flutter)
Architecture: `spec/architecture.md` §2.1–§2.3 (feature-first clean architecture; `core/`; promote shared `Document` to `core/entities`; no cross-feature imports)
OpenSpec: `openspec/specs/document-scan/spec.md`
UI: compose **ONLY** from `core/design_system` (`Lexivo*` — especially `LexivoDocumentCard`, `LexivoEmptyState`, `LexivoButton`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoSnackbar`). Any new visual atom → Design System Agent first — never inline one-offs.
Product: Lexivo
Execution order: **STEP 3.7 next feature** after auth PASS

**Prerequisite (completed)**
- [x] STEP 3.7 auth + core network/routing DoD **PASS** (`openspec/reviews/frontend-auth-step37-review.md`) — `document_scan` may proceed
- [x] Design-system DoD **PASS** — `LexivoDocumentCard` (thumbnail, name, status badge, timestamp) available
- [x] Backend documents create/upload/list/get/status APIs exist (`POST/GET /api/v1/documents`, `GET /{id}`, `GET /{id}/status`); StorageProvider upload happens **server-side** on create

**Out of scope for this file (later plans)**
- OCR result view / extracted-text UI (`ocr` capability)
- Summarization, translation, rag-chat, pdf-export, notifications, subscription features
- Client-side StorageProvider / R2 SDK calls (forbidden — upload bytes via typed API multipart only)
- New design-system atoms unless a gap is flagged below for Design System Agent
- CI/CD, Cloud Run, Drift offline sync for documents
- Full production-grade document edge-detection ML on every platform (MVP crop step allowed — see Product defaults)

**Product defaults (resolved)**

| Concern | Choice |
|---|---|
| Input abstraction | Single `DocumentInputSource` (domain contract + one implementation façade). Capability probe chooses camera vs file — **no** `if (kIsWeb)` / per-platform UI forks in screens |
| Camera path | When camera capability is available + permission granted → capture → **edge detect/crop** (or documented MVP interactive crop step) → confirm bytes |
| Fallback path | Same abstraction returns file bytes (image/PDF) when camera unavailable/denied |
| Upload | `ApiClient.createDocument` multipart `file` + optional `title` → backend `create_with_upload` (R2 via StorageProvider + enqueue processing). Feature never imports storage SDKs |
| Shared identity | Freezed `Document` (+ `DocumentStatus`) in `lib/core/entities/` — not feature-private |
| Status UX | Map domain status → `LexivoDocumentStatus` for `LexivoDocumentCard` badges; poll via existing `JobPoller` + `getDocumentStatus` |
| State | Riverpod (current pin ^2.6.1; prefer 3 when pins allow — same note as auth) |
| Models | Freezed (+ json_serializable only for network DTOs) |
| Routing | GoRouter named routes only; inject builders like auth — no cross-feature widget imports |

**Conventions**
- Loop per chunk: failing test → implement → (widget test where UI) → review vs OpenSpec document-scan + architecture §2.1–§2.3 + Lexivo* composition → fix → commit.
- Prefer small sequential commits; never one giant “frontend-document-scan” commit.
- Feature public surface = barrel `features/document_scan/document_scan.dart` only.
- Screens: layout + `Lexivo*` only. Grep guard: no ad-hoc Material buttons/text fields/cards as interactive atoms.
- All HTTP via `core/network` `ApiClient` — no `Dio(` / `package:dio` inside `features/document_scan/`.
- Prefixes: package `lexivo`; UI `Lexivo*`; never `Nexora*`.
- Do **not** import `features/auth/data` or any other feature internals; auth only via existing core guard/session providers + named routes.

**Design-system gap flag**
- Expected composition covers library + scan CTA with existing atoms (`LexivoDocumentCard`, `LexivoEmptyState`, `LexivoButton`, sheets/dialogs if needed).
- If a true visual gap appears (e.g. dedicated crop chrome that cannot be layout + Lexivo*), **stop and flag Design System Agent** — do not invent feature-local atoms.

**MVP crop note (must document in code comment + this plan)**
- Prefer a real edge-detect + crop plugin on mobile when practical.
- Acceptable MVP: after camera capture (or when edge-detect unavailable), present a single interactive crop step before confirm. File-upload path may skip crop when the user already picked a finished image/PDF.
- Record the chosen packages and MVP vs full edge-detect in §0 decision gate.

**Shared test fixtures (Test Agent ownership)**

| Location | Owns |
|---|---|
| `test/fixtures/documents/` | JSON samples: list, get, status (`processing`/`ready`/`failed`), create response, error envelopes |
| `test/helpers/` | `FakeDocumentRepository`, `FakeDocumentInputSource`, `MockApiClient` extensions for multipart create, `ProviderContainer` harness reuse |
| `test/core/entities/` | Shared `Document` entity tests |
| `test/core/network/` | `createDocument` multipart tests on `ApiClient` |
| `test/features/document_scan/` | Domain/data/presentation/input-source tests (use helpers; no duplicate fakes) |

---

## 0. Dependencies + DocumentInputSource package decision

### 0.A Pubspec

- [x] 0.1 Add runtime deps needed for unified input (spike first if unsure): e.g. `camera` and/or `image_picker`, `file_picker`, crop/`image_cropper` (or chosen edge-detect package). Prefer packages that work on mobile + web where possible; wrap behind `DocumentInputSource` so screens never import plugins directly
- [x] 0.2 Document platform permissions (camera/photos) in README / `.env.example` notes as needed; no secrets
- [x] 0.3 **Decision gate:** write short ADR comment in plan §0 / `docs/document_input_source.md`: camera probe strategy; crop = edge-detect plugin **or** MVP crop step; file types (jpeg/png/pdf); web behavior
- [x] 0.4 Review vs OpenSpec “Unified document input source”; fix; commit deps + decision note

### 0.B ApiClient create/upload gap

Auth slice stubbed list/get/status only — **create multipart is missing** and blocks upload scenarios.

- [x] 0.5 Write failing `ApiClient` unit test: `POST /api/v1/documents` multipart (`file` bytes + filename, optional `title` form field) → `DocumentDto`; maps Dio errors via `ErrorMapper`
- [x] 0.6 Implement `createDocument({required List<int> bytes, required String filename, String? title})` on `ApiClient` (interim façade); keep `TODO(openapi-codegen)` regen note updated in `docs/api_client.md`
- [x] 0.7 Add/update fixtures under `test/fixtures/documents/`; extend OpenAPI snapshot if regenerating
- [x] 0.8 Review: feature code will call only this method for upload — never storage SDK; fix; commit

---

## 1. Core shared entity — `Document`

Architecture §2.3: promote shared identity so OCR/RAG/export never import `document_scan`.

- [x] 1.1 Write failing unit tests for Freezed `Document` / `DocumentStatus` (`processing`, `ready`, `failed`): equality, copyWith, status mapping helpers to/from API string + to `LexivoDocumentStatus`
- [x] 1.2 Implement `lib/core/entities/document.dart` (and barrel `lib/core/entities/entities.dart` if useful)
- [x] 1.3 Mapper utility (core or feature data): `DocumentDto` → `Document` — no design-system imports in entity file
- [x] 1.4 Review vs architecture §2.3 “Cross-feature document reference”; fix; commit

---

## 2. Feature scaffold (§2.1)

- [x] 2.1 Create `lib/features/document_scan/` tree: `data/{datasources,repositories,models}/`, `domain/{entities,repositories,usecases}/`, `presentation/{screens,widgets,providers}/`, barrel `document_scan.dart`
- [x] 2.2 Write failing barrel smoke: exports public screens/providers/`DocumentInputSource` contract as needed by router/tests — **not** data-layer types
- [x] 2.3 Review vs architecture §2.1 folder contract; fix; commit scaffold

---

## 3. Domain — DocumentInputSource + repository + usecases

### 3.A DocumentInputSource (required — covered end-to-end)

- [x] 3.1 Define abstract `DocumentInputSource` in feature domain (or `core/` only if reused outside this feature immediately — default: feature domain, exported via barrel): `Future<bool> get isCameraAvailable`; `Future<Result<DocumentBytes, Failure>> captureOrPick({required DocumentInputPreference preference})` (or split `captureWithCamera` / `pickFile` with a single orchestrator usecase)
- [x] 3.2 Freezed `DocumentBytes` (or equivalent): bytes, filename, mimeType, source enum (`camera` \| `file`)
- [x] 3.3 Write failing unit tests with `FakeDocumentInputSource`: camera-available path returns camera-sourced bytes; unavailable/denied path returns file-sourced bytes through **same** API; preference/`auto` never requires UI to branch on platform
- [x] 3.4 Write failing tests: camera path invokes crop/edge-detect step (fake cropper) before returning; file path returns selected bytes (crop optional/skip for PDF)
- [x] 3.5 Implement concrete `DocumentInputSourceImpl` in `data/` wrapping plugins + cropper behind interfaces (`CameraGateway`, `FilePickerGateway`, `DocumentCropper`) for testability
- [x] 3.6 Review vs OpenSpec scenarios “Camera available” / “Camera unavailable”; **no screen-level platform forks**; fix; commit

### 3.B Repository + usecases

- [x] 3.7 Define abstract `DocumentRepository`: `listDocuments`, `getDocument`, `getStatus`, `createWithUpload` (bytes/filename/title) — returns `Result` + core `Document`
- [x] 3.8 Write failing usecase tests (fake repo + fake input source): `ObtainDocumentInput`, `UploadDocument`, `ListDocuments`, `WatchOrPollDocumentStatus` (or separate poll usecase using `JobPoller`)
- [x] 3.9 Implement usecases — each single `call()`, returns `Result`
- [x] 3.10 Review vs OpenSpec “Document creation after capture” + “Shared Document entity”; fix; commit

---

## 4. Data layer — remote + repository impl

- [x] 4.1 Write failing tests for `DocumentRemoteDatasource`: `list`/`get`/`status`/`create` via `ApiClient` only; DTO→entity mapping; failures mapped
- [x] 4.2 Implement datasource + `DocumentRepositoryImpl`
- [x] 4.3 Riverpod providers for repository + `DocumentInputSource` (override-friendly for tests)
- [x] 4.4 Assert no `package:dio` import under `features/document_scan/`; fix; commit

---

## 5. Presentation — providers (Riverpod)

- [x] 5.1 Write failing provider tests: library loads list → `AsyncValue` data/error/loading; empty list is valid empty state
- [x] 5.2 Write failing tests: scan flow — obtain input → upload → document appears with `processing`; failure surfaces `Failure` without corrupting library
- [x] 5.3 Write failing tests: status poll via `JobPoller` + `getDocumentStatus` updates card status `processing` → `ready` / `failed`; cancel/dispose stops polling
- [x] 5.4 Implement notifiers/providers (`documentLibraryProvider`, `documentScanController`, status poller wiring)
- [x] 5.5 Review vs OpenSpec “Status reflection”; fix; commit

---

## 6. Presentation — Capture / Scan screen (Lexivo* only)

- [x] 6.1 Write failing widget tests for **DocumentScanScreen** (name flexible): primary CTA starts `DocumentInputSource` flow; loading on `LexivoButton`; errors via `LexivoErrorBanner` / snackbar; success navigates to library or shows confirmation — **grep: no platform `if (kIsWeb)` in this screen**
- [x] 6.2 Implement scan screen composing Lexivo* + layout only; crop UI may be plugin-provided chrome wrapped by feature widget that still uses Lexivo actions for confirm/cancel where controllable
- [x] 6.3 If crop UI cannot meet design-system rules, flag Design System Agent; do not ship raw Material-only primary actions without Lexivo*
- [x] 6.4 Review vs OpenSpec input + creation scenarios; fix; commit

---

## 7. Presentation — Library screen (LexivoDocumentCard)

- [x] 7.1 Write failing widget tests for **DocumentLibraryScreen**: loading → skeleton/`AsyncValueView`; empty → `LexivoEmptyState` + CTA to scan; items → `LexivoDocumentCard` with name, timestamp, status badge, optional thumbnail
- [x] 7.2 Write failing tests: status badge reflects `processing` / `ready` / `failed` via `LexivoDocumentStatus` mapping
- [x] 7.3 Implement library screen; feature-local list widgets compose Lexivo* only (no bespoke card chrome)
- [x] 7.4 Review vs OpenSpec “Document library presentation”; fix; commit

---

## 8. Routing + authenticated shell wiring

- [x] 8.1 Write failing router tests: authenticated routes for library + scan (e.g. `/documents`, `/documents/scan`); unauthenticated → sign-in; named routes only
- [x] 8.2 Extend `app_router` / `RouteGuards` with document routes; inject screen builders from `document_scan` barrel (mirror auth pattern) — **no** importing `document_scan/presentation` from auth data
- [x] 8.3 Replace `AuthHomeShell` placeholder affordance with navigation entry to document library (Lexivo* CTA / bottom-nav item if already available — do not invent nav atoms)
- [x] 8.4 Review vs architecture §2.3 navigation contract; fix; commit

---

## 9. End-to-end feature flow (widget/integration-ish)

- [x] 9.1 Write failing flow test: fake camera-available source → crop confirm → multipart create mocked → library shows processing card → poll → ready badge
- [x] 9.2 Write failing flow test: camera denied/unavailable → same UI entry → file pick → upload → library entry
- [x] 9.3 Wire providers in app bootstrap overrides alongside auth; ensure bearer token still injected for document calls
- [x] 9.4 Review full OpenSpec document-scan scenarios; fix; commit

---

## 10. Shared fixtures hygiene (Test Agent)

- [x] 10.1 Add `FakeDocumentRepository`, `FakeDocumentInputSource`, multipart create helpers under `test/helpers/`
- [x] 10.2 Add `test/fixtures/documents/*.json` for list/get/status/create + errors
- [x] 10.3 Keep fixture map in this plan’s table updated; commit

---

## 11. Reviewer gate checkpoints (STEP 3.7 document-scan slice)

Run after §§0–10 land; blockers must be fixed before declaring this slice done.

- [ ] 11.1 **Prerequisite gate:** auth STEP 3.7 review still PASS; no regression in auth/core suites
- [ ] 11.2 **DocumentInputSource gate:** one abstraction; camera when available + crop/edge-detect (or documented MVP crop); file fallback; **zero** screen-level platform UI forks; tests cover both OpenSpec input scenarios
- [ ] 11.3 **Upload / Storage gate:** create goes through `ApiClient` multipart only; no client StorageProvider/R2 SDK; backend enqueue implied by create response `processing`
- [ ] 11.4 **Shared entity gate:** `Document` lives in `core/entities`; feature barrel does not force other features to import `document_scan` internals
- [ ] 11.5 **Library / card gate:** library uses `LexivoDocumentCard`; badges track processing/ready/failed; empty/loading/error via Lexivo* / `AsyncValueView`
- [ ] 11.6 **Clean architecture gate:** §2.1 tree + barrel-only outside; no cross-feature data imports; no Dio inside feature
- [ ] 11.7 **UI composition gate:** Lexivo* only; any DS gap flagged, not inlined
- [ ] 11.8 **Scope gate:** no OCR result view, summarization, rag-chat, export UIs; no CI/CD; no backend changes unless OpenAPI/multipart blocker filed
- [ ] 11.9 **TDD / stack gate:** Freezed + Riverpod; `flutter test` green for core entity/network additions + `document_scan` suites
- [ ] 11.10 Final review vs `openspec/specs/document-scan/spec.md` + architecture §2.1–§2.3; fix remaining gaps; commit “frontend document-scan STEP 3.7 slice DoD met”

---

## Definition of Done (STEP 3.7 — document-scan)

- [ ] `DocumentInputSource` unified camera + file upload with crop/edge-detect (or documented MVP crop) — covered by tests
- [ ] Upload via typed `ApiClient.createDocument` matching backend create/upload/enqueue flow
- [ ] `features/document_scan/` clean architecture + barrel
- [ ] Shared `Document` in `core/entities`
- [ ] Library UI with `LexivoDocumentCard` + status badges + polling
- [ ] Reviewer gates 11.1–11.10 passed
- [ ] Out of scope preserved (OCR/summary/later features, no client storage SDK, no new DS atoms unless flagged)

---

## Coverage matrix (planner verification)

| Requirement (OpenSpec / architecture) | Plan section |
|---|---|
| Unified DocumentInputSource (camera + file, no UI fork) | §0.A, §3.A, §6, §9, §11.2 |
| Edge detect/crop when camera path supports (MVP crop OK) | §0.3, §3.4–3.5, §6, §11.2 |
| Create + StorageProvider upload server-side via API | §0.B, §3.B, §4, §11.3 |
| Library DocumentCard + status badges | §5, §7, §11.5 |
| Shared Document in core entities | §1, §11.4 |
| Clean architecture + barrel; no cross-feature imports | §2, §8, §11.6 |
| Lexivo* composition only | §6–§7, §11.7 |
| job_poller reuse for status | §5.3–5.4 |
| Auth prerequisite completed | Prerequisites (PASS review) |
| Out of scope: OCR/summary/later | Out of scope, §11.8 |

**DocumentInputSource covered:** **Yes** — dedicated §3.A + gates §11.2 + E2E §9.1–9.2.

**Task count:** **63** numbered TDD/gate tasks (0.1–11.10). Prerequisites (3) marked completed above and excluded. DoD summary list (7) is a roll-up of those gates, not extra work items.
