# Frontend RAG Chat STEP 3.7 Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | rag-chat (Flutter + thin chat API) + architecture §2.1–§2.3 / §5 |
| **Reviewer** | Reviewer Agent (independent) |
| **Date** | 2026-08-04 |
| **Sources** | `openspec/specs/rag-chat/spec.md`, `spec/architecture.md` §2.1–§2.3 / §5, `openspec/plans/frontend-rag-chat-tasks.md` §11, prior `openspec/reviews/frontend-translation-step37-review.md` |
| **Claimed** | chat APIs + `features/rag_chat`; commits `b610625`…; §11 open |
| **Verdict** | **PASS** |

---

## Verdict

**PASS** — STEP 3.7 rag-chat slice Definition of Done is met. Plan gates 11.1–11.11 all pass. Independent runs: backend **291 passed** (1 skipped); `flutter test` **341 passed**. No findings that block DoD or pdf_export follow-on.

**Is STEP 3.7 rag-chat DoD met?** **Yes.**

**May pdf_export feature proceed?** **Yes.** Use named routes + core `Document` (and chat message identity only if/when promoted); do not import `features/rag_chat` (or translation / summarization / ocr / document_scan) internals.

---

## Gate-by-gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Prerequisite — translation STEP 3.7 still PASS; no auth/core/document_scan/ocr/summarization/translation regression | **PASS** |
| 11.2 | Backend Master — `run_master("ask"\|"rag_chat")` only; not-ready 409; persist; ungrounded | **PASS** |
| 11.3 | Persistence / sync — create + list resume | **PASS** |
| 11.4 | Async UI — AsyncValueView + Lexivo*; no JobPoller for ask | **PASS** |
| 11.5 | Shared entity — core Document identity; barrel does not force rag_chat internals | **PASS** |
| 11.6 | Navigation — translation → chat via named routes only; no cross-feature widget/data imports | **PASS** |
| 11.7 | Clean architecture — §2.1 tree + barrel-only outside; no Dio in feature; typed `ApiClient` | **PASS** |
| 11.8 | UI composition — LexivoChatBubble + citation slot; Lexivo* only | **PASS** (soft notes) |
| 11.9 | Scope — no pdf_export UIs; no Search/Citation/RagPipeline reimplementation; thin backend only | **PASS** |
| 11.10 | TDD / stack — Freezed + Riverpod; flutter + backend tests green | **PASS** |
| 11.11 | Final vs OpenSpec rag-chat + architecture §2.1–§2.3 / §5 | **PASS** |
| — | pdf_export may proceed | **Yes** |

---

## Evidence

### 11.1 Prerequisite gate

- Translation STEP 3.7 review remains **PASS** (`openspec/reviews/frontend-translation-step37-review.md`); rag_chat was cleared to proceed.
- Independent full Flutter suite **341 passed** — includes auth, core, document_scan, ocr, summarization, translation, and rag_chat; no regression observed.
- Full backend pytest **291 passed**, 1 skipped — prior claim baseline was 272; net growth matches chat API + related coverage.

### 11.2 Backend Master gate

- Commits: `b610625` (thin chat API + persist), `a368b05` (message list ordering), covered by `backend/tests/test_chat_api.py` + coupling-style source guards in that module.
- Router `POST /api/v1/chats/{doc_id}/messages` → `ChatService.ask` only; `ConflictError` → **HTTP 409** when OCR `status != ready` or no ingested chunks; `ValidationError` (empty content) → **HTTP 422**.
- Ask path: `await run_master(ASK_INTENT, …)` with `ASK_INTENT = "ask"` (Master also accepts alias `rag_chat` via `ASK_INTENTS`); Search→Citation remains inside Master — service does not call specialists.
- Citations persisted on assistant `ChatMessage` (`citations` JSON); ungrounded / master failure shaped to `CANNOT_ANSWER` without inventing content.
- Source guards: `test_chat_service_module_enters_via_master_only` asserts router + service have **no** `SearchAgent` / `CitationAgent` / `RagPipeline` imports; service has `run_master`; router has none. DI in `deps.get_chat_service` injects a pipeline instance for Master — acceptable wiring, not a router/service specialist import.

### 11.3 Persistence / sync gate

- `POST /chats/{doc_id}` ensure is idempotent (`get_or_create`).
- `GET /chats/{doc_id}/messages` returns prior thread after ask (`test_api_list_messages_empty_then_resume`); Flutter `RagChatNotifier.build` ensure + load for resume on open.
- Ordering fix (`a368b05`) keeps user then assistant stable when timestamps collide.

### 11.4 Async UI gate

- `RagChatScreen` wraps `ragChatProvider` in `AsyncValueView`:
  - loading → `LexivoSkeleton` lines
  - error → `LexivoErrorBanner` via `AsyncValueView` (+ retry → refresh)
  - empty thread → `LexivoEmptyState`
  - send-in-flight → pending user bubble + `LexivoChatBubbleVariant.assistantStreaming` (no JobPoller)
  - send errors (409/422) → `LexivoErrorBanner` / snackbar without fabricating assistant
- Grep under `lib/features/rag_chat/`: **no** `JobPoller`, **no** feature-local poll `Timer`.

### 11.5 Shared entity gate

- Document identity via `core/entities` `Document` (id / status readiness); chat models stay feature-owned Freezed (`Chat`, `ChatMessage`, `Citation`) — plan explicitly defers promoting chat to core until pdf_export needs it.
- Barrel `rag_chat.dart` exports providers/screen/entities only; `rag_chat_barrel_test` + isolation pattern match prior features.

### 11.6 Navigation gate

- Translation CTA → `context.go(RouteGuards.documentChat(documentId))`; chat back → `documentTranslation`.
- Core route `/documents/:documentId/chat` wired via `ragChatScreenBuildersProvider` override from barrel (`ragChatCoreOverrides`) — same pattern as OCR/summary/translation.
- No imports of translation/summarization/ocr/document_scan internals from `rag_chat`; other features do not import `rag_chat` internals (only `main.dart` barrel + route bridge).

### 11.7 Clean architecture gate

- Tree: `data/` (datasource, mappers, repository_impl) / `domain/` (entities, repository, usecases) / `presentation/` (providers, screen) + barrel.
- Datasource uses typed `ApiClient.createChat` / `listChatMessages` / `postChatMessage` only; **no** `package:dio` under `features/rag_chat`.
- Paths align with OpenAPI `/api/v1/chats/{doc_id}` and `/messages`.

### 11.8 UI composition gate

- Answers render via `LexivoChatBubble` with `citationChips` slot filled from message citations.
- Compose also uses `LexivoTextField`, `LexivoButton`, `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoSnackbar`, tokens.
- Soft notes (non-blocking, same class as prior STEP 3.7 reviews):
  1. `IconButton` back affordance (not a Lexivo* control).
  2. Material `Chip` widgets inside the citation slot — slot is documented as generic widgets; DS has no dedicated Lexivo citation chip yet.

### 11.9 Scope gate

- No `features/pdf_export` module or export CTAs in chat UI.
- No Search/Citation/RagPipeline reimplementation in Flutter or thin ChatService (Master-only ask).
- Backend limited to models/migration, schemas, ChatService, chats router, OpenAPI — no agent rewrite.

### 11.10 TDD / stack gate

- Freezed entities + Riverpod `AsyncNotifierProvider.family`.
- Independent: `pytest` **291 passed**, 1 skipped; `flutter test` **341 passed** (includes rag_chat suite + prior features).
- Chat-focused backend: `tests/test_chat_api.py` green as part of full suite.

### 11.11 Final vs OpenSpec + architecture

| OpenSpec / architecture requirement | Met? |
|---|---|
| Ask → answer + citations | Yes |
| Empty / ungrounded → cannot-answer | Yes |
| Chat persistence + resume | Yes |
| Search then Citation via Master only | Yes |
| Citation chips via ChatBubble slot | Yes |
| Typed client; `/chats/{doc_id}/messages` | Yes |
| Core Document identity; no cross-feature imports | Yes |
| Architecture §5 ChatService → ask (no double RagPipeline.query in service) | Yes |
| Out of scope: pdf_export / agent rewrite | Yes |

Optional “frontend rag-chat STEP 3.7 slice DoD met” commit and plan §11 checkbox roll-up remain for planner after this PASS (reviewer does not edit plan or commit).

---

## Soft notes (non-blocking)

1. `IconButton` back affordance — see §11.8; not a gate fail.
2. Material `Chip` in citation slot — see §11.8; slot contract allows generic widgets; optional future Lexivo citation chip.
3. Plan §11 checkboxes / DoD roll-up and optional “slice DoD met” commit remain for planner after this PASS.

---

## Follow-on

| Item | Guidance |
|---|---|
| **pdf_export may proceed** | **Yes** — use named routes + core Document; do not import `features/rag_chat` internals unless a later plan promotes shared chat types |
| Plan §11 checkboxes / DoD roll-up | May be marked complete by planner after this PASS |
| Promote `ChatMessage` to `core/entities` | Deferred per plan until pdf_export (or another feature) needs it |

---

## Commits reviewed (claimed range)

| Commit | Summary |
|---|---|
| `b610625` | Thin chat API with Master ask and message persistence |
| `0317a41` | Extend ApiClient DTOs and fixtures for chat create/list/ask |
| `a77eb3d` | Add features/rag_chat with LexivoChatBubble UI and chat route |
| `a368b05` | Fix chat message list ordering when timestamps collide |
