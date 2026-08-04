# architecture.md — Lexivo System Architecture

> Expands `spec.md` §3, §4, §6, §7 into concrete module boundaries, contracts, and folder structures. This is the second document handed to Cursor, after `spec.md`. Every rule here exists to enforce one thing: **no component, module, or service is ever built as a one-off** — everything is designed to be reused, replaced, or extended without a rewrite.

---

## 1. System Context

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter Client                        │
│         (Mobile: Android/iOS, Web, Windows later)            │
│  core/ (design_system, network, routing, theming, widgets)   │
│  features/ (auth, document_scan, ocr, summarization,          │
│             translation, rag_chat, pdf_export,                │
│             notifications, subscription)                      │
└───────────────────────────┬───────────────────────────────────┘
                             │ typed REST client (generated from OpenAPI)
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                        FastAPI Backend                       │
│  routers/  →  services/  →  repositories/  →  adapters/       │
│  (thin)       (business      (DB access)      (storage/auth/  │
│                logic)                          LLM providers) │
└───────┬───────────────────────┬───────────────────┬───────────┘
        │                       │                   │
        ▼                       ▼                   ▼
  PostgreSQL + pgvector      Redis            Cloudflare R2
        │                       │
        │                       ▼
        │                 Celery Workers
        │                       │
        │                       ▼
        │            Agent Orchestrator (LangGraph)
        │                       │
        │        ┌──────┬───────┼───────┬──────┬─────────┐
        │        ▼      ▼       ▼       ▼      ▼         ▼
        │      OCR   Summary  Trans-  Search Citation  Export/
        │      Agent  Agent   lation  /RAG   Agent      PDF/
        │                     Agent   Agent            Security/
        │                                               Notif/
        │                                               Analytics
        └──────────────────────────────────────────────────┘
                             │
                             ▼
                    Gemini / OpenAI (via one LLM adapter)
```

**Boundary rule:** arrows only flow one direction shown. A router never talks to a repository directly; a feature in Flutter never talks to another feature's data layer directly; an agent never calls another agent directly (only the orchestrator/graph does).

---

## 2. Frontend Architecture

### 2.1 Layering (per feature)

```
features/<feature_name>/
  data/
    datasources/       # remote (generated API client calls) + local (Drift) — implementations only
    repositories/       # implements domain repository interface
    models/             # Freezed DTOs, fromJson/toJson
  domain/
    entities/           # Freezed plain entities (no json annotations)
    repositories/        # abstract repository interface (contract)
    usecases/            # one class per user action, single `call()` method
  presentation/
    screens/
    widgets/             # feature-specific composition ONLY of core/design_system atoms
    providers/           # Riverpod providers/notifiers
  <feature_name>.dart     # barrel file — the ONLY public surface other layers may import
```

**Rule:** Only the barrel file is imported outside the feature. `data/` and internal `presentation/widgets` are never imported cross-feature.

### 2.2 core/ (shared, mandatory, built before any feature)

```
core/
  design_system/
    tokens/            # color.dart, spacing.dart, radius.dart, elevation.dart, motion.dart, typography.dart
    components/        # button.dart, card.dart, input.dart, bottom_sheet.dart, dialog.dart,
                        # nav_bar.dart, chat_bubble.dart, document_card.dart, empty_state.dart,
                        # error_banner.dart, skeleton_loader.dart, badge.dart, snackbar.dart
    theme/             # ThemeData assembly from tokens (light/dark)
  network/
    api_client.dart     # generated from OpenAPI — single source, never hand-edited
    dio_provider.dart    # interceptors: auth header injection, retry, error mapping
    error_mapper.dart    # maps API errors -> domain-level Failure types, reused everywhere
  routing/
    app_router.dart      # GoRouter config, one route table
    route_guards.dart    # auth guard, subscription guard — reusable guard functions
  theming/
    app_theme.dart
  utils/
    result.dart          # shared Result<Success, Failure> type used by every usecase
    job_poller.dart       # reusable "poll async job until done" utility (used by OCR, translation, export, etc.)
  widgets/
    async_value_view.dart # generic wrapper: loading/error/data states for any Riverpod AsyncValue
```

**Rule:** `job_poller.dart` and `async_value_view.dart` exist precisely so that OCR-processing, translation-processing, and PDF-export-processing — three different features with the same "long-running job" shape — share one polling/UI pattern instead of three reimplementations.

### 2.3 Cross-feature communication contract
- Feature A never imports `features/B/data` or `features/B/presentation`.
- If Feature A needs data owned by Feature B (e.g., `rag_chat` needs a `Document` entity owned by `document_scan`), the entity is promoted to `core/entities` (shared, versioned) and both features depend on `core/`, not on each other.
- Navigation between features happens only via named GoRouter routes, never direct widget imports.

---

## 3. Backend Architecture

### 3.1 Folder structure

```
backend/
  app/
    main.py
    api/
      v1/
        routers/        # auth.py, documents.py, chats.py, exports.py, subscriptions.py
    services/            # document_service.py, chat_service.py, export_service.py, ...
    repositories/         # document_repo.py, chat_repo.py, ... (SQLAlchemy queries only)
    adapters/
      auth/               # clerk_adapter.py, supabase_adapter.py (implements AuthProvider interface)
      storage/            # r2_adapter.py (implements StorageProvider interface)
      llm/                # gemini_adapter.py, openai_adapter.py (implements LLMProvider interface)
      ocr/                # doc_ai_adapter.py, mistral_ocr_adapter.py (implements OCRProvider interface)
    models/                # SQLAlchemy ORM models
    schemas/                # Pydantic request/response schemas (source of OpenAPI spec)
    agents/
      base_agent.py         # abstract BaseAgent — every agent below implements this
      master_agent.py
      ocr_agent.py
      summary_agent.py
      translation_agent.py
      search_agent.py
      citation_agent.py
      export_agent.py
      security_agent.py
      notification_agent.py
      analytics_agent.py
    rag/
      chunker.py
      embedder.py
      retriever.py          # HybridRetriever (pgvector + BM25)
      context_builder.py
    prompts/                # versioned .prompt / .yaml templates, loaded by a shared prompt_loader.py
    tasks/                  # celery tasks — one task per unit of work, composable
    core/
      config.py
      security.py            # rate limiting middleware, applied globally
      db.py
  alembic/
  tests/
```

### 3.2 Service-layer contract
Every service module exposes a consistent shape so any new domain concept plugs into the same pattern:

```python
class BaseService(Generic[T]):
    def create(self, data) -> T: ...
    def get(self, id) -> T: ...
    def list(self, filters) -> list[T]: ...
    def update(self, id, data) -> T: ...
    def delete(self, id) -> None: ...
```

Domain-specific services (e.g. `DocumentService`) extend this and add domain methods (`start_processing()`, `get_status()`), but the CRUD shape is never reinvented per service.

### 3.3 Adapter contracts (the core reusability mechanism on the backend)

```python
class LLMProvider(Protocol):
    async def complete(self, prompt: str, **kwargs) -> str: ...

class OCRProvider(Protocol):
    async def extract_text(self, file: bytes) -> OCRResult: ...

class StorageProvider(Protocol):
    async def upload(self, key: str, file: bytes) -> str: ...
    async def signed_url(self, key: str) -> str: ...

class AuthProvider(Protocol):
    async def verify_token(self, token: str) -> UserIdentity: ...
```

Every agent, service, or route depends on these **Protocol interfaces**, injected via FastAPI's dependency injection — never on a concrete SDK class directly. Switching Gemini → OpenAI, or Clerk → Supabase Auth, means writing one new adapter class and changing one DI binding.

### 3.4 Agent contract (`base_agent.py`)

```python
class AgentResult(BaseModel):
    success: bool
    data: dict | None
    error: str | None
    metadata: dict = {}

class BaseAgent(ABC):
    name: str

    @abstractmethod
    async def run(self, input: dict, context: AgentContext) -> AgentResult: ...

    async def on_error(self, error: Exception, context: AgentContext) -> AgentResult:
        # default retry/error-shape logic, overridable
        ...
```

Every specialized agent (OCR, Summary, Translation, Search, Citation, Export, Security, Notification, Analytics) subclasses `BaseAgent` and implements only `run()`. The Master Agent (a LangGraph graph) sequences agents by contract, not by import — agents never call each other's classes directly, only through the graph's node registry.

### 3.5 RAG pipeline module (`rag/`)
One parameterized pipeline, not one per document type:

```python
class RagPipeline:
    def __init__(self, chunker: Chunker, embedder: Embedder, retriever: HybridRetriever):
        ...
    async def ingest(self, document: Document, config: RagConfig) -> None: ...
    async def query(self, document_id: str, question: str) -> RagAnswer: ...
```

`RagConfig` varies chunk size/overlap/strategy per document type (contract vs. receipt vs. paper); the pipeline code itself does not branch per type.

---

## 4. API Contract Ownership
- Pydantic schemas in `app/schemas/` are the single source of truth.
- OpenAPI JSON is generated from FastAPI automatically (`/openapi.json`).
- Flutter's `core/network/api_client.dart` is code-generated from that OpenAPI JSON (e.g., via `openapi-generator` or `swagger_dart_code_generator`) — never hand-written per endpoint.
- Any schema change requires regenerating the Flutter client as part of the same PR (enforced by CI).

Full field-level schema lives in `api_contract.md` (next doc).

---

## 5. Data Flow Example — "Ask the document" (RAG chat)

1. User taps a document → Flutter `rag_chat` feature calls generated client → `POST /v1/chats/{doc_id}/messages`
2. Router (thin) → `ChatService.ask()` 
3. `ChatService` calls `RagPipeline.query()` → `HybridRetriever` hits pgvector + BM25 → builds context
4. `ChatService` invokes Master Agent graph → routes to `SearchAgent` then `CitationAgent` then final answer composed via shared `LLMProvider` adapter
5. Response persisted via `ChatRepository`, returned through the same `AgentResult`/Pydantic schema shape used by every other agent-backed endpoint
6. Flutter receives typed response, renders via the reusable `ChatBubble` component from `core/design_system`

Note how every step reuses a contract already defined for another feature (service shape, agent shape, adapter shape, UI component) — this is the pattern to replicate for every future feature.

---

## 6. Environments
- `local` — Docker Compose (Postgres+pgvector, Redis, backend, Celery worker)
- `staging` — Railway/Cloud Run + Neon branch DB
- `production` — Railway/Cloud Run + Neon main + Cloudflare Pages (web) + store builds (mobile)

Config is environment-variable driven through one `config.py` (`pydantic-settings`), never hardcoded per environment in code.

---

## 7. Open Questions for Cursor / Team to Confirm Before Coding
- [ ] Clerk vs. Supabase Auth — final choice (affects one adapter, not architecture)
- [ ] Google Document AI vs. Mistral OCR — final choice for launch (affects one adapter)
- [ ] Gemini vs. OpenAI as default LLM (affects one adapter's default binding, both remain supported)
- [ ] Subscription feature flag: built but hidden, or fully live at launch?
