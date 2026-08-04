# AI Document Assistant — Product & Technical Specification (spec.md)

> **Status:** Draft v1.0
> **Purpose:** This is the first deliverable in the spec-driven development workflow. It is meant to be attached to Cursor (or any AI coding agent) as the source of truth before any code generation begins. Follow-on documents (`architecture.md`, `ui_design_system.md`, `database.md`, `api_contract.md`, `agent_architecture.md`, `rag_design.md`, `security.md`, `testing_strategy.md`, `deployment.md`) will each expand a section of this file in depth.
>
> **Core design principle for this entire project: everything is a reusable component.** No screen, agent, API route, or widget should be built as a one-off. Every UI element lives in a shared design system; every AI capability lives behind a shared agent interface; every backend concern lives in a shared, swappable service module. This principle is referenced throughout this document and must be enforced in every subsequent spec and every pull request.

---

## 1. Product Overview

**Product name:** Lexivo

**One-line pitch:** An AI-native document assistant that lets users scan, understand, translate, and interrogate any document — on mobile or web — through a fast, agent-powered RAG pipeline.

**Target platforms:** Android, iOS, Web (single Flutter codebase). Desktop (Windows) is a future phase, not part of v1.

**Primary user:** Students, professionals, and small businesses who deal with paperwork, contracts, receipts, research papers, or reports and want fast answers without reading the whole document.

**Non-goals for v1:**
- No team/multi-user collaboration (future phase)
- No handwriting-specific OCR tuning (future phase)
- No offline LLM inference (offline mode is limited to local caching/queueing, not on-device generation)
- Not building the "super app" (Productivity Hub) yet — this app is deliberately scoped to one strong vertical, architected so a super app can be assembled later from the same reusable components.

---

## 2. Core Features (v1 scope)

| # | Feature | Description |
|---|---------|-------------|
| 1 | Camera document scan | Capture a document via device camera with edge detection/crop |
| 2 | OCR text extraction | Convert scanned image/PDF into clean structured text |
| 3 | Document summarization | AI-generated short and detailed summaries |
| 4 | Translation | Translate extracted text into supported target languages |
| 5 | Ask-the-document (RAG chat) | Conversational Q&A grounded in the uploaded document via retrieval |
| 6 | Export to PDF | Re-export summary/translation/annotated content as a clean PDF |
| 7 | Cloud sync | Documents, chats, and summaries sync across devices |
| 8 | Auth & account | Sign up/sign in, session management, account settings |
| 9 | Notifications | Processing-complete and reminder notifications |
| 10 | Subscription/paywall (post-MVP toggle) | Usage limits and paid tier, built but feature-flagged off for launch if not ready |

Every feature above must be delivered as an independent, testable **capability module** (see §6 Agent Architecture) and an independent **feature-first Flutter module** (see §4 Frontend). No feature may directly reach into another feature's internals — they only communicate through defined contracts (state providers, API clients, agent interfaces).

---

## 3. High-Level Architecture

```
Flutter (Mobile + Web)
        │  REST (OpenAPI-typed client, generated, reusable)
        ▼
   FastAPI (Python)
        │
        ├── Auth layer (Clerk / Supabase Auth)
        ├── Core API (documents, chats, users, exports)
        ├── Queue producer (Celery tasks)
        │
        ▼
   PostgreSQL (+ pgvector)         Redis (cache + broker)
        │                                │
        ▼                                ▼
  Object Storage (Cloudflare R2)   Celery Workers
                                          │
                                          ▼
                                  Agent Orchestrator (LangGraph)
                                          │
        ┌─────────────┬─────────────┬────┴─────────┬─────────────┐
        ▼             ▼             ▼              ▼             ▼
   OCR Agent   Summary Agent  Translation    Search/RAG     Export/PDF
                              Agent          Agent          Agent
                                          │
                                          ▼
                                  Gemini / OpenAI APIs
```

**Guiding rule:** every box in this diagram must be replaceable without touching the boxes around it. E.g., swapping Gemini for OpenAI, or Clerk for Supabase Auth, should require changing one adapter, not the app.

---

## 4. Frontend Specification (Flutter)

### 4.1 Stack
- **Framework:** Flutter 3.x (latest stable at implementation time)
- **State management:** Riverpod 3
- **Routing:** GoRouter
- **Immutable models/codegen:** Freezed + json_serializable
- **Local/offline storage:** Drift
- **Networking:** Dio (with a single generated API client — see §7)
- **Responsive layout:** Responsive Framework
- **Design system:** Material 3, extended with a custom token-based theme (see §5)
- **Targets:** Android, iOS, Web (Windows later)

### 4.2 Architecture pattern
**Feature-first + Clean Architecture.** Each feature folder is self-contained and only exposes what it needs to via a public API (barrel file):

```
lib/
  core/                     # shared, reusable across ALL features
    design_system/          # reusable UI components (see §5)
    network/                # Dio client, interceptors, error mapping
    routing/                # GoRouter config
    theming/                # tokens, typography, spacing
    utils/
    widgets/                 # generic reusable widgets not tied to design system tokens directly (loaders, error states)
  features/
    auth/
      data/
      domain/
      presentation/
    document_scan/
    ocr/
    summarization/
    translation/
    rag_chat/
    pdf_export/
    notifications/
    subscription/
  main.dart
```

**Rule:** a feature may depend on `core/`, never on another feature's internals directly. Cross-feature communication happens through Riverpod providers exposed in a feature's `domain` layer, or through routes.

### 4.3 Reusability requirements (frontend)
- Every screen is composed from `core/design_system` components — no inline one-off buttons, cards, inputs, dialogs, etc.
- Any UI pattern used more than once (empty states, loading skeletons, error banners, confirmation sheets) must be extracted into `core/widgets` before a second screen uses it.
- All API calls go through a single generated, typed client (see §7) — no ad hoc `Dio.get()` calls inside feature code.
- Shared business logic (e.g., "poll job status until complete") must live in a reusable hook/provider in `core/`, not duplicated per feature.

---

## 5. UI/Design System

Full detail belongs in `ui_design_system.md`; this section defines the requirement at the spec level.

### 5.1 Visual direction
Inspired by (not copied from) Notion, Linear, Perplexity, Arc Browser, ChatGPT, Apple Notes. Characteristics:
- Minimal, generous whitespace
- Glass/blur effects used sparingly, not decoratively
- Smooth 60/120 FPS animations, no jank
- Consistent 8pt spacing scale
- Strong, restrained typography (1–2 font families max)
- Subtle micro-interactions (button press, success checkmarks, skeleton loaders)

### 5.2 Mandatory reusable component library
All UI must be built from this shared component set (owned by `core/design_system`), each with variants/props rather than one-off copies:

- Button (primary, secondary, ghost, destructive, loading state)
- Card (default, elevated, interactive/pressable)
- Input field (text, multiline, search, with validation states)
- Bottom sheet (generic, scrollable, action-sheet variant)
- Dialog / modal
- Navigation (bottom nav for mobile, side rail/nav for web/tablet)
- Typography scale (display, headline, title, body, caption — as reusable text style tokens, not hardcoded `TextStyle`)
- Spacing & color tokens (semantic tokens: `surface`, `onSurface`, `primary`, `danger`, etc., never raw hex codes in feature code)
- Radius & elevation tokens
- Animation/motion presets (standard durations/curves reused everywhere)
- Loading/skeleton states
- Empty states
- Error/retry banners
- Chat bubble component (for RAG chat, reusable for any future chat-like feature)
- File/document card (thumbnail, name, status badge — reusable across library, scan results, chat attachments)

**Rule:** before adding any new visual widget, check whether an existing design-system component can be extended with a new variant. New one-off widgets require explicit justification.

---

## 6. AI Agent Architecture

### 6.1 Framework
**LangGraph** (not LangChain) — chosen for built-in agent orchestration, memory, workflow graphs, checkpointing, retries, and human-approval steps.

### 6.2 Agent topology

```
Master Agent (orchestrator)
 ├── OCR Agent
 ├── Summary Agent
 ├── Translation Agent
 ├── PDF Agent
 ├── Search/RAG Agent
 ├── Citation Agent
 ├── Export Agent
 ├── Security Agent
 ├── Notification Agent
 └── Analytics Agent
```

### 6.3 Reusability requirements (agents)
- Every agent implements the **same base interface** (defined once, e.g. `BaseAgent` with `run(input) -> AgentResult`, standard error/retry contract, standard logging/tracing hooks). New agents are added by implementing this interface, never by copy-pasting another agent's plumbing.
- Each agent is **independent, testable, and replaceable** — no agent calls another agent directly; all coordination goes through the Master Agent/graph, so any single agent (e.g., swapping the Translation Agent's model) can change without touching others.
- Prompts are stored centrally in a `prompts/` directory as versioned templates, not inlined per agent — a shared prompt-loading utility is reused by every agent.
- Model access (Gemini/OpenAI) goes through one shared LLM client abstraction so agents don't hardcode a specific provider SDK.

### 6.4 RAG pipeline

```
Document → OCR → Chunking → Embeddings → pgvector → Retriever → Context Builder → LLM
```

- **OCR:** Google Document AI or Mistral OCR (avoid Tesseract unless offline OCR becomes a hard requirement)
- **Vector store:** pgvector inside PostgreSQL (no Pinecone/Chroma/Weaviate — one less moving part)
- **Search:** Hybrid search — pgvector similarity + BM25 keyword search, merged by a single reusable `HybridRetriever` service usable by any future feature needing document search (not just chat)
- **Chunking & embedding logic** lives in one reusable pipeline module, parameterized by document type, so scanned receipts, contracts, and research papers all pass through the same pipeline with different config, not different code paths

---

## 7. Backend Specification

### 7.1 Stack
- **API framework:** FastAPI (Python)
- **Database:** PostgreSQL + pgvector extension
- **ORM:** SQLAlchemy
- **Migrations:** Alembic
- **Cache/broker:** Redis
- **Background jobs:** Celery (OCR, embedding, translation, PDF generation, email, push notifications)
- **Object storage:** Cloudflare R2
- **Auth:** Clerk or Supabase Auth (not Firebase Auth)
- **API style:** REST first; GraphQL only if a real need emerges later

### 7.2 Reusability requirements (backend)
- **Service layer pattern:** every domain concept (documents, chats, exports, users) has a `service` module with a consistent shape (create/get/list/update/delete + domain-specific methods). Routers are thin and only call services — no business logic in route handlers.
- **One generated OpenAPI schema** is the single source of truth for the API contract; the Flutter client is code-generated from it so frontend and backend never drift, and no endpoint is hand-typed twice.
- **Adapters, not hardcoded SDKs:** storage (R2), auth (Clerk/Supabase), and LLM providers (Gemini/OpenAI) are each behind a small adapter interface, so switching providers is a config/adapter change, not a rewrite.
- **Celery tasks are composable units** — a task does one thing (e.g., `run_ocr`, `generate_embeddings`) and is chained/orchestrated by the agent graph, not duplicated per feature.

### 7.3 Database (high-level; full detail in `database.md`)
Core tables: `users`, `documents`, `document_chunks` (with `pgvector` embedding column), `chats`, `chat_messages`, `exports`, `subscriptions`, `notifications`, `jobs`.

---

## 8. CI/CD & Deployment

### 8.1 Pipeline

```
GitHub → Pull Request → Lint → Tests → Flutter Build → Backend Tests → Docker Build → Deploy → Release
```

GitHub Actions jobs:
- `flutter analyze`
- `flutter test` (unit + widget)
- Python tests (`pytest`)
- Docker build (backend)
- Flutter Web build & deploy
- Android APK/AAB build

### 8.2 Environments & hosting
- **Frontend:** Cloudflare Pages (Web); Play Store / App Store pipelines for mobile
- **Backend:** Railway or Google Cloud Run
- **Database:** Neon PostgreSQL
- **Observability:** Sentry, OpenTelemetry, Grafana, Prometheus
- **Analytics:** PostHog (not Firebase Analytics)

### 8.3 Reusability requirement
CI/CD workflows are written as **reusable GitHub Actions composite workflows** (e.g., a `lint.yml`, `test.yml`, `build.yml` that later feature-specific pipelines call), not copy-pasted per environment.

---

## 9. Testing Strategy (summary — full detail in `testing_strategy.md`)

```
Specification → Unit Test → Implementation → Widget Test → Integration Test → Golden Test → AI Review
```

- Target ~80–90% coverage on business logic (not chasing 100%)
- Shared test utilities/fixtures (mock API client, mock agent responses, test data factories) live in one reusable test-support module used by every feature's test suite
- Golden tests validate design-system components once at the component level, so every screen that reuses them inherits visual regression coverage for free

---

## 10. Security (summary — full detail in `security.md`)
- Auth via Clerk/Supabase, never rolling custom auth
- Signed, time-limited URLs for R2 object access
- PII/document content encrypted at rest
- Rate limiting and quota enforcement at the API gateway layer, implemented once and applied via middleware to all routes (not per-endpoint)

---

## 11. Development Workflow (Cursor / AI-agent driven)

Documents to be produced in order, each attachable to Cursor as context:
1. `spec.md` (this document)
2. `architecture.md`
3. `ui_design_system.md`
4. `database.md`
5. `api_contract.md`
6. `agent_architecture.md`
7. `rag_design.md`
8. `security.md`
9. `testing_strategy.md`
10. `deployment.md`

**Task granularity rule:** work is requested from Cursor in small, sequential tasks per feature (spec → unit test → implementation → widget test → review → fix → commit), never as one large "build the whole app" prompt. This keeps output quality high and keeps every generated piece consistent with the reusable-component rules in this document.

---

## 12. Definition of Done (v1 launch)
- [ ] Auth working end-to-end (sign up, sign in, session persistence)
- [ ] Document scan → OCR → summary → translation → chat pipeline working on mobile and web
- [ ] Export to PDF working
- [ ] Cloud sync across devices
- [ ] Notifications for job completion
- [ ] CI/CD pipeline green on main, auto-deploying web + backend
- [ ] Design system fully in place with no one-off widgets in feature code
- [ ] All agents implemented against the shared `BaseAgent` interface
- [ ] 80%+ test coverage on business logic
- [ ] Sentry + analytics wired up in production

---

## 13. Explicit Reusability Checklist (apply to every PR)
- [ ] Does this PR introduce any new UI widget not built from `core/design_system`?
- [ ] Does this PR duplicate an existing agent's plumbing instead of implementing `BaseAgent`?
- [ ] Does this PR call an LLM/storage/auth SDK directly instead of going through the shared adapter?
- [ ] Does this PR hand-write an API call instead of using the generated client?
- [ ] Is any prompt inlined in code instead of stored in the shared `prompts/` directory?

If the answer to any of the above is yes, the PR should be revised before merge.
