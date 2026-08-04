# Agent Orchestrator + OCR STEP 3.4 Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | agent-orchestrator (+ ocr agent/backend) |
| **Reviewer** | Reviewer Agent (independent) |
| **Date** | 2026-08-04 |
| **Sources** | `spec/architecture.md` §3.4 (+ §3.1 agents/prompts), `openspec/specs/agent-orchestrator/spec.md`, `openspec/specs/ocr/spec.md` (agent/backend), `openspec/plans/agent-orchestrator-ocr-tasks.md` §8.1–8.7 |
| **Claimed** | BaseAgent + Master LangGraph + OCR Agent; Celery → Master → OCR; 115 pytest green |
| **Verdict** | **PASS** |

---

## Verdict

**PASS** — STEP 3.4 BaseAgent + Master Agent + OCR Agent Definition of Done is met. Plan gates 8.1–8.7 all pass. Independent `pytest` run matches the claimed green suite.

**Is STEP 3.4 DoD met?** **Yes.**

**May STEP 3.5 (RAG pipeline) proceed?** **Yes.**

---

## Gate-by-gate results

| # | Gate | Result |
|---|---|---|
| 8.1 | BaseAgent — OCR subclasses BaseAgent; `AgentResult` / `AgentContext` / `on_error` match §3.4 | **PASS** |
| 8.2 | Master-only orchestration — no specialist→specialist imports; Celery → Master → registry → OCR (no direct OCRAgent / `extract_text` in task) | **PASS** |
| 8.3 | OCR Protocol — OCR Agent uses `OCRProvider` only; no vendor SDKs in `app/agents/` | **PASS** |
| 8.4 | Prompts — `prompt_loader` + `prompts/`; no inlined prompt bodies in agent modules | **PASS** |
| 8.5 | Celery status — enqueue/`run_ocr` status transitions preserved; DocumentService callers unchanged | **PASS** |
| 8.6 | Scope — no other specialized agents; no `rag/` | **PASS** |
| 8.7 | Final vs OpenSpec agent-orchestrator + ocr (agent/backend) + architecture §3.4 | **PASS** |
| — | Coupling tests exist and make sense | **PASS** |
| — | `pytest` in `backend/` green | **PASS** (115 passed, 1 warning) |

---

## Evidence

### 8.1 BaseAgent gate

- `app/agents/base_agent.py`: `AgentResult` (`success`, `data`, `error`, `metadata` with defaults), `AgentContext` (document/job/user/correlation ids + `extra`), abstract `BaseAgent` with `name`, async `run`, default `on_error` shaping `success=False` + error string + metadata (agent name, error_type, ids). Retry policy: documented no-retry (deterministic).
- `OCRAgent` subclasses `BaseAgent`, sets `name = "ocr"`, implements only `run`.
- Covered by `tests/test_base_agent.py`, `tests/test_ocr_agent.py`.

### 8.2 Master-only orchestration gate

- Agents under `app/agents/`: `base_agent.py`, `master_agent.py`, `ocr_agent.py` only (+ package `__init__`).
- `ocr_agent.py` imports only `base_agent` + Protocol + `prompt_loader` — no other `*_agent` modules, no Master.
- `master_agent.py` alone imports `OCRAgent` for registry wiring; LangGraph `StateGraph` routes `intent=="ocr"` → OCR node → `AgentResult`.
- Public task entrypoint: `run_master` / `MasterAgent.invoke`.
- `app/tasks/document_processing.py`: imports `AgentContext` + `run_master` only from agents; **no** `OCRAgent` import; **no** `.extract_text` call. Obtains `OCRProvider` via task DI and injects into `run_master` (factory/DI for graph construction — not a direct provider invocation).
- Static + behavioral coverage: `tests/test_agent_coupling.py`, `tests/test_document_processing_tasks.py` (`test_run_ocr_task_module_does_not_call_extract_text_directly`, Master-path / failure mocks).

### 8.3 OCR Protocol gate

- `OCRAgent.__init__(self, ocr: OCRProvider)`; `run` calls only `await self._ocr.extract_text(...)`.
- Grep of `app/agents/`: no Mistral / Document AI / OpenAI / boto3 / Supabase / Google Cloud SDK markers.
- Vendor adapters remain under `app/adapters/ocr/` (STEP 3.3). Unit guard: `test_ocr_agent_module_has_no_vendor_sdk_imports`.

### 8.4 Prompts gate

- `app/prompts/prompt_loader.py` loads versioned YAML from `app/prompts/<name>/<version>.yaml`; path traversal rejected.
- Template present: `app/prompts/ocr/v1.yaml`.
- `OCRAgent` calls `prompt_loader.load("ocr", version="v1")`; agent source has no inlined copy of the template body (body lives only in YAML). Plan explicitly allows Protocol-only OCR to ship loader + namespaced template as pattern proof — satisfied.
- Tests: `tests/test_prompt_loader.py`, `test_ocr_agent_loads_prompt_via_loader_not_inline`.

### 8.5 Celery status gate

- Success path: job `succeeded`, document `ready`; failure: job `failed` + `error_message`, document `failed`.
- Status updates remain at the task layer after Master returns `AgentResult`.
- `enqueue_document_processing(document_id) -> job_id` signature unchanged for DocumentService.
- Tests preserve STEP 3.3 semantics via Master mock and eager Celery + fakes (`tests/test_document_processing_tasks.py`).

### 8.6 Scope gate

- No Summary / Translation / Search / Citation / Export / Security / Notification / Analytics agent modules.
- No `app/rag/` tree.
- Master rejects non-OCR intents (`Unsupported Master intent`) — correct for this step’s OCR-only graph.

### 8.7 Final vs OpenSpec + architecture §3.4

| Expectation | Status |
|---|---|
| BaseAgent + AgentResult + on_error (§3.4) | Met |
| Specialized agents implement only `run` | Met (OCR) |
| Master LangGraph sequences via node registry; no agent→agent class calls | Met |
| OCR Agent via Master, returns AgentResult | Met |
| OCR extraction only through OCRProvider Protocol | Met (inside agent) |
| Shared prompts directory + loader; no inlined prompt bodies | Met |
| Celery composable unit orchestrated by agent graph | Met (`run_ocr` → `run_master`) |
| Full specialized agent set / LLMProvider agent usage | Deferred (STEP 3.6) — out of scope |
| Client job poller (ocr Flutter) | Deferred — out of scope |
| `rag/` | Deferred (STEP 3.5) — correctly absent |

### Coupling tests

`tests/test_agent_coupling.py` is substantive, not decorative:

1. AST import-graph over specialized modules — forbids other specialists and `master_agent`.
2. Only Master may import specialized agents.
3. Source-level ban on other specialist class names / Master refs in `ocr_agent.py`.
4. Behavioral: Master invokes OCR while OCR source never references Master.

Together with task-module source asserts (no `.extract_text`), this adequately enforces OpenSpec “Reject direct agent coupling” for STEP 3.4.

### pytest (independent)

```
115 passed, 1 warning in ~7s
```

(Starlette/`httpx` TestClient deprecation warning only — non-blocking.)

---

## Findings

### Blockers

None.

### Non-blocking observations

1. **OCR prompt body unused for LLM work** — `OCRAgent` loads `ocr/v1` and surfaces `prompt_name` / `prompt_version` in `data`, but does not consume `prompt.template` (no LLM call yet). Acceptable per plan §2.1 pattern-proof; future LLM-backed agents should actually apply loaded templates.
2. **OCRProvider resolved at Celery boundary** — task still calls `get_task_ocr_provider()` and passes the instance into `run_master`. This is DI into the graph, not a direct `extract_text` call; gate 8.2 / 8.3 still pass. Tighter encapsulation later could resolve providers only inside `build_master_agent` factories if desired.
3. **Task module does not AST-forbid `OCRAgent` import** — source inspection shows no such import today; optional hardening would assert `OCRAgent` absent from `document_processing.py` the same way `.extract_text` is forbidden.

---

## STEP 3.5 readiness

**Yes — RAG pipeline (STEP 3.5) may proceed.** Orchestration contract (BaseAgent, Master registry, Celery → Master) and OCR path are in place; `rag/` remains correctly unimplemented for this step.
