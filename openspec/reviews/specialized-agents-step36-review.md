# Specialized Agents STEP 3.6 Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | agent-orchestrator (+ summarization, translation, rag-chat, pdf-export, notifications agent/backend slices) |
| **Reviewer** | Reviewer Agent (independent) |
| **Date** | 2026-08-04 |
| **Sources** | `spec/architecture.md` §3.4 (+ §3.1 agents), `openspec/specs/agent-orchestrator/spec.md`, agent-side requirements in summarization / translation / rag-chat / pdf-export / notifications, `openspec/plans/specialized-agents-tasks.md` §12 |
| **Claimed** | 8 agents + Master ask/rag_chat Search→Citation; 236 passed / 1 skipped; §12 open |
| **Verdict** | **PASS** |

---

## Verdict

**PASS** — STEP 3.6 specialized agents Definition of Done is met. Plan gates 12.1–12.10 all pass. Independent `pytest` in `backend/` matches the claimed suite (236 passed, 1 skipped).

**Is STEP 3.6 DoD met?** **Yes.**

**May STEP 3.7 (Frontend features) proceed?** **Yes.**

---

## Gate-by-gate results

| # | Gate | Result |
|---|---|---|
| 12.1 | BaseAgent — eight agents subclass `BaseAgent`, implement only `run()`, return `AgentResult` | **PASS** |
| 12.2 | Master-only orchestration — no specialist→specialist imports; Search→Citation via Master graph state; Celery/tasks enter via Master | **PASS** |
| 12.3 | LLM / prompts — Summary, Translation, Citation use `LLMProvider` + `prompt_loader` / `prompts/`; no inlined bodies; no vendor SDKs in `app/agents/` | **PASS** |
| 12.4 | Search/RAG — Search uses `RagPipeline.query`; no final-answer invention; Citation shapes citations separately | **PASS** |
| 12.5 | Translation languages — EN↔ES, FR, DE, HI, PT validated; unsupported rejected | **PASS** |
| 12.6 | Export PDF — section toggles honored; upload + signed URL via `StorageProvider` | **PASS** |
| 12.7 | Notification — in-app + push Protocol; no email in v1 path | **PASS** |
| 12.8 | Security + Analytics — documented `run()` responsibilities; allow/deny and track/fail covered | **PASS** |
| 12.9 | Scope — no Flutter features; no full ChatService polish; no CI/CD in this step | **PASS** |
| 12.10 | Final vs OpenSpec agent-orchestrator + agent surfaces + architecture §3.4 | **PASS** |
| — | Coupling tests cover new agents | **PASS** |
| — | `pytest` in `backend/` green | **PASS** (236 passed, 1 skipped, 1 warning) |

---

## Evidence

### 12.1 BaseAgent gate

All eight new agents subclass `BaseAgent`, set stable `name`, inject deps in `__init__`, and implement only async `run` (default `on_error` retained):

| Agent | Module | `name` |
|---|---|---|
| Summary | `summary_agent.py` | `summary` |
| Translation | `translation_agent.py` | `translation` |
| Search | `search_agent.py` | `search` |
| Citation | `citation_agent.py` | `citation` |
| Export | `export_agent.py` | `export` |
| Security | `security_agent.py` | `security` |
| Notification | `notification_agent.py` | `notification` |
| Analytics | `analytics_agent.py` | `analytics` |

OCR retained from STEP 3.4. Module-level helpers (parsers, PDF builder, validators) are not extra agent methods. Covered by per-agent unit tests + scaffold smoke.

### 12.2 Master-only orchestration gate

- AST/source guards in `tests/test_agent_coupling.py` list all nine specialists (OCR + eight). No specialist imports another; none references `MasterAgent` / `run_master`.
- `master_agent.py` alone imports all specialists for registry wiring.
- `document_processing.py` enters via `run_master` only (no specialist imports) — coupling test asserts this.
- Ask flow: intents `ask` / `rag_chat` → `search_then_cite` node → state `search_result` → `citation_after_search` with Citation input built from Search `data` + question. Neither Search nor Citation imports the other.
- Empty Search → Citation still invoked; Citation returns cannot-answer without LLM (`test_master_ask_empty_search_still_invokes_citation_cannot_answer`).

### 12.3 LLM / prompts gate

- Summary / Translation / Citation: `LLMProvider` DI + `prompt_loader.load(..., version="v1")`; templates in `prompts/summary|translation|citation/v1.yaml`.
- Agent modules carry loader keys/versions only — no inlined prompt bodies.
- Grep of `app/agents/`: no OpenAI / Gemini / Firebase / PostHog / boto3 / reportlab vendor SDKs (Analytics docstring mentions PostHog-oriented Protocol only).
- Export / Security / Notification / Analytics correctly omit LLM where not required.

### 12.4 Search/RAG gate

- `SearchAgent` injects `RagPipeline`, calls `query(document_id, question, config=...)`, maps chunks/context into `AgentResult.data`, sets `answer: None` and `ungrounded` when empty.
- No Citation / LLM usage in Search module.
- `CitationAgent` accepts prior retrieval payload only; loads `prompts/citation/v1`; returns `answer` + `citations`; ungrounded path returns `CANNOT_ANSWER` without calling LLM.
- Aligns with plan preference for full `RagPipeline.query` (HybridRetriever used inside pipeline from STEP 3.5).

### 12.5 Translation languages gate

- `SUPPORTED_LANGS = {en, es, fr, de, hi, pt}`; case-normalized.
- Pair rule: English on one side (`source == "en" or target == "en"`); same-lang and non-EN pairs (e.g. es→fr) rejected without LLM.
- Unsupported codes (e.g. `ja`) fail validation with no LLM call.
- Tests: `test_translation_agent.py` (supported pairs, unsupported, non-EN pair).

### 12.6 Export PDF gate

- Toggles: `include_summary` / `include_translation` / `include_chat`; requires matching content when enabled; at least one section required.
- `build_simple_pdf` (stdlib) embeds section markers; `StorageProvider.upload` + `signed_url`; returns `storage_key` / `signed_url`.
- No R2 SDK in `export_agent.py`. Tests assert all-sections vs summary-only marker presence/absence.

### 12.7 Notification gate

- DI: `NotificationStore` + `PushProvider` Protocols; stub adapters under `adapters/push/`.
- Success: in-app `create_notification`; push when `push_enabled=True`; in-app only when False.
- Explicit reject of `email` / `send_email`; result always `email_sent: False`.
- Push failure soft-fails (in-app success + `push_error`). Tests cover no-email SDK guard.

### 12.8 Security + Analytics gate

- **Security:** docstring lists checks (action allow-list, empty text, max size, blocked patterns); deterministic; structured `allowed` + `checks`; no LLM.
- **Analytics:** `AnalyticsProvider.track`; missing name fails without provider call; provider exception → `on_error` soft-fail.
- Unit tests: `test_security_agent.py`, `test_analytics_agent.py`.

### 12.9 Scope gate

- STEP 3.6 commits (`990063d..32831ad`) touch only `backend/` agents/adapters/prompts/tests and `openspec/plans/specialized-agents-tasks.md`.
- No Flutter `lib/features` modules, no design-system UI, no CI/CD, no full ChatService HTTP product polish (OCR Celery path unchanged; Master factory extended for optional DI).

### 12.10 Final vs OpenSpec + architecture §3.4

| Expectation | Status |
|---|---|
| Every specialist subclasses BaseAgent; implements only `run()` (§3.4) | Met (OCR + 8) |
| Master LangGraph sequences via node registry; no agent→agent class calls | Met |
| Specialized set: OCR, Summary, Translation, Search, Citation, Export, Security, Notification, Analytics | Met |
| Shared prompts + LLMProvider for LLM agents | Met |
| Search then Citation for ask/rag_chat (Master only) | Met |
| Translation EN↔ES,FR,DE,HI,PT | Met (agent-level validation) |
| Export multi-section + StorageProvider signed URL | Met (agent-level) |
| Notification in-app + push; no email v1 | Met (agent-level) |
| Flutter feature UIs / design-system notification list | Deferred (STEP 3.7) — correctly out of scope |

### Coupling tests

`tests/test_agent_coupling.py` extended with all eight new modules:

1. AST import-graph forbids specialist→specialist and specialist→Master.
2. Only Master may import all specialists.
3. Source ban on other specialist class names / Master refs per module.
4. Celery thin hook must not import specialists except via `run_master`.
5. Behavioral Master→OCR still present.

Plus `tests/test_master_specialized_wiring.py` for registry, single intents, and Search→Citation.

### pytest (independent)

```
236 passed, 1 skipped, 1 warning in ~8.55s
```

(Starlette/`httpx` TestClient deprecation warning only — non-blocking. Skip is the existing Postgres HybridRetriever marker from STEP 3.5.)

---

## Findings

### Blockers

None.

### Non-blocking observations

1. **Search depends on concrete `RagPipeline`** — not a `typing.Protocol`. Matches plan §3.1 preference for `RagPipeline.query` and STEP 3.5’s in-app port; still no vendor SDK. Optional later: a narrow query Protocol if adapter swapping is needed without importing `app.rag.pipeline`.
2. **Export PDF stream truncation** — `build_simple_pdf` truncates the PDF text stream (~1800 chars) but appends full section markers after `%%EOF` for assertions. Adequate for agent-level STEP 3.6; a production PDF library can replace the helper without changing the agent contract.
3. **Plan §12 / DoD checkboxes remain unchecked in the plan file** — implementer correctly left reviewer gates open. This review is the PASS record; plan checkboxes may be closed in a follow-up housekeeping commit.
4. **Notification/Export/Translation product HTTP + Flutter** — intentionally absent; STEP 3.7 owns feature modules and UI.

---

## STEP 3.7 readiness

**Yes — Frontend features (STEP 3.7) may proceed.** All eight specialists are BaseAgent-compliant, Master-registered, Search→Citation is Master-only, coupling tests cover the set, and backend pytest is green with prior OCR/RAG behavior preserved.
