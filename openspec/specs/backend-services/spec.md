## Purpose

Defines the FastAPI service layer, repository boundary, adapter Protocols, Celery task units, and OpenAPI-owned API contract so routers stay thin and providers stay swappable.

## Requirements

### Requirement: Service-layer CRUD shape
Every domain service SHALL expose create, get, list, update, and delete plus domain-specific methods as needed; routers MUST call services only and MUST NOT contain business logic or talk to repositories directly.

#### Scenario: Thin router
- **WHEN** an HTTP request hits a v1 router
- **THEN** the handler delegates to a service method and returns a Pydantic schema response

### Requirement: Adapter protocols
LLM, OCR, storage, and auth integrations SHALL implement LLMProvider, OCRProvider, StorageProvider, and AuthProvider Protocols and be injected via DI; no route, service, or agent MAY call a concrete vendor SDK directly.

#### Scenario: Default bindings
- **WHEN** the application starts with launch defaults
- **THEN** AuthProvider binds to Supabase, OCRProvider to Mistral OCR, LLMProvider to Gemini, and StorageProvider to Cloudflare R2

#### Scenario: Swap provider
- **WHEN** operators change a DI binding to an alternate adapter (e.g., OpenAI or Document AI)
- **THEN** callers of the Protocol require no code changes

### Requirement: Composable Celery tasks
Background work SHALL be expressed as single-purpose Celery tasks (e.g., run_ocr, generate_embeddings) chained or orchestrated by the agent graph, not duplicated per feature.

#### Scenario: OCR task unit
- **WHEN** OCR is queued
- **THEN** a dedicated task performs OCR extraction and can be composed with subsequent ingest tasks

### Requirement: OpenAPI as API source of truth
Pydantic schemas SHALL generate OpenAPI; the Flutter client MUST be code-generated from that OpenAPI and regenerated in the same PR as schema changes.

#### Scenario: Schema change regenerates client
- **WHEN** a Pydantic response schema changes
- **THEN** CI or the PR workflow requires regenerating the Flutter typed client

### Requirement: Core data domains
The backend SHALL support users, documents, document_chunks (pgvector), chats, chat_messages, exports, subscriptions, notifications, and jobs as first-class persisted domains.

#### Scenario: Document status lifecycle
- **WHEN** a document moves through processing states
- **THEN** job and document status fields remain queryable via document services
