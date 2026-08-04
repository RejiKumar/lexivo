# Backend Services — Task Plan
Capability: backend-services (primary) + auth / documents / users (backend-relevant)
Architecture: architecture.md §3.1–§3.3 (folder structure, BaseService, adapter Protocols)
OpenSpec: `openspec/specs/backend-services/spec.md`, `openspec/specs/auth/spec.md` (backend parts only)
Product: Lexivo
Execution order: **STEP 3.3** — Backend core (auth, documents, users) + adapters + tests

**Prerequisite (completed)**
- [x] Design-system DoD met (`openspec/plans/design-system-tasks.md` F.6) — STEP 3.2 gate cleared; this plan may proceed

**Out of scope for this file (later steps)**
- Specialized agents / LangGraph Master Agent
- RAG pipeline (`rag/`, chunker, embedder, hybrid retriever)
- Flutter features / OpenAPI client codegen wiring on the client
- Cloud Run deploy (Hosting = Cloud Run later; local Compose only here)

**Product defaults (resolved — wire as DI launch bindings)**

| Protocol | Default adapter | Alternate / stub |
|---|---|---|
| AuthProvider | Supabase Auth | Clerk (stub behind same Protocol) |
| OCRProvider | Mistral OCR | Google Document AI (stub) |
| LLMProvider | Gemini | OpenAI (stub) |
| StorageProvider | Cloudflare R2 | — (Protocol only) |

**Conventions**
- Loop per chunk: failing unit test → implement → integration test (where noted) → review vs OpenSpec + architecture §3.1–§3.3 → fix → commit.
- Routers stay thin: services only; no repository or SDK calls in handlers.
- Services/repos/agents depend on **Protocols via DI**, never concrete vendor SDKs.
- Prefer small sequential commits; never one giant “backend” commit.
- Prefix package/layout: `backend/app/...` per architecture.md §3.1.

---

## 0. FastAPI scaffold (§3.1)

- [x] 0.1 Create `backend/` Python project skeleton (`pyproject.toml` / `requirements.txt`, `app/` package, `tests/`, `alembic/` placeholder); pin FastAPI, uvicorn, pydantic-settings, SQLAlchemy, celery, redis, pytest, httpx, pytest-asyncio
- [x] 0.2 Scaffold empty tree per architecture.md §3.1: `app/main.py`, `api/v1/routers/`, `services/`, `repositories/`, `adapters/{auth,storage,llm,ocr}/`, `models/`, `schemas/`, `tasks/`, `core/{config,security,db}.py` — stub modules only (no agents/, no rag/)
- [x] 0.3 Write failing smoke test that app factory exposes FastAPI instance and `/health` (or `/api/v1/health`) returns 200
- [x] 0.4 Implement minimal `create_app()` + health route; ensure `uvicorn` entry works locally
- [x] 0.5 Review scaffold vs architecture.md §3.1 (folder names, layering dirs present, no premature agents/rag); fix; commit scaffold

---

## 1. Config, DB, Docker Compose

### 1.A Config (pydantic-settings)

- [x] 1.1 Write failing unit tests for `Settings` loading from env: database URL, Redis URL, Celery broker, Supabase/R2/Gemini/Mistral keys, adapter provider selectors (`AUTH_PROVIDER`, `OCR_PROVIDER`, `LLM_PROVIDER`, `STORAGE_PROVIDER`) with defaults = supabase / mistral / gemini / r2
- [x] 1.2 Implement `app/core/config.py` via pydantic-settings; no hardcoded secrets; document required env vars in `backend/.env.example`
- [x] 1.3 Review vs architecture.md §6 (env-driven config); fix; commit

### 1.B Database session

- [x] 1.4 Write failing tests for engine/session factory and FastAPI `get_db` dependency yielding a session
- [x] 1.5 Implement `app/core/db.py` (SQLAlchemy engine, SessionLocal, `get_db`); enable pgvector extension in migration bootstrap notes
- [x] 1.6 Add Alembic init + first migration placeholder for `users`, `documents`, `jobs` tables (document_chunks deferred to RAG step — table stub OK if needed for FK hygiene, no ingest logic)
- [x] 1.7 Review vs backend-services “Core data domains” (users, documents, jobs for this step); fix; commit

### 1.C Docker Compose local stack

- [x] 1.8 Write Compose file: Postgres+pgvector, Redis, backend API, Celery worker; shared env from `.env.example`; healthchecks for Postgres/Redis
- [ ] 1.9 Integration smoke: `docker compose up` brings services healthy; backend `/health` reachable from host
  <!-- PARTIAL: Compose files + README verify steps shipped; Docker not available in agent session — host must run smoke manually -->
- [x] 1.10 Review vs architecture.md §6 local stack; fix; commit Compose + docs note (Cloud Run later)

---

## 2. Adapter Protocols + DI

- [x] 2.1 Write failing unit tests asserting Protocol shapes exist and are structural: `AuthProvider.verify_token`, `StorageProvider.upload` / `signed_url`, `LLMProvider.complete`, `OCRProvider.extract_text` (match architecture.md §3.3 signatures; shared types `UserIdentity`, `OCRResult`)
- [x] 2.2 Implement Protocol modules + shared result/identity types under `app/adapters/` (or `app/adapters/protocols.py`); no SDK imports in Protocol files
- [x] 2.3 Write failing tests for DI providers: with default Settings, bindings resolve to Supabase / R2 / Gemini / Mistral concrete classes (may use fakes until adapters land — mark xfail or inject stubs temporarily)
- [x] 2.4 Implement FastAPI dependency providers (`get_auth_provider`, `get_storage_provider`, `get_llm_provider`, `get_ocr_provider`) switching on Settings selectors
- [x] 2.5 Review vs OpenSpec backend-services “Adapter protocols” + “Default bindings”; fix; commit

---

## 3. Auth adapters (Supabase default + Clerk stub)

- [ ] 3.1 Write failing unit tests for Supabase Auth adapter: valid token → `UserIdentity`; invalid/missing → raises/maps to unauthorized domain error (mock Supabase JWT/JWKS or client)
- [ ] 3.2 Implement `adapters/auth/supabase_adapter.py` implementing `AuthProvider`
- [ ] 3.3 Write failing unit tests for Clerk stub adapter: same Protocol surface; returns deterministic stub identity or clear “not configured” behavior for local tests
- [ ] 3.4 Implement `adapters/auth/clerk_adapter.py` stub behind `AuthProvider` (no production Clerk requirement)
- [ ] 3.5 Wire DI: default `AUTH_PROVIDER=supabase`; selector can switch to `clerk`
- [ ] 3.6 Integration test: protected dependency using AuthProvider rejects bad bearer; accepts mocked valid token
- [ ] 3.7 Review vs OpenSpec auth “Token verification via AuthProvider” (backend only — no Flutter auth module); fix; commit

---

## 4. Storage adapter (R2)

- [ ] 4.1 Write failing unit tests for R2 adapter: `upload` returns object key/URL string; `signed_url` returns time-limited URL (mock boto3/S3-compatible client)
- [ ] 4.2 Implement `adapters/storage/r2_adapter.py` implementing `StorageProvider`
- [ ] 4.3 Bind DI default `STORAGE_PROVIDER=r2`
- [ ] 4.4 Review vs architecture §3.3 StorageProvider + document upload boundary; fix; commit

---

## 5. LLM adapters (Gemini default + OpenAI stub)

- [ ] 5.1 Write failing unit tests for Gemini adapter: `complete(prompt, **kwargs)` returns string (mock Gemini SDK/HTTP)
- [ ] 5.2 Implement `adapters/llm/gemini_adapter.py` implementing `LLMProvider`
- [ ] 5.3 Write failing unit tests for OpenAI stub adapter: same Protocol; deterministic stub completion for tests
- [ ] 5.4 Implement `adapters/llm/openai_adapter.py` stub behind `LLMProvider`
- [ ] 5.5 Wire DI: default `LLM_PROVIDER=gemini`; selector can switch to `openai`
- [ ] 5.6 Review vs OpenSpec default Gemini / swap OpenAI; confirm no route/service imports SDK; fix; commit

---

## 6. OCR adapters (Mistral default + Document AI stub)

- [ ] 6.1 Write failing unit tests for Mistral OCR adapter: `extract_text(file: bytes)` → `OCRResult` (mock HTTP/SDK)
- [ ] 6.2 Implement `adapters/ocr/mistral_ocr_adapter.py` implementing `OCRProvider`
- [ ] 6.3 Write failing unit tests for Document AI stub: same Protocol surface; stub `OCRResult`
- [ ] 6.4 Implement `adapters/ocr/doc_ai_adapter.py` stub behind `OCRProvider`
- [ ] 6.5 Wire DI: default `OCR_PROVIDER=mistral`; selector can switch to `document_ai`
- [ ] 6.6 Review vs OpenSpec OCR adapter defaults (backend Protocol only — no OCR agent); fix; commit

---

## 7. BaseService + repositories + UserService + DocumentService

### 7.A ORM models + repositories

- [ ] 7.1 Write failing model/repo unit tests for `User` and `Document` (+ minimal `Job` for status) CRUD via repositories
- [ ] 7.2 Implement SQLAlchemy models in `app/models/` and repositories in `app/repositories/` (SQL only; no business rules)
- [ ] 7.3 Review layering: repos never import adapters or routers; fix; commit

### 7.B BaseService

- [ ] 7.4 Write failing unit tests for `BaseService[T]` CRUD shape: `create`, `get`, `list`, `update`, `delete` (architecture.md §3.2)
- [ ] 7.5 Implement `BaseService` generic; domain services extend it
- [ ] 7.6 Review vs OpenSpec “Service-layer CRUD shape”; fix; commit

### 7.C UserService

- [ ] 7.7 Write failing unit tests for `UserService`: upsert/get from `UserIdentity`, get/update allowed profile fields (account settings backend surface)
- [ ] 7.8 Implement `UserService` + wire repository; no Auth SDK in service (identity already verified)
- [ ] 7.9 Review vs auth “Account settings” backend persistence; fix; commit

### 7.D DocumentService

- [ ] 7.10 Write failing unit tests for `DocumentService`: create document metadata, attach storage key via StorageProvider Protocol, update/query status lifecycle (`processing` / `ready` / `failed`), list/filter by user
- [ ] 7.11 Implement `DocumentService` extending BaseService; inject StorageProvider + repository via DI; enqueue hook stubbed to task interface (implement enqueue in §9)
- [ ] 7.12 Review vs backend-services document status lifecycle + document-scan backend boundary (create + upload + enqueue, no Flutter); fix; commit

---

## 8. Thin routers + Pydantic → OpenAPI

### 8.A Schemas

- [ ] 8.1 Write failing schema tests (or contract snapshots) for auth identity/session responses, user profile request/response, document create/list/status responses
- [ ] 8.2 Implement Pydantic schemas in `app/schemas/`; ensure FastAPI generates `/openapi.json` fields from them
- [ ] 8.3 Review vs architecture.md §4 (schemas as API source of truth); note Flutter regen is later CI step — do not implement Flutter client here; fix; commit

### 8.B Auth router

- [ ] 8.4 Write failing API tests: bearer-protected routes use AuthProvider; unauthorized without token; me/session endpoint returns identity-backed payload
- [ ] 8.5 Implement thin `api/v1/routers/auth.py` (verify/session/me only — no custom password crypto)
- [ ] 8.6 Review vs OpenSpec auth token verification scenarios; fix; commit

### 8.C Users router

- [ ] 8.7 Write failing API tests for get/update current user profile via UserService
- [ ] 8.8 Implement thin `api/v1/routers/users.py`
- [ ] 8.9 Review thin-router rule (no repo/SDK in handler); fix; commit

### 8.D Documents router

- [ ] 8.10 Write failing API tests: create/upload document, get by id, list, get status — all via DocumentService
- [ ] 8.11 Implement thin `api/v1/routers/documents.py`
- [ ] 8.12 Mount v1 routers in `main.py`; confirm OpenAPI lists auth/users/documents paths
- [ ] 8.13 Review vs OpenSpec “Thin router” + OpenAPI source of truth; fix; commit

---

## 9. Celery task units (upload / OCR enqueue — minimal core)

- [ ] 9.1 Write failing unit tests for Celery app config (broker from Settings) and task registration
- [ ] 9.2 Implement `app/tasks/` Celery app + worker entry compatible with Compose
- [ ] 9.3 Write failing tests for `enqueue_document_processing` (or equivalent): given document id, creates/updates job row and queues OCR task unit
- [ ] 9.4 Implement minimal task units: e.g. `run_ocr` calling OCRProvider Protocol (injected/factory — not SDK), update document/job status; **no** agent graph, embeddings, or RAG
- [ ] 9.5 Wire DocumentService create/upload path to enqueue task
- [ ] 9.6 Integration test (Compose or eager Celery): upload → task runs with mocked OCRProvider → status transitions queryable
- [ ] 9.7 Review vs OpenSpec “Composable Celery tasks” / OCR task unit (core only); fix; commit

---

## 10. Shared test fixtures + pytest green

- [ ] 10.1 Add shared fixtures: test Settings, DB session (SQLite or testcontainer Postgres), fake Auth/Storage/LLM/OCR providers implementing Protocols, APITestClient with auth header helper
- [ ] 10.2 Ensure all unit + API + task tests use shared fixtures; remove duplicated mocks
- [ ] 10.3 Run full `pytest` suite green locally (and document Compose-backed integration optional marker)
- [ ] 10.4 Review fixture hygiene (fakes implement Protocols; no concrete SDK required for default CI); fix; commit

---

## 11. Reviewer gate checkpoints (service / adapter contracts)

Run after §§2–9 land; blockers must be fixed before declaring STEP 3.3 done.

- [ ] 11.1 **Adapter Protocol gate:** grep/review — no route, service, or task imports vendor SDKs; only adapters do; Protocols match §3.3
- [ ] 11.2 **Default bindings gate:** with launch Settings, DI resolves Auth=Supabase, OCR=Mistral, LLM=Gemini, Storage=R2; alternates Clerk / Document AI / OpenAI selectable without caller changes
- [ ] 11.3 **Service shape gate:** UserService + DocumentService expose BaseService CRUD + domain methods; routers call services only
- [ ] 11.4 **Auth backend gate:** bearer verification only via `AuthProvider.verify_token`; unauthorized path covered by tests
- [ ] 11.5 **Celery core gate:** upload/OCR enqueue is a single-purpose task unit; no specialized agents or RAG in this step
- [ ] 11.6 **OpenAPI gate:** `/openapi.json` reflects Pydantic schemas for auth/users/documents
- [ ] 11.7 Final review vs `openspec/specs/backend-services/spec.md` + auth backend requirements + architecture §3.1–§3.3; fix remaining gaps; commit “backend-services STEP 3.3 core DoD met”

---

## Definition of Done (STEP 3.3)

- [ ] Scaffold matches architecture.md §3.1 (minus agents/rag deferred)
- [ ] Compose stack: Postgres+pgvector, Redis, backend, Celery
- [ ] All four Protocols + DI defaults (Supabase / R2 / Gemini / Mistral) and stubs (Clerk / OpenAI / Document AI)
- [ ] BaseService + UserService + DocumentService + repositories
- [ ] Thin routers: auth, users, documents; OpenAPI from Pydantic
- [ ] Minimal Celery upload/OCR enqueue path
- [ ] Shared fixtures; pytest green
- [ ] Reviewer gates 11.1–11.7 passed
