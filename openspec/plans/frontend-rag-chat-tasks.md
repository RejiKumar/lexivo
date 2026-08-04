# Frontend RAG Chat — Task Plan
Capability: **rag-chat** (Flutter + thin backend chat API → `ChatService.ask` → Master `ask`/`rag_chat` Search→Citation)
Architecture: `spec/architecture.md` §2.1–§2.3 (feature-first clean architecture; `core/`; shared `Document` in `core/entities`; no cross-feature imports) + §5 ask-the-document data flow
OpenSpec: `openspec/specs/rag-chat/spec.md`
UI: compose **ONLY** from `core/design_system` (`Lexivo*` — especially `LexivoChatBubble` with `citationChips` slot, `LexivoTextField`, `LexivoButton`, `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoSnackbar`). Message-list load via shared `AsyncValueView`. Any new visual atom → Design System Agent first — never inline one-offs.
Product: Lexivo
Execution order: **STEP 3.7 next feature** after translation PASS

**Prerequisite (completed)**
- [x] STEP 3.7 translation DoD **PASS** (`openspec/reviews/frontend-translation-step37-review.md`) — rag_chat may proceed; use named routes + core `Document` (incl. translation fields already present); **do not** import `features/translation` (or `summarization` / `ocr` / `document_scan`) internals
- [x] Design-system DoD **PASS** — `LexivoChatBubble` (+ `citationChips` slot), `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoButton`, `LexivoTextField` available
- [x] RAG pipeline STEP 3.5 **PASS** — `RagPipeline` / `HybridRetriever` / `document_chunks` ready for Search
- [x] Specialized agents STEP 3.6 — Master intents `ask` / `rag_chat` run Search→Citation; Search uses `RagPipeline.query`; Citation shapes answer + citations — **HTTP ChatService + messages CRUD still missing** (see §0)

**Out of scope for this file (later plans)**
- pdf_export (and export section toggles UI), notifications, subscription features
- Reimplementing Search/Citation agents, `RagPipeline`, LLMProvider, Master graph, or prompts
- Client-side LLM / vendor SDKs / vector DB SDKs
- Streaming token UI beyond `LexivoChatBubbleVariant.assistantStreaming` as a **sending/loading** affordance (full SSE/WebSocket stream out of scope)
- Offline Drift sync for chats; CI/CD; Cloud Run
- New design-system atoms unless a gap is flagged below for Design System Agent
- Promoting `ChatMessage` to `core/entities` (defer until pdf_export or another feature needs it)

**Product defaults (resolved)**

| Concern | Choice |
|---|---|
| Feature home | `lib/features/rag_chat/` — per-document chat thread + ask composer |
| Shared identity | Core Freezed `Document` for document id / title / OCR `status` readiness; never import other features’ data/presentation |
| Chat domain models | Feature-owned `Chat` / `ChatMessage` (+ citation view models) under `features/rag_chat/domain` — not on `Document` |
| Backend gap | **Include thin chat API** — no chats/messages routes, models, or `ChatService` today; land before Flutter typed client |
| Orchestration | Thin `ChatService.ask` calls **only** `run_master("ask"` or `"rag_chat", …)` — Search→Citation inside Master (Search already uses `RagPipeline`). **Do not** call `RagPipeline.query` again in `ChatService` (avoids double retrieval). No `SearchAgent` / `CitationAgent` / `RagPipeline` imports in router/service/task |
| Intent key | Prefer `ask` (alias `rag_chat` accepted by Master `ASK_INTENTS`) — document choice in service/OpenAPI notes |
| Trigger | `POST /api/v1/chats/{doc_id}/messages` (auth) body `{ content }` (question text) → ask + persist user + assistant messages; returns assistant message with citations |
| Create / ensure chat | `POST /api/v1/chats/{doc_id}` get-or-create chat for (user, document); idempotent |
| Resume / sync | `GET /api/v1/chats/{doc_id}/messages` → ordered messages (user + assistant) with citation payloads — same user across devices |
| Persist | ORM `chats` + `chat_messages` (role, content, citations JSON, timestamps); FK document + owner |
| Citations shape | List of `{ chunk_id` and/or `index`, `snippet`, optional `page`/`label` }` aligned to Citation Agent `data.citations` |
| Ready gate | Document OCR `status == ready` **and** at least one `document_chunks` row (ingested); else **409** with clear not-ready / not-ingested `detail` |
| Empty question | **422** validation |
| Ungrounded | Master/Citation cannot-answer path → persist assistant message that refuses invention; **200** with that content (not 5xx) |
| Async shape | **Synchronous HTTP ask** (architecture §5) — POST waits for Master result; **no** Celery/`JobPoller` for v1 ask. Message-list fetch is a normal AsyncValue load |
| Sending UX | Optimistic user bubble + `LexivoChatBubble` `assistantStreaming` (or skeleton) while POST in flight; replace with assistant + citation chips on success |
| Empty thread UX | `LexivoEmptyState` when no messages yet |
| Failed UX | `LexivoErrorBanner` / `LexivoSnackbar` on send failure; retry re-POSTs same content |
| Navigation | Named GoRouter: `/documents/:documentId/chat` (`RouteGuards.documentChat`). Translation / summary / OCR / library navigate via route constants only |
| State | Riverpod (current pin ^2.6.1; prefer 3 when pins allow) |
| Models | Freezed (+ json_serializable only for network DTOs) |
| HTTP | Typed `ApiClient` only — no `Dio(` / `package:dio` inside `features/rag_chat/` |
| UI bubble | **Must** use `LexivoChatBubble`; citations only via `citationChips` slot (generic widgets — e.g. Material `Chip` / `LexivoBadge` labels). No feature-local bubble atom |

**Conventions**
- Loop per chunk: failing test → implement → (widget test where UI) → review vs OpenSpec rag-chat + architecture §2.1–§2.3 / §5 + Lexivo* composition → fix → commit.
- Prefer small sequential commits; never one giant “frontend-rag-chat” commit.
- Feature public surface = barrel `features/rag_chat/rag_chat.dart` only.
- Screens: layout + `Lexivo*` + `AsyncValueView` only. Grep guard: no ad-hoc chat bubble clones.
- All HTTP via `core/network` `ApiClient`.
- Prefixes: package `lexivo`; UI `Lexivo*`; never `Nexora*`.
- Do **not** import `features/translation/**`, `features/summarization/**`, `features/ocr/**`, `features/document_scan/**`, or any other feature internals. Cross-feature wiring = named routes + injected screen builders only.
- Thin CTA from translation (and/or summary / OCR / library): `context.go` chat route by id — still no `features/rag_chat/...` imports inside those features beyond route constants in `core/routing`.

**Design-system gap flag**
- Expected composition: chat screen = `AsyncValueView` for thread load + list of `LexivoChatBubble` (user / assistant / streaming) + `citationChips` slot filled with layout + existing Chip/`LexivoBadge` (no rag models inside DS) + `LexivoTextField` composer + send `LexivoButton`.
- If a true visual gap appears (e.g. dedicated `LexivoCitationChip` that cannot be Chip/`LexivoBadge` + tokens), **stop and flag Design System Agent** — do not invent feature-local atoms.

**Shared test fixtures (Test Agent ownership)**

| Location | Owns |
|---|---|
| `test/fixtures/chats/` (or `documents/`) | JSON: empty thread, thread with citations, ungrounded assistant, 409 not-ready / not-ingested, 422 empty content |
| `test/helpers/` | `FakeRagChatRepository`, `MockApiClient` chat create/list/post stubs |
| `test/core/network/` | `createChat` / `listChatMessages` / `postChatMessage` DTO + ErrorMapper (409/422) tests |
| `test/features/rag_chat/` | Domain/data/presentation/flow tests (use helpers; no duplicate fakes) |
| `backend/tests/` | Thin ChatService/router: not-ready, empty content, `run_master` only, persist messages + citations, ungrounded path, resume list |

---

## 0. Backend thin API — ChatService + messages CRUD + Master ask (MISSING today)

OpenAPI / routers currently expose documents + summary + translation. **No** `chats` / `chat_messages` models, **no** `ChatService`, **no** ask HTTP path. Master `ask`/`rag_chat` is callable only in agent tests — **blocks Flutter**.

### 0.A Model + schemas + OpenAPI

- [x] 0.1 **Decision gate:** document in this plan / `docs/api_client.md`: get-or-create `POST /api/v1/chats/{doc_id}`; list `GET /api/v1/chats/{doc_id}/messages`; ask `POST /api/v1/chats/{doc_id}/messages` body `{ content }`; readiness = OCR `ready` + ingested chunks; citations array on assistant messages; Master intent `ask` (alias `rag_chat`)
- [x] 0.2 Add ORM models: `Chat` (id, user_id, document_id, unique per user+document, timestamps); `ChatMessage` (id, chat_id, role `user`\|`assistant`, content Text, citations JSON nullable, created_at) — migration or create_all-compatible for tests
- [x] 0.3 Add Pydantic schemas + OpenAPI snapshot paths: `ChatResponse`, `ChatMessageResponse` (incl. citations), `ChatMessageCreate` (`content`), list envelope; refresh `openapi/lexivo.openapi.json`
- [x] 0.4 Write failing backend tests for schema/serialization of chat + message + citations

### 0.B Thin ChatService (Master only)

- [x] 0.5 Write failing tests: ensure_chat / ask rejects when document missing, wrong owner, `status != ready`, or no `document_chunks` → not-ready error (HTTP 409 at router); empty/whitespace `content` → validation (HTTP 422)
- [x] 0.6 Write failing tests: success path persists user message then calls `run_master("ask"| "rag_chat", input={question, document_id, …})` with LLM (+ RAG deps as Master factory expects); on success persists assistant `content` + `citations` from `AgentResult.data`; returns assistant message
- [x] 0.7 Write failing tests: empty/ungrounded Master result → assistant message with cannot-answer copy (no invented claims); still persisted; no 5xx
- [x] 0.8 Assert service/router/task source: **has** `run_master`; **no** `SearchAgent` / `CitationAgent` / `search_agent` / `citation_agent` / `RagPipeline` imports (extend coupling test)
- [x] 0.9 Implement thin `ChatService` (+ repository helpers) — status/readiness checks at service layer; do not mutate OCR/summary/translation fields
- [x] 0.10 Review vs OpenSpec “Ask the document” + “Search and Citation agents” + architecture §5 (Master entry, not double-query); fix; commit backend service slice

### 0.C Router endpoints

- [x] 0.11 Write failing API tests: `POST /api/v1/chats/{doc_id}` auth + ownership; get-or-create idempotent
- [x] 0.12 Write failing API tests: `GET .../messages` returns prior messages for resume; empty list for new chat
- [x] 0.13 Write failing API tests: `POST .../messages` 200 with assistant + citations; 409 not-ready; 422 empty content; ungrounded cannot-answer body
- [x] 0.14 Implement thin chats router — call `ChatService` only; no agent / pipeline imports
- [x] 0.15 Refresh OpenAPI snapshot; commit

---

## 1. Typed client + fixtures (Flutter)

- [x] 1.1 Write failing `ApiClient` / DTO unit tests: `createChat` / `listChatMessages` / `postChatMessage`; parse role, content, citations list
- [x] 1.2 Write failing tests: HTTP 409 not-ready maps to `ValidationFailure` (or dedicated); HTTP 422 empty content maps to `ValidationFailure`; extend `ErrorMapper` if needed
- [x] 1.3 Add Freezed DTOs (`ChatDto`, `ChatMessageDto`, `CitationDto`, create body) aligned to OpenAPI
- [x] 1.4 Implement `ApiClient.createChat` / `listChatMessages` / `postChatMessage`; update `docs/api_client.md` (`TODO(openapi-codegen)` note)
- [x] 1.5 Add/update fixtures under `test/fixtures/chats/` (or documents)
- [x] 1.6 Review vs OpenSpec “Generated client and module boundaries”; fix; commit

---

## 2. Core shared entity — `Document` identity only

Architecture §2.3: rag_chat depends on core `Document`, not other features. Chat/message entities stay feature-owned for this slice.

- [x] 2.1 Write failing unit tests (if gaps): feature readiness helpers / mappers use core `Document.status` (and id/title); no new Document fields required unless OpenAPI forces a chat pointer (prefer none)
- [x] 2.2 Confirm `lib/core/entities/document.dart` unchanged **or** only additive if a documented chat metadata field is required — do not break translation/summary/OCR fields
- [x] 2.3 Update any broken constructors/tests if Document touched; suite stays green
- [x] 2.4 Review vs architecture §2.3; fix; commit

---

## 3. Feature scaffold (§2.1)

- [x] 3.1 Create `lib/features/rag_chat/` tree: `data/{datasources,repositories,models}/`, `domain/{entities,repositories,usecases}/`, `presentation/{screens,widgets,providers}/`, barrel `rag_chat.dart`
- [x] 3.2 Write failing barrel smoke: exports public chat screen builder / providers needed by router — **not** data-layer types
- [x] 3.3 Review vs architecture §2.1 folder contract; fix; commit scaffold

---

## 4. Domain — repository + usecases

- [x] 4.1 Define abstract `RagChatRepository` (name flexible): `ensureChat(docId)`, `listMessages(docId)`, `sendMessage(docId, content)` → `Result` + feature `ChatMessage` / list — document id as `String` or core `Document`; **no** other feature types
- [x] 4.2 Freezed domain `ChatMessage` + `Citation` (chunk id/index, snippet, label) — feature domain only
- [x] 4.3 Write failing usecase tests (fake repo): `LoadChatMessages`, `SendChatMessage`, `EnsureChat`; success/failure/not-ready/empty-content `Result` shapes
- [x] 4.4 Write failing tests: ungrounded assistant message still success `Result` with cannot-answer content; citations optional empty
- [x] 4.5 Implement usecases — each single `call()`, returns `Result`
- [x] 4.6 Review vs OpenSpec ask + persistence + ungrounded; fix; commit

---

## 5. Data layer — remote + repository impl

- [x] 5.1 Write failing tests for `RagChatRemoteDatasource`: create / list / post via `ApiClient` only; DTO→domain mapping including citations; failures via `ErrorMapper`/`Result`
- [x] 5.2 Implement datasource + `RagChatRepositoryImpl`
- [x] 5.3 Riverpod providers for repository + usecases (override-friendly)
- [x] 5.4 Assert no `package:dio` and no `features/translation` / `summarization` / `ocr` / `document_scan` imports under `features/rag_chat/`; fix; commit

---

## 6. Presentation — providers (Riverpod)

- [x] 6.1 Write failing provider tests: open chat for doc → load messages → `AsyncValue` data (empty → empty list)
- [x] 6.2 Write failing tests: send message → user message appears; POST in flight → streaming/sending state; success → assistant + citations in thread
- [x] 6.3 Write failing tests: 409 not-ready → clear error **without** fabricating assistant answer; 422 empty → validation; send failure → error + retry
- [x] 6.4 Write failing tests: ungrounded assistant content shown as normal assistant bubble (no crash on empty citations)
- [x] 6.5 Implement notifier(s) (`ragChatProvider` family by document id, etc.) — **no** feature-local `JobPoller` for ask (sync POST)
- [x] 6.6 Review vs OpenSpec “Successful Q&A” + “Empty or ungrounded” + “Resume chat”; fix; commit

---

## 7. Presentation — chat screen (`LexivoChatBubble` + citation slot)

- [x] 7.1 Write failing widget tests for **RagChatScreen** (name flexible): loading → `AsyncValueView` / `LexivoSkeleton`; empty → `LexivoEmptyState`; messages → `LexivoChatBubble` user/assistant; failed load → `LexivoErrorBanner`
- [x] 7.2 Write failing tests: assistant with citations → `citationChips` slot non-null / chips visible; sending → `assistantStreaming` (or equivalent) visible; composer uses `LexivoTextField` + send control
- [x] 7.3 Implement screen composing Lexivo* + layout only; **no** pdf_export / subscription CTAs; citations only through bubble slot
- [x] 7.4 Grep guard: production rag_chat UI uses `LexivoChatBubble` (not a custom bubble class); fix; commit
- [x] 7.5 Review vs OpenSpec “Citation chips in UI” + Lexivo composition; fix; commit

---

## 8. Routing + navigation from translation / summary / OCR / library

- [x] 8.1 Write failing router tests: authenticated route `/documents/:documentId/chat`; unauthenticated → sign-in; named routes only
- [x] 8.2 Extend `RouteGuards` + `app_router` with chat route; inject builders from `rag_chat` barrel (mirror translation) — **no** importing `rag_chat/presentation` from other features’ data layers
- [x] 8.3 Wire translation screen and/or summary / OCR / library when appropriate: CTA → `context.go(RouteGuards.documentChat(id))` using **only** `core/routing` helpers
- [x] 8.4 Ensure translation / summarization / OCR / document_scan still have **zero** imports of `features/rag_chat/data` or internal widgets
- [x] 8.5 Review vs architecture §2.3 navigation contract; fix; commit

---

## 9. End-to-end feature flow (widget/integration-ish)

- [x] 9.1 Write failing flow test: navigate to chat (empty) → type question → send → assistant answer + citation chips from fixtures
- [x] 9.2 Write failing flow test: resume — list fixtures with prior messages → screen shows history without re-ask
- [x] 9.3 Write failing flow test: not-ready document → clear error; no successful grounded answer fabricated
- [x] 9.4 Write failing flow test: ungrounded / cannot-answer assistant message rendered; send failure → banner/snackbar + retry
- [x] 9.5 Wire providers in app bootstrap overrides alongside prior features; bearer token still injected; review full OpenSpec rag-chat **client** scenarios; fix; commit

---

## 10. Shared fixtures hygiene (Test Agent)

- [x] 10.1 Add/extend `FakeRagChatRepository` + helpers under `test/helpers/`
- [x] 10.2 Add/update `test/fixtures/chats/*.json` for empty / cited / ungrounded / 409 / 422 envelopes
- [x] 10.3 Keep fixture map in this plan’s table updated; commit

---

## 11. Reviewer gate checkpoints (STEP 3.7 rag-chat slice)

Run after §§0–10 land; blockers must be fixed before declaring this slice done.

- [ ] 11.1 **Prerequisite gate:** translation STEP 3.7 review still PASS; no regression in auth/core/document_scan/ocr/summarization/translation suites
- [ ] 11.2 **Backend Master gate:** ask HTTP path enters only via `run_master("ask"|"rag_chat", …)`; no specialist / `RagPipeline` imports in router/service; not-ready rejected (409); messages + citations persisted; ungrounded cannot-answer path
- [ ] 11.3 **Persistence / sync gate:** create chat + list messages returns prior thread for same user/doc (resume)
- [ ] 11.4 **Async UI gate:** thread load via `AsyncValueView` + Lexivo*; send uses streaming/loading bubble — **no** feature-local JobPoller for v1 ask
- [ ] 11.5 **Shared entity gate:** uses `core/entities` `Document` for document identity; barrel does not force other features to import `rag_chat` internals
- [ ] 11.6 **Navigation gate:** translation/summary/OCR/library → chat via named routes only; no cross-feature widget/data imports
- [ ] 11.7 **Clean architecture gate:** §2.1 tree + barrel-only outside; no Dio inside feature; typed `ApiClient` only
- [ ] 11.8 **UI composition gate:** `LexivoChatBubble` + citation slot; Lexivo* only; any DS gap flagged, not inlined
- [ ] 11.9 **Scope gate:** no pdf_export UIs; no Search/Citation/RagPipeline reimplementation; no CI/CD; backend limited to thin ChatService/router + persist/OpenAPI
- [ ] 11.10 **TDD / stack gate:** Freezed + Riverpod; `flutter test` green for core + rag_chat (+ prior features); backend chat API tests green
- [ ] 11.11 Final review vs `openspec/specs/rag-chat/spec.md` + architecture §2.1–§2.3 / §5; fix remaining gaps; commit “frontend rag-chat STEP 3.7 slice DoD met”

---

## Definition of Done (STEP 3.7 — rag-chat)

- [ ] Thin backend chat API: ensure chat + list messages + POST ask via `run_master("ask"|"rag_chat")` only; persist messages with citations; not-ready when OCR incomplete / not ingested; ungrounded cannot-answer
- [ ] `features/rag_chat/` clean architecture + barrel; typed API client only
- [ ] Chat UI with `LexivoChatBubble` + citation chips slot; empty / loading / error / send-in-flight via Lexivo* + `AsyncValueView`
- [ ] Navigate from translation (and/or summary/OCR/library) via named routes only
- [ ] Shared `Document` in `core/entities` for identity; no cross-feature imports
- [ ] Reviewer gates 11.1–11.11 passed
- [ ] Out of scope preserved (pdf_export and later; no agent/pipeline rewrite)

---

## Coverage matrix (planner verification)

| Requirement (OpenSpec / architecture) | Plan section |
|---|---|
| Ask the document → answer + citations | §0.6–0.7, §0.13, §4–7, §9.1, §11.2 |
| Empty / ungrounded → cannot-answer (no invention) | §0.7, §0.13, §4.4, §6.4, §9.4, §11.2 |
| Chat persistence + cross-device resume | §0.2, §0.11–0.12, §6.1, §9.2, §11.3 |
| Search then Citation via Master only | §0.6–0.8, §11.2 |
| Citation chips via ChatBubble slot | §7, §9.1, §11.8 |
| Typed client exclusively; path `/chats/{doc_id}/messages` | §0.1, §1, §5, §11.7 |
| Core Document identity; no cross-feature imports | §2, §5.4, §8, §11.5–11.6 |
| Architecture §5 ChatService → ask flow | §0 (Master-only entry; no double RagPipeline.query) |
| Translation prerequisite completed | Prerequisites (PASS review) |
| Out of scope: pdf_export / later; no agent rewrite | Out of scope, §11.9 |

**Client OpenSpec scenarios covered:** **Yes** — successful Q&A, ungrounded refusal, resume chat, citation chips, typed client + core Document.

**Backend API tasks included:** **Yes** — dedicated §0 (models/persist + ChatService + routers) because chat endpoints and `ChatService` are missing from current OpenAPI/routers.

**Task count:** **73** numbered TDD/gate tasks (0.1–0.15, 1.1–11.11). Prerequisites (4) marked completed above and excluded. DoD summary list (7) is a roll-up of those gates, not extra work items.

---

## Reviewer

*(Leave blank for Reviewer Agent — fill after implementation.)*

| Field | Value |
|---|---|
| **Capability** | rag-chat (Flutter + thin chat API) |
| **Reviewer** | |
| **Date** | |
| **Sources** | `openspec/specs/rag-chat/spec.md`, `spec/architecture.md` §2.1–§2.3 / §5, this plan §11, `openspec/reviews/frontend-translation-step37-review.md` |
| **Verdict** | |

### Gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Prerequisite — translation STEP 3.7 still PASS | |
| 11.2 | Backend Master — `run_master("ask"\|"rag_chat")` only; not-ready; persist; ungrounded | |
| 11.3 | Persistence / sync — create + list resume | |
| 11.4 | Async UI — AsyncValueView + Lexivo*; no JobPoller for ask | |
| 11.5 | Shared entity — core Document identity | |
| 11.6 | Navigation — named routes only | |
| 11.7 | Clean architecture — §2.1 + typed client | |
| 11.8 | UI composition — LexivoChatBubble + citation slot | |
| 11.9 | Scope — no pdf_export/later; thin backend only | |
| 11.10 | TDD / stack — flutter + backend tests green | |
| 11.11 | Final vs OpenSpec + architecture | |

### Notes

-
