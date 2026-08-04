# Agent Orchestrator + OCR Agent — Task Plan
Capability: agent-orchestrator (primary) + ocr (agent/backend surface)
Architecture: architecture.md §3.4 (BaseAgent, AgentResult, Master Agent LangGraph — no agent-to-agent direct calls); §3.1 `agents/` + `prompts/`
OpenSpec: `openspec/specs/agent-orchestrator/spec.md`, `openspec/specs/ocr/spec.md` (agent/backend parts only)
Product: Lexivo
Execution order: **STEP 3.4** — BaseAgent + Master Agent + OCR Agent + tests

**Prerequisite (completed)**
- [x] Backend core STEP 3.3 DoD PASS (`openspec/reviews/backend-services-step33-review.md`) — adapter Protocols, DocumentService, Celery `run_ocr` calling OCRProvider directly; this plan may proceed

**Out of scope for this file (later steps)**
- Summary, Translation, Search, Citation, Export, Security, Notification, Analytics agents (STEP 3.6)
- RAG pipeline / `rag/` (STEP 3.5)
- Flutter features / job poller UI (OCR client polling deferred)
- Changing OCRProvider Protocol or Mistral/Document AI adapters (already STEP 3.3)

**In scope (only)**
- `BaseAgent` + `AgentResult` + `AgentContext` + default `on_error`
- Master Agent LangGraph graph + node registry
- OCR Agent only (depends on `OCRProvider` Protocol — already exists)
- Shared prompt loader + `prompts/` directory pattern
- Tests proving no agent-to-agent direct calls
- Thin Celery `run_ocr` migration: Celery → Master → OCR Agent (Protocol usage stays inside the agent)

**Conventions**
- Loop per chunk: failing unit test → implement → integration test (where noted) → review vs OpenSpec + architecture §3.4 → fix → commit.
- Agents subclass `BaseAgent` and implement only `run()`; no copied plumbing.
- Specialized agents never import or invoke other specialized agent classes — only the Master node registry may invoke agents.
- Agents/services depend on **Protocols via DI**, never concrete vendor SDKs.
- Prompts live under `backend/app/prompts/`; no inlined prompt strings in agent code.
- Prefer small sequential commits; never one giant “agents” commit.
- Prefix layout: `backend/app/agents/`, `backend/app/prompts/` per architecture.md §3.1.

**Current state (migration note)**
- STEP 3.4 complete: `run_ocr` → `run_master` → OCR Agent → OCRProvider; Celery remains the job boundary; status updates stay at the task layer.

---

## 0. Agents / prompts scaffold + LangGraph dependency

- [x] 0.1 Add `langgraph` (and minimal required peer deps) to `backend/requirements.txt` / `pyproject.toml`; pin versions compatible with existing FastAPI/Celery stack
- [x] 0.2 Scaffold empty tree: `app/agents/` (`__init__.py`, placeholders for `base_agent.py`, `master_agent.py`, `ocr_agent.py` only — **no** summary/translation/… stubs that imply STEP 3.6 work), `app/prompts/` (+ `__init__.py`), `app/prompts/prompt_loader.py` stub
- [x] 0.3 Write failing smoke test that `app.agents` and `app.prompts` packages import and LangGraph is importable
- [x] 0.4 Review scaffold vs architecture.md §3.1 agents/prompts layout (only Base/Master/OCR files); fix; commit

---

## 1. AgentResult + AgentContext + BaseAgent + on_error

### 1.A Result / context types

- [x] 1.1 Write failing unit tests for `AgentResult` Pydantic model: fields `success`, `data`, `error`, `metadata` (defaults: `data=None`, `error=None`, `metadata={}`); reject invalid shapes
- [x] 1.2 Write failing unit tests for `AgentContext`: carries correlation ids / document_id / job_id / user_id (or equivalent) needed by agents and tracing; serializable for graph state handoff
- [x] 1.3 Implement `AgentResult` + `AgentContext` in `app/agents/base_agent.py` (or adjacent `types` module re-exported from base) matching architecture.md §3.4
- [x] 1.4 Review vs OpenSpec agent-orchestrator “BaseAgent contract” field list; fix; commit

### 1.B BaseAgent ABC

- [x] 1.5 Write failing unit tests: concrete subclass must set `name` and implement `async run(input: dict, context: AgentContext) -> AgentResult`; cannot instantiate ABC
- [x] 1.6 Write failing unit tests for default `on_error(error, context) -> AgentResult`: shapes `success=False`, `error` string populated, `metadata` may include agent name / error type; overridable by subclass
- [x] 1.7 Write failing unit test that a minimal stub agent’s `run` success path returns `AgentResult(success=True, data=...)` without reimplementing error plumbing
- [x] 1.8 Implement abstract `BaseAgent` with `name`, `run`, default `on_error` (retry/error-shape hooks as specified — document retry policy: default no-retry or single retry if architecture silent; keep deterministic for unit tests)
- [x] 1.9 Review vs architecture.md §3.4 + OpenSpec “New agent implements only run”; fix; commit

---

## 2. Shared prompt loader + prompts/ pattern

- [x] 2.1 Add versioned sample template under `app/prompts/` (e.g. `ocr/v1.yaml` or `.prompt`) used by OCR Agent for any post-extract cleanup/instruction text if needed; if OCR Agent is Protocol-only with no LLM call, still ship loader + one OCR-namespaced template proving the pattern
- [x] 2.2 Write failing unit tests for `prompt_loader.load(name, version=...)` (or equivalent): returns template text/structured fields; missing template raises clear error; no agent may hardcode the same string
- [x] 2.3 Implement `app/prompts/prompt_loader.py` reading only from `app/prompts/`; path traversal rejected
- [x] 2.4 Review vs OpenSpec “Shared prompts and LLM access” / “No inlined prompts”; fix; commit

---

## 3. Master Agent LangGraph graph + node registry

- [x] 3.1 Write failing unit tests for node registry: register agent by name → resolve callable/node; unknown name fails clearly; registry does not require specialized agents to import each other
- [x] 3.2 Write failing unit tests for Master graph (OCR-only for this step): given a graph input requesting OCR, graph invokes the registered OCR node and returns aggregated `AgentResult` (or graph state containing it)
- [x] 3.3 Write failing unit test: Master entrypoint is the only public orchestrator API used by tasks (`run_master(...)` / `MasterAgent.invoke(...)` — pick one name and stick to it)
- [x] 3.4 Implement `app/agents/master_agent.py`: LangGraph StateGraph, node registry, OCR node wired; stubs/placeholders for future agent names **must not** import or implement those agents (registry keys optional/empty OK)
- [x] 3.5 Review vs OpenSpec “Master Agent orchestration only” + architecture “sequences agents by contract, not by import”; fix; commit

---

## 4. OCR Agent (OCRProvider Protocol)

- [x] 4.1 Write failing unit tests for `OCRAgent(BaseAgent)`: `name` is stable (e.g. `"ocr"`); `run` accepts input with file bytes (or storage key + bytes already loaded by caller); calls **only** injected `OCRProvider.extract_text`; returns `AgentResult(success=True, data={text, pages, ...})`
- [x] 4.2 Write failing unit tests: provider failure → agent uses `on_error` (or returns shaped failure `AgentResult`); no vendor SDK imports inside `ocr_agent.py`
- [x] 4.3 Write failing unit test: OCR Agent loads any needed prompt via shared `prompt_loader` (assert loader called / template key), not an inline string constant for the prompt body
- [x] 4.4 Implement `app/agents/ocr_agent.py` depending on `OCRProvider` Protocol via constructor/DI; map `OCRResult` → `AgentResult.data`
- [x] 4.5 Register OCR Agent in Master node registry; unit test Master→OCR happy path with `FakeOCRProvider`
- [x] 4.6 Review vs OpenSpec ocr “OCR Agent contract” + “OCR extraction through adapter”; fix; commit

---

## 5. Celery `run_ocr` thin migration (Celery → Master → OCR)

- [x] 5.1 Write failing tests updating `tests/test_document_processing_tasks.py` (and/or new agent-integration tests): `run_ocr` must not call `OCRProvider` directly from the task module; assert Master/OCR Agent path is used (spy/mock on Master invoke or OCRAgent.run)
- [x] 5.2 Write failing tests: success still marks document `ready` / job `succeeded` and surfaces OCR metadata; failure still marks `failed` with error message (preserve STEP 3.3 status semantics)
- [x] 5.3 Implement thin migration in `document_processing.py`: load bytes via StorageProvider (unchanged), build `AgentContext`, invoke Master with OCR intent, map `AgentResult` → job/document status updates; OCRProvider obtained only inside OCR Agent (factory/DI when constructing agent for the graph)
- [x] 5.4 Keep `enqueue_document_processing` API stable (same signature / Celery task name) so DocumentService callers need no change
- [x] 5.5 Integration test (eager Celery + fakes): upload/enqueue → Master → OCR Agent → FakeOCRProvider → status transitions queryable
- [x] 5.6 Review vs architecture §3.4 + nexora_spec “Celery tasks are composable units” orchestrated by agent graph; confirm task file has no direct `extract_text` call; fix; commit

---

## 6. No agent-to-agent direct calls (coupling guard)

- [x] 6.1 Write failing static/unit guard test: AST or import-graph check over `app/agents/` — specialized agent modules (`ocr_agent.py` now; future agents later) must not import other `*_agent.py` modules except `base_agent` / shared types; only `master_agent` may import specialized agents for registry wiring
- [x] 6.2 Write failing behavioral test: OCR Agent module has no reference to other specialist agent classes; Master can invoke OCR without OCR importing Master
- [x] 6.3 Implement/adjust package layout and imports until coupling tests pass (Master owns registry; agents stay leaf nodes)
- [x] 6.4 Review vs OpenSpec “Reject direct agent coupling”; fix; commit

---

## 7. Shared fixtures + pytest green

- [x] 7.1 Add shared fixtures: stub `AgentContext`, `FakeOCRProvider` reuse, Master graph factory with OCR node, optional `prompt_loader` temp prompts dir
- [x] 7.2 Ensure agent + migrated task tests use shared fixtures; remove duplicated mocks
- [x] 7.3 Run full `backend` `pytest` suite green (prior STEP 3.3 tests still pass after Celery migration)
- [x] 7.4 Review fixture hygiene; fix; commit

---

## 8. Reviewer gate checkpoints (STEP 3.4)

Run after §§1–6 land; blockers must be fixed before declaring STEP 3.4 done.

- [x] 8.1 **BaseAgent gate:** every agent under `app/agents/` (OCR only) subclasses BaseAgent; `AgentResult` / `AgentContext` / `on_error` match §3.4
- [x] 8.2 **Master-only orchestration gate:** no specialized-agent→specialized-agent imports; Celery enters via Master, not OCRAgent directly from task (task → Master → registry → OCR)
- [x] 8.3 **OCR Protocol gate:** OCR Agent uses OCRProvider only; no Mistral/Document AI SDK in agents/
- [x] 8.4 **Prompts gate:** prompt_loader + `prompts/` used; no inlined prompt bodies in agent modules
- [x] 8.5 **Celery status gate:** enqueue/`run_ocr` status transitions preserved; DocumentService unchanged callers
- [x] 8.6 **Scope gate:** no Summary/Translation/Search/Citation/Export/Security/Notification/Analytics agent implementations; no `rag/` module
- [x] 8.7 Final review vs `openspec/specs/agent-orchestrator/spec.md` + `openspec/specs/ocr/spec.md` (agent/backend) + architecture §3.4; fix remaining gaps; commit “agent-orchestrator STEP 3.4 Base+Master+OCR DoD met”

---

## Definition of Done (STEP 3.4)

- [x] `BaseAgent` + `AgentResult` + `AgentContext` + default `on_error` implemented and unit-tested
- [x] Master Agent LangGraph graph + node registry; OCR node registered
- [x] OCR Agent subclasses BaseAgent; uses OCRProvider Protocol; returns AgentResult
- [x] Shared `prompt_loader` + `prompts/` directory pattern in place
- [x] Celery `run_ocr` orchestrates via Master → OCR Agent (no direct OCRProvider call in the task)
- [x] Coupling tests prove no agent-to-agent direct calls
- [x] Full backend pytest green; STEP 3.3 behaviors preserved for document/job status
- [x] Reviewer gates 8.1–8.7 passed
- [x] Only Base + Master + OCR agents in scope — no other specialized agents, no RAG, no Flutter
