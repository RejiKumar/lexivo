# Specialized Agents — Task Plan (STEP 3.6)
Capability: agent-orchestrator (remaining agents) + agent-side surfaces from summarization, translation, rag-chat, pdf-export, notifications
Architecture: architecture.md §3.4 — every agent subclasses BaseAgent; Master registry only; no agent-to-agent calls; prompts/ + LLMProvider
OpenSpec: `openspec/specs/agent-orchestrator/spec.md` (+ agent/backend slices of summarization, translation, rag-chat, pdf-export, notifications)
Product: Lexivo
Execution order: **STEP 3.6** — Summary, Translation, Search, Citation, Export, Security, Notification, Analytics agents + tests

**Prerequisite (completed)**
- [x] RAG pipeline STEP 3.5 DoD PASS (`openspec/reviews/rag-pipeline-step35-review.md`) — `RagPipeline` / `HybridRetriever` / `document_chunks` ready for Search Agent; this plan may proceed
- [x] Agent orchestrator STEP 3.4 — `BaseAgent`, `AgentResult`, `AgentContext`, Master LangGraph + OCR node, `prompt_loader`, coupling guards, Celery → Master → OCR

**Already exists (do not rebuild)**
- `BaseAgent` / `AgentResult` / `AgentContext` / default `on_error`
- Master `NodeRegistry` + OCR-only graph (`run_master` / `build_master_agent`)
- OCR Agent + `OCRProvider`
- `RagPipeline` / `HybridRetriever` / `ContextBuilder` / `RagConfig`
- `LLMProvider` / `OCRProvider` / `StorageProvider` Protocols + fakes (`FakeLLMProvider`, etc.)
- `app/prompts/prompt_loader.py` + `prompts/ocr/v1.yaml` pattern

**Out of scope for this file**
- Flutter features / design-system UI
- Full ChatService HTTP product polish beyond thin hooks needed to invoke Master (optional thin service/task OK)
- CI/CD
- Changing BaseAgent contract shape (extend Master factory/DI only)
- Replacing or rewriting `app/rag/` internals (Search consumes them)

**In scope (only)**
- Eight specialized agents: Summary, Translation, Search, Citation, Export, Security, Notification, Analytics — each subclasses `BaseAgent`, implements only `run()`
- Register each in Master node registry / LangGraph; extend graph for single-intent nodes and Search→Citation sequencing; **no** agent→agent imports
- Search Agent uses `RagPipeline` / `HybridRetriever`; Citation Agent shapes citations — coordinated **only** via Master
- Translation languages: EN↔ES, FR, DE, HI, PT
- Export Agent PDF path with summary/translation/chat section toggles at agent input level
- Notification Agent in-app + push hooks (push may stub behind a Protocol)
- Security + Analytics agents with clear `run()` responsibilities
- Versioned prompts under `prompts/`; LLM via Protocol only
- Coupling tests extended for new agents
- Small TDD tasks (failing test → implement → review → commit)

**Conventions**
- Loop per chunk: failing unit test → implement → integration/Master wiring test (where noted) → review vs OpenSpec + architecture §3.4 → fix → commit.
- Specialized agents never import or invoke other `*_agent.py` modules — only Master may import them for registry wiring.
- Agents depend on **Protocols / pipeline ports via DI**, never concrete vendor SDKs (Gemini/OpenAI/Firebase/PostHog SDKs stay in adapters).
- Prompts live under `backend/app/prompts/<agent>/vN.yaml` (or `.prompt`); no inlined prompt bodies in agent modules.
- Prefer small sequential commits; never one giant “all agents” commit.
- Layout: `backend/app/agents/<name>_agent.py` per architecture.md §3.1.

**Current state (migration note)**
- Master registers agents whose DI deps are provided; OCR path unchanged for Celery.
- Coupling tests list all nine specialized agent modules (OCR + eight STEP 3.6 agents).
- §§0–11 implementer tasks complete; §12 Reviewer gates left open (STEP 3.6 PASS not claimed).

---

## 0. Scaffold remaining agent modules + prompt namespaces

- [x] 0.1 Scaffold empty agent modules (stubs only — raise `NotImplementedError` in `run` or leave class body minimal): `summary_agent.py`, `translation_agent.py`, `search_agent.py`, `citation_agent.py`, `export_agent.py`, `security_agent.py`, `notification_agent.py`, `analytics_agent.py` under `app/agents/`
- [x] 0.2 Create prompt namespace dirs with placeholder `v1.yaml` for agents that need LLM templates: `prompts/summary/`, `prompts/translation/`, `prompts/citation/` (Search may use retrieval-only; Export/Security/Notification/Analytics may ship a minimal template or loader usage only where needed — document choice per agent)
- [x] 0.3 Write failing smoke test: each new agent module imports; each declares a stable `name` string matching registry keys (`summary`, `translation`, `search`, `citation`, `export`, `security`, `notification`, `analytics`)
- [x] 0.4 Review scaffold vs architecture.md §3.1 agent file list; fix; commit

---

## 1. Summary Agent (LLMProvider + prompts)

### 1.A Contract + prompts

- [x] 1.1 Write failing unit tests: `SummaryAgent(BaseAgent)` has `name == "summary"`; constructor accepts injected `LLMProvider`
- [x] 1.2 Write failing unit tests for `run` input: requires document text (e.g. `text` or `extracted_text`); missing/empty text → shaped failure via `on_error` or clear `AgentResult(success=False)`
- [x] 1.3 Write failing unit tests for success path: loads versioned `prompts/summary/v1` via `prompt_loader`; calls `LLMProvider.complete` (not vendor SDK); returns `AgentResult(success=True, data={short_summary, detailed_summary, ...})`
- [x] 1.4 Write failing unit test: FakeLLMProvider failure → `on_error` / failure `AgentResult`; no Gemini/OpenAI imports in `summary_agent.py`
- [x] 1.5 Write failing unit test: prompt body is not inlined as a string constant in the agent module (loader key/version only)
- [x] 1.6 Implement `app/agents/summary_agent.py` + `prompts/summary/v1.yaml` (short + detailed instructions in template)
- [x] 1.7 Review vs OpenSpec summarization “Summary Agent via orchestrator” + agent-orchestrator “Shared prompts and LLM access”; fix; commit

---

## 2. Translation Agent (EN↔ES,FR,DE,HI,PT)

- [x] 2.1 Write failing unit tests: `TranslationAgent` `name == "translation"`; DI `LLMProvider`
- [x] 2.2 Write failing unit tests for supported language codes: source/target in `{en, es, fr, de, hi, pt}` (case-normalized); pairs are EN↔target or target↔EN as required for v1
- [x] 2.3 Write failing unit tests: unsupported language → validation failure `AgentResult` (no LLM call)
- [x] 2.4 Write failing unit tests: success path loads `prompts/translation/v1`, calls `LLMProvider.complete` with rendered prompt including source text + languages; returns `data={translated_text, source_lang, target_lang, ...}`
- [x] 2.5 Write failing unit test: no other agent imports; no vendor SDK in module
- [x] 2.6 Implement `app/agents/translation_agent.py` + `prompts/translation/v1.yaml`
- [x] 2.7 Review vs OpenSpec translation “Supported language pairs” + “Translation Agent orchestration”; fix; commit

---

## 3. Search Agent (RagPipeline / HybridRetriever)

- [x] 3.1 Write failing unit tests: `SearchAgent` `name == "search"`; constructor injects `RagPipeline` (or a narrow query port wrapping pipeline/`HybridRetriever` — prefer full `RagPipeline.query` to reuse STEP 3.5)
- [x] 3.2 Write failing unit tests for `run` input: requires `document_id` + `question` (and optional config knobs); missing fields → clear failure
- [x] 3.3 Write failing unit tests for success: calls `RagPipeline.query(document_id, question)` (spy); maps `RagAnswer` / ranked chunks + context into `AgentResult.data` (`context`, `chunks`/`ranked_chunks`, metadata) — **does not** call CitationAgent or LLM for final prose
- [x] 3.4 Write failing unit tests: empty / insufficient retrieval → success-with-empty or explicit ungrounded flag in `data` (document contract); no invented answer text from Search Agent
- [x] 3.5 Write failing unit test: Search Agent module does not import `citation_agent` / other specialists; no vector-DB vendor clients
- [x] 3.6 Implement `app/agents/search_agent.py`
- [x] 3.7 Review vs OpenSpec rag-chat “Search and Citation agents” (Search half) + architecture §3.5 reuse; fix; commit

---

## 4. Citation Agent (shape citations; LLM for grounded answer)

- [x] 4.1 Write failing unit tests: `CitationAgent` `name == "citation"`; DI `LLMProvider`
- [x] 4.2 Write failing unit tests for `run` input: accepts prior Search payload (`context`, ranked `chunks` with ids/indexes, `question`); missing retrieval context → clear failure or “cannot answer” shaped result
- [x] 4.3 Write failing unit tests for success: loads `prompts/citation/v1`; calls `LLMProvider.complete`; returns `data={answer, citations: [{chunk_id|index, snippet, ...}, ...]}` suitable for later ChatBubble citation slots — **does not** call `RagPipeline` or SearchAgent
- [x] 4.4 Write failing unit tests: ungrounded / empty chunks → answer refuses invention (explicit cannot-answer message) per rag-chat “Empty or ungrounded retrieval”
- [x] 4.5 Write failing unit test: no import of `search_agent` / other specialists
- [x] 4.6 Implement `app/agents/citation_agent.py` + `prompts/citation/v1.yaml`
- [x] 4.7 Review vs OpenSpec rag-chat Search/Citation + agent-orchestrator coupling rule; fix; commit

---

## 5. Export Agent (PDF + section toggles + StorageProvider)

- [x] 5.1 Write failing unit tests: `ExportAgent` `name == "export"`; DI `StorageProvider` (and optional PDF builder port/Protocol if extraction helps testing)
- [x] 5.2 Write failing unit tests for section toggles in input: `include_summary`, `include_translation`, `include_chat` (bools); content payloads for enabled sections supplied in `input` (agent-level toggles OK — no Flutter)
- [x] 5.3 Write failing unit tests: export all sections → PDF bytes include all selected content markers/sections; export subset (summary only) omits translation/chat
- [x] 5.4 Write failing unit tests: on success, uploads via `StorageProvider.upload`, returns `data={storage_key, signed_url}` from `signed_url`; failure path shapes `AgentResult`
- [x] 5.5 Write failing unit test: no agent→agent imports; no direct R2 SDK in `export_agent.py`
- [x] 5.6 Implement `app/agents/export_agent.py` (minimal PDF generator OK — e.g. reportlab/`fpdf` or stdlib-friendly builder behind a small internal helper; keep deps minimal and pinned)
- [x] 5.7 Review vs OpenSpec pdf-export “Multi-section PDF export” + “Export Agent and storage”; fix; commit

---

## 6. Security Agent (clear `run()` responsibilities)

**`run()` responsibility (STEP 3.6):** validate/sanitize agent-bound payloads for a document/job context — e.g. reject oversized text, strip/flag disallowed content patterns, enforce simple allow-lists on intents/fields, attach a security verdict to `AgentResult.data`. Not a full WAF; not Flutter auth UI.

- [x] 6.1 Write failing unit tests: `SecurityAgent` `name == "security"`; `run` accepts `input` with `action`/`payload` (or equivalent) + uses `AgentContext` user/document ids in metadata
- [x] 6.2 Write failing unit tests: allowed payload → `success=True`, `data={allowed: true, checks: [...]}` (or equivalent structured verdict)
- [x] 6.3 Write failing unit tests: rejected payload (oversized text, empty critical fields, blocked pattern) → `success=False` or `allowed: false` with reasons — deterministic, no LLM required unless explicitly designed; if LLM used, must go through `LLMProvider` + prompts/
- [x] 6.4 Write failing unit test: no specialist agent imports; no vendor security SDK required for v1 unit path
- [x] 6.5 Implement `app/agents/security_agent.py` with documented check list in module docstring
- [x] 6.6 Review vs agent-orchestrator “Specialized agent set” + §3.4 BaseAgent-only `run`; fix; commit

---

## 7. Notification Agent (in-app + push Protocol stub)

- [x] 7.1 Add `PushProvider` Protocol (e.g. in `adapters/protocols.py`): `async def send(user_id: str, title: str, body: str, **kwargs) -> None` (or equivalent); add `FakePushProvider` in `tests/fakes.py`
- [x] 7.2 Define in-app notification port (Protocol or injectable store): `create_notification(user_id, type, payload) -> NotificationRecord` — may be an in-memory fake for unit tests; no Flutter
- [x] 7.3 Write failing unit tests: `NotificationAgent` `name == "notification"`; DI in-app store + `PushProvider`
- [x] 7.4 Write failing unit tests for `run` input: processing-complete (and optional reminder) events with `user_id`, `job_type`/`event_type`, message fields
- [x] 7.5 Write failing unit tests: success creates in-app record **and** calls push when `push_enabled=True`; when `push_enabled=False`, in-app only; **never** sends email (assert no email API/provider call)
- [x] 7.6 Write failing unit tests: push provider failure can still return partial success metadata or shaped failure per documented contract (pick one; test it)
- [x] 7.7 Implement `app/agents/notification_agent.py` + stub `PushProvider` adapter (no-op or log-only) under `adapters/`
- [x] 7.8 Review vs OpenSpec notifications “In-app” / “Push” / “No email in v1” / “Notification Agent coordination”; fix; commit

---

## 8. Analytics Agent (clear `run()` responsibilities)

**`run()` responsibility (STEP 3.6):** accept a structured analytics event (`name`, `user_id`, properties) and emit via an `AnalyticsProvider` Protocol (PostHog-oriented; stub adapter OK). Returns `AgentResult` with emit acknowledgment. Does not call other agents; does not block product flows on analytics failure beyond documented soft-fail.

- [x] 8.1 Add `AnalyticsProvider` Protocol: `async def track(event: str, *, user_id: str | None, properties: dict) -> None`; `FakeAnalyticsProvider` records calls
- [x] 8.2 Write failing unit tests: `AnalyticsAgent` `name == "analytics"`; DI `AnalyticsProvider`
- [x] 8.3 Write failing unit tests: valid event → provider `track` called once; `AgentResult(success=True, data={event, tracked: true})`
- [x] 8.4 Write failing unit tests: invalid event (missing name) → failure without calling provider; provider exception → `on_error` / soft-fail per documented choice
- [x] 8.5 Implement `app/agents/analytics_agent.py` + stub adapter (no PostHog SDK required in agent module)
- [x] 8.6 Review vs nexora_spec Analytics (PostHog) + §3.4; fix; commit

---

## 9. Master wiring — registry + LangGraph intents

### 9.A Single-intent nodes

- [x] 9.1 Write failing unit tests: registry can register/resolve each new agent name; unknown name still raises `UnknownAgentError`
- [x] 9.2 Write failing unit tests: Master `invoke` with intents `summary`, `translation`, `export`, `security`, `notification`, `analytics`, `search`, `citation` each routes to the matching node and returns that agent’s `AgentResult` (fakes for all deps)
- [x] 9.3 Extend `MasterAgent._build_graph`: add nodes for all eight agents; extend `route_intent` map; keep OCR node
- [x] 9.4 Extend `build_master_agent` / `run_master` factory to accept optional DI kwargs (`llm`, `rag_pipeline`, `storage`, `push`, `analytics`, in-app store, etc.) — only construct/register agents whose deps are provided **or** always wire all with injected fakes/adapters (pick one factory style; document it; prefer explicit required deps for agents under test)

### 9.B Search → Citation sequence (Master-only)

- [x] 9.5 Write failing unit tests for multi-step intent (e.g. `"ask"` or `"rag_chat"`): Master runs Search node then Citation node; Citation input is taken from Search `AgentResult.data` + original question — **neither agent imports the other**
- [x] 9.6 Write failing behavioral test: empty Search context → Citation still invoked by Master with empty chunks and returns cannot-answer shape (or Master short-circuits — document choice and test it)
- [x] 9.7 Implement graph edges/state handoff for Search→Citation (state may carry `search_result` / intermediate fields in `MasterGraphState`)
- [x] 9.8 Review vs OpenSpec “Master Agent orchestration only” + rag-chat “Search then Citation”; fix; commit

---

## 10. Coupling tests extended + thin invoke hooks

- [x] 10.1 Extend `SPECIALIZED_AGENT_MODULES` in `tests/test_agent_coupling.py` to include all eight new `*_agent` modules; AST guard must fail if any specialist imports another
- [x] 10.2 Extend class-name / source guards: each specialist source must not reference other specialist class names or `MasterAgent` / `run_master`
- [x] 10.3 Update `test_only_master_may_import_specialized_agents` expectations: `master_agent.py` may import all registered specialists
- [x] 10.4 Optional thin hook (only if needed for invoke path): Celery task or minimal service function that calls `run_master` for summary/translation/export/ask — **no** Flutter; **no** full ChatService product polish; keep status mapping consistent with existing job patterns if a task is added
- [x] 10.5 Write failing/updated tests proving thin hook (if added) never imports specialist agents except via Master
- [x] 10.6 Review vs OpenSpec “Reject direct agent coupling”; fix; commit

---

## 11. Shared fixtures + pytest green

- [x] 11.1 Add/extend fixtures: `FakeLLMProvider` responses for summary/translation/citation JSON-ish text; `FakePushProvider`; `FakeAnalyticsProvider`; Master factory with all nodes; sample Search→Citation state; PDF section payload fixtures
- [x] 11.2 Ensure new agent tests use shared fakes; default suite makes no network LLM/push/analytics calls
- [x] 11.3 Run full `backend` `pytest` suite green (STEP 3.3–3.5 behaviors preserved, including OCR Master path + RAG ingest/query)
- [x] 11.4 Review fixture hygiene; fix; commit

---

## 12. Reviewer gate checkpoints (STEP 3.6)

Run after §§1–11 land; blockers must be fixed before declaring STEP 3.6 done.

- [ ] 12.1 **BaseAgent gate:** all eight new agents subclass `BaseAgent`, implement only `run()`, use default or override `on_error`; return `AgentResult`
- [ ] 12.2 **Master-only orchestration gate:** no specialized-agent→specialized-agent imports; Search→Citation only via Master graph state; Celery/services enter via Master
- [ ] 12.3 **LLM / prompts gate:** Summary, Translation, Citation (and any other LLM-using agent) use `LLMProvider` + `prompt_loader` / `prompts/`; no inlined prompt bodies; no vendor SDK in `app/agents/`
- [ ] 12.4 **Search/RAG gate:** Search Agent uses `RagPipeline`/`HybridRetriever` query path; does not invent final answers; Citation shapes citations separately
- [ ] 12.5 **Translation languages gate:** EN↔ES, FR, DE, HI, PT validated; unsupported rejected
- [ ] 12.6 **Export PDF gate:** section toggles honored; upload + signed URL via `StorageProvider`
- [ ] 12.7 **Notification gate:** in-app + push hooks; push behind Protocol/stub; no email in v1 path
- [ ] 12.8 **Security + Analytics gate:** each has documented `run()` responsibilities and unit tests covering allow/deny or track/fail paths
- [ ] 12.9 **Scope gate:** no Flutter features; no full ChatService HTTP product polish beyond optional thin Master hooks; no CI/CD work
- [ ] 12.10 Final review vs `openspec/specs/agent-orchestrator/spec.md` + agent-side requirements in summarization / translation / rag-chat / pdf-export / notifications + architecture §3.4; fix remaining gaps; commit “agent-orchestrator STEP 3.6 specialized agents DoD met”

---

## Definition of Done (STEP 3.6)

- [ ] Summary, Translation, Search, Citation, Export, Security, Notification, Analytics agents implemented against `BaseAgent`
- [ ] Each registered in Master node registry / LangGraph; OCR still works; Search→Citation sequenced by Master only
- [ ] Search uses RagPipeline/HybridRetriever; Citation shapes citations; no agent→agent calls
- [ ] Translation supports EN↔ES, FR, DE, HI, PT with validation
- [ ] Export produces PDF with section toggles; stores via StorageProvider; returns signed URL
- [ ] Notification supports in-app + push Protocol stub; no email
- [ ] Security + Analytics have clear, tested `run()` responsibilities
- [ ] Versioned prompts under `prompts/`; LLM via Protocol
- [ ] Coupling tests cover all specialized agents
- [ ] Full backend pytest green; STEP 3.4/3.5 behaviors preserved
- [ ] Reviewer gates 12.1–12.10 passed
- [ ] No Flutter / full ChatService polish / CI/CD in this step
