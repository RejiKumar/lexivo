# Frontend Document Scan STEP 3.7 Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | document-scan (Flutter) + architecture §2.1–§2.3 |
| **Reviewer** | Reviewer Agent (independent) |
| **Date** | 2026-08-04 |
| **Sources** | `openspec/specs/document-scan/spec.md`, `spec/architecture.md` §2.1–§2.3, `openspec/plans/frontend-document-scan-tasks.md` §11, `docs/document_input_source.md`, prior `openspec/reviews/frontend-auth-step37-review.md` |
| **Claimed** | Multipart create; `DocumentInputSource` camera+file+MVP crop; library/scan screens; 223 flutter tests; §11 open |
| **Verdict** | **PASS** |

---

## Verdict

**PASS** — STEP 3.7 document-scan slice Definition of Done is met. Plan gates 11.1–11.10 all pass. MVP interactive crop (`image_cropper`) is accepted with note (plan Product defaults / §0.3 / §11.2 explicitly allow it in place of full ML edge-detect). Independent `flutter test`: **223 passed**.

**Is STEP 3.7 document-scan DoD met?** **Yes.**

**May OCR result view (`ocr` capability / next frontend feature) proceed?** **Yes.** Shared `Document` in `core/entities` unblocks cross-feature identity without importing `document_scan` internals.

---

## Gate-by-gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Prerequisite — auth STEP 3.7 still PASS; no auth/core regression | **PASS** |
| 11.2 | DocumentInputSource — one abstraction; camera + crop (MVP OK); file fallback; zero screen platform forks | **PASS** (MVP crop note) |
| 11.3 | Upload / Storage — `ApiClient.createDocument` multipart only; no client StorageProvider/R2 SDK | **PASS** |
| 11.4 | Shared entity — `Document` in `core/entities`; barrel does not force internals on other features | **PASS** |
| 11.5 | Library / card — `LexivoDocumentCard` + status badges; empty/loading/error via Lexivo* / `AsyncValueView` | **PASS** |
| 11.6 | Clean architecture — §2.1 tree + barrel-only outside; no cross-feature data imports; no Dio in feature | **PASS** |
| 11.7 | UI composition — Lexivo* only; no inlined DS atoms | **PASS** |
| 11.8 | Scope — no OCR/summary/rag/export UIs; no CI/CD; no backend scope creep | **PASS** |
| 11.9 | TDD / stack — Freezed + Riverpod; `flutter test` green | **PASS** (223) |
| 11.10 | Final vs OpenSpec document-scan + architecture §2.1–§2.3 | **PASS** |
| — | MVP crop vs full edge-detect | **PASS with note** |
| — | OCR result view may proceed | **Yes** |

---

## Evidence

### 11.1 Prerequisite gate

- Auth review remains **PASS** (`openspec/reviews/frontend-auth-step37-review.md`).
- Full suite includes auth + core + document_scan; independent run **223 passed**, no auth/core regressions observed.

### 11.2 DocumentInputSource gate

- Domain contract: `DocumentInputSource` + `captureOrPick(preference:)` + `DocumentBytes` / `DocumentInputPreference` in `lib/features/document_scan/domain/entities/document_input.dart`.
- Impl: `DocumentInputSourceImpl` orchestrates `CameraGateway` / `FilePickerGateway` / `DocumentCropper`; `auto` probes camera then file — **no screen-level branching**.
- Screens (`DocumentScanScreen`, `DocumentLibraryScreen`): grep — **no** `kIsWeb`, `Platform.`, or plugin imports; single CTA invokes controller with `DocumentInputPreference.auto`.
- Camera + unavailable paths covered by domain tests, flow tests (`cameraAvailable: true|false`), and fakes under `test/helpers/`.
- Decision recorded: `docs/document_input_source.md` + code comments on cropper.

**MVP crop (PASS with note):** Crop is `image_cropper` interactive crop (`ImageCropperDocumentCropper`), not ML document edge-detect. Plan Product defaults, §0.3, Out of scope, and §11.2 explicitly allow “documented MVP interactive crop.” Packages + policy documented. Evaluate as **PASS with note**, not REJECT.

**Soft follow-up (non-blocking):** `ImagePickerCameraGateway.isAvailable` defaults to `true` without a real permission/capability probe. Denied/failed capture after `auto` surfaces `Failure` rather than silently switching to file. Abstraction + fake/unavailable tests still satisfy the OpenSpec “same API” contract; tighten the production probe later.

### 11.3 Upload / Storage gate

- Feature upload path: `DocumentRemoteDatasource.createWithUpload` → `ApiClient.createDocument(bytes, filename, title?)` multipart `file` (+ optional `title`).
- No `package:dio`, no StorageProvider / R2 / cloud SDKs under `lib/features/document_scan/`.
- Multipart + ErrorMapper covered in `test/core/network/api_client_test.dart`; fixtures under `test/fixtures/documents/`.

### 11.4 Shared entity gate

- Freezed `Document` + `DocumentStatus` in `lib/core/entities/document.dart` (+ mapper); entity tests in `test/core/entities/document_test.dart`.
- Feature barrel exports input contract + screens/providers — not data-layer types. Other features can depend on `core/entities` only (architecture §2.3).

### 11.5 Library / card gate

- `DocumentLibraryScreen`: `AsyncValueView` + empty `LexivoEmptyState` + list of `LexivoDocumentCard` with `toLexivoDocumentStatus` mapping (processing / ready / failed).
- Status poll: `DocumentScanController` + core `JobPoller` + `getDocumentStatus` updates library badges; covered by provider + flow tests.
- Thumbnail optional on card; library omits it — allowed by plan (“optional thumbnail”).

### 11.6 Clean architecture gate

- Tree present: `data/{datasources,repositories,input,models}/`, `domain/{entities,repositories,usecases}/`, `presentation/{screens,providers,widgets}/`, barrel `document_scan.dart`.
- Outside feature: `main.dart` imports barrel only; auth navigates via `RouteGuards.documents` (no document_scan widget/data imports).
- No cross-feature `features/*/data` imports from document_scan; no Dio inside feature.

### 11.7 UI composition gate

- Scan: `LexivoButton`, `LexivoErrorBanner`, `LexivoSnackbar`, tokens.
- Library: `LexivoDocumentCard`, `LexivoEmptyState`, `LexivoButton`, `AsyncValueView` (LexivoSkeleton / LexivoErrorBanner).
- No feature-local interactive atoms; crop chrome is plugin-owned behind `DocumentCropper` (allowed MVP). Widget tests assert no `ElevatedButton`.

### 11.8 Scope gate

- No OCR result / summarization / rag-chat / pdf-export / subscription feature UIs.
- No CI/CD or backend service changes required for this slice beyond typed client multipart already in core network.

### 11.9 TDD / stack gate

| Claim | Actual | Decision |
|---|---|---|
| Freezed models | `Document`, `DocumentBytes`, API DTOs | **PASS** |
| Riverpod | `flutter_riverpod: ^2.6.1` (same pin as auth) | **PASS** |
| `flutter test` | **223 passed** (independent run) | **PASS** |

### 11.10 Final / OpenSpec + architecture

| OpenSpec document-scan requirement | Status |
|---|---|
| Unified DocumentInputSource; no UI platform fork | **PASS** |
| Camera path with edge-detect/crop | **PASS** (MVP crop; plan-allowed) |
| Camera unavailable → file via same abstraction | **PASS** (impl + tests; probe soft note) |
| Create + server-side storage via API (no client SDK) | **PASS** |
| Library DocumentCard + status reflection | **PASS** |
| Shared Document in core entities | **PASS** |
| Architecture §2.1 feature tree + barrel | **PASS** |
| Architecture §2.3 no cross-feature entity coupling | **PASS** |

### Routing

- Named routes `/documents`, `/documents/scan` in `app_router` + `RouteGuards`.
- Builders injected via `documentScanCoreOverrides()` / `documentScreenBuildersProvider` (mirror auth pattern).
- Unauthenticated → sign-in; covered by `document_router_test.dart`.

---

## MVP crop vs full edge-detect

| Aspect | Finding |
|---|---|
| Chosen approach | `image_cropper` interactive crop after camera (images); PDF skip; pass-through when no path / crop fails |
| Documented? | Yes — `docs/document_input_source.md`, plan §0, cropper class comment |
| Plan allows MVP? | **Yes** |
| Reviewer decision | **PASS with note** — do not block DoD or OCR follow-on for lack of ML edge-detect |

---

## Soft notes (non-blocking)

1. Production `CameraGateway.isAvailable` default-true probe — improve permission/capability check so `auto` prefers file when camera truly unavailable/denied.
2. Screen widget test’s `kIsWeb` assertion is a no-op tautology; static absence of forks is verified by this review (and screen source).
3. Empty `data/models/` and `presentation/widgets/` folders are scaffold placeholders — fine for this slice.

---

## Proceed decision

| Next work | Allowed? |
|---|---|
| OCR result view feature (OpenSpec `ocr`) | **Yes** — depends on core `Document`, not document_scan internals |
| Plan §11 checkboxes / DoD roll-up | May be marked complete by planner after this PASS |
| Full ML edge-detect | Deferred enhancement; not a STEP 3.7 blocker |
