# Backend Services STEP 3.3 Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | backend-services (+ auth backend) |
| **Reviewer** | Reviewer Agent |
| **Date** | 2026-08-04 |
| **Sources** | `spec/architecture.md` §3.1–§3.3, `openspec/specs/backend-services/spec.md`, `openspec/specs/auth/spec.md` (backend), `openspec/plans/backend-services-tasks.md` §11.1–11.7 |
| **Verdict** | **PASS** |

---

## Verdict

**PASS** — STEP 3.3 Backend core Definition of Done is met. Plan gates 11.1–11.7 all pass (Compose host smoke 1.9 remains a known acceptable partial).

**Is STEP 3.3 Backend core DoD met?** **Yes.**

**May Agent-Architecture (STEP 3.4) proceed?** **Yes.**

---

## Gate-by-gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Adapter Protocol — no vendor SDKs in routers/services/tasks; Protocols match §3.3 | **PASS** |
| 11.2 | Default DI bindings Supabase / Mistral / Gemini / R2; alternates selectable | **PASS** |
| 11.3 | UserService + DocumentService BaseService CRUD + domain methods; thin routers | **PASS** |
| 11.4 | Bearer via `AuthProvider.verify_token`; unauthorized covered by tests | **PASS** |
| 11.5 | Celery upload/OCR single-purpose; no `agents/` or `rag/` logic | **PASS** |
| 11.6 | `/openapi.json` reflects auth / users / documents schemas | **PASS** |
| 11.7 | Final vs OpenSpec backend-services + auth backend + architecture §3.1–§3.3 | **PASS** |
| 8 | `pytest` in `backend/` green | **PASS** (79 passed, 1 warning) |
| — | Compose smoke task 1.9 | **PARTIAL (acceptable)** — Compose + README verify steps exist; Docker smoke not run in this session |

---

## Evidence

### 11.1 Adapter Protocol gate

- Grep of `app/api/`, `app/services/`, `app/tasks/`: **no** imports of `boto3`, OpenAI/Gemini/Mistral SDKs, Supabase client, Clerk SDK, or Google Document AI clients.
- Vendor/integration libraries live only under `app/adapters/` (`boto3` in R2; `jwt` in Supabase; `httpx` for Mistral/Gemini HTTP). Protocols file has no SDK imports.
- `app/adapters/protocols.py` matches architecture §3.3: `AuthProvider.verify_token`, `StorageProvider.upload` / `signed_url`, `LLMProvider.complete`, `OCRProvider.extract_text`, plus shared `UserIdentity` / `OCRResult`.
- Tasks use `httpx` only to fetch bytes after `StorageProvider.signed_url` (or optional `get_object` on fakes). That is a generic HTTP client, not a vendor SDK — allowed.

### 11.2 Default bindings gate

- `Settings` defaults: `auth_provider=supabase`, `ocr_provider=mistral`, `llm_provider=gemini`, `storage_provider=r2`.
- `provider_factory` / FastAPI deps resolve to `SupabaseAuthAdapter`, `MistralOCRAdapter`, `GeminiLLMAdapter`, `R2StorageAdapter`.
- Alternates via selectors: Clerk, Document AI, OpenAI (covered by `tests/test_dependencies.py`).

### 11.3 Service shape gate

- `BaseService` exposes `create` / `get` / `list` / `update` / `delete`.
- `UserService` / `DocumentService` extend it with domain methods (`upsert_from_identity`, `update_profile`, `create_with_upload`, `list_for_user`, `get_status`, `mark_status`).
- Routers (`auth`, `users`, `documents`) depend on services / `get_current_user` only — no repository or SDK calls in handlers. Repo wiring is in `app/api/deps.py`.

### 11.4 Auth backend gate

- `get_current_user` extracts bearer and calls only `AuthProvider.verify_token`; maps `AuthenticationError` / missing token → 401.
- Coverage: `test_auth_protected.py`, `test_api_auth.py`, `test_api_users.py`, `test_api_documents.py` (401 without token); Supabase/Clerk adapter unit tests for invalid tokens.

### 11.5 Celery core gate

- `enqueue_document_processing` + `run_ocr` are single-purpose OCR units; OCR via `OCRProvider`; no agent graph or RAG ingest.
- `app/agents/` and `app/rag/` are absent (deferred to later steps) — correct for STEP 3.3.

### 11.6 OpenAPI gate

Inspected `create_app().openapi()`:

| Paths | Schemas (auth/users/documents) |
|---|---|
| `/api/v1/auth/me` | `AuthSessionResponse` |
| `/api/v1/users/me` | `UserProfileResponse`, `UserProfileUpdateRequest` |
| `/api/v1/documents`, `/{id}`, `/{id}/status` | `DocumentResponse`, `DocumentListResponse`, `DocumentStatusResponse`, upload body |

### 11.7 Final vs OpenSpec + architecture

| Expectation | Status |
|---|---|
| §3.1 scaffold (minus agents/rag) | Present: routers, services, repositories, adapters/{auth,storage,llm,ocr}, models, schemas, tasks, core |
| §3.2 BaseService | Implemented; domain services extend it |
| §3.3 Protocols + DI | Implemented; defaults + swaps |
| Thin routers → services | Met |
| Composable Celery OCR unit | Met |
| OpenAPI from Pydantic | Met |
| Auth: bearer via AuthProvider | Met |
| Core STEP 3.3 domains (users, documents, jobs) | Models + repos + migration present; broader domains (chats, RAG chunks, etc.) correctly deferred |
| Compose files | `backend/docker-compose.yml` + Dockerfile + verify notes |

### pytest

```
79 passed, 1 warning in ~7s
```

(Starlette/`httpx` TestClient deprecation warning only — non-blocking.)

---

## Known partial (non-blocking)

- **Task 1.9 Compose smoke:** files and host verify steps exist; live `docker compose up` health check was not executed here (Docker unavailable / out of review scope). Per review contract, this alone does **not** REJECT.

---

## Advisory (not required for PASS)

- Document ownership checks (`doc.user_id != user.id`) live in the documents router. Acceptable as HTTP authz for this step; could later move into `DocumentService` for stricter “no domain rules in routers.”
- Full OpenSpec “Core data domains” list (chats, exports, subscriptions, …) is intentionally out of scope for STEP 3.3 per the task plan.

---

## Actionable findings

**None** — no REJECT blockers.

---

## Proceed decision

| Question | Answer |
|---|---|
| STEP 3.3 Backend core DoD met? | **Yes** |
| May Agent-Architecture (STEP 3.4) proceed? | **Yes** |
