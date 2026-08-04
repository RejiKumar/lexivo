# RAG Pipeline STEP 3.5 Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | rag-pipeline |
| **Reviewer** | Reviewer Agent (independent) |
| **Date** | 2026-08-04 |
| **Sources** | `spec/architecture.md` §3.5 (+ §3.1 `rag/` layout), `openspec/specs/rag-pipeline/spec.md`, `openspec/plans/rag-pipeline-tasks.md` §11 + DoD |
| **Claimed** | RagPipeline ingest/query, HybridRetriever, RagConfig, document_chunks, Celery generate_embeddings; 152 passed / 1 skipped; §11 left open |
| **Verdict** | **PASS** |

---

## Verdict

**PASS** — STEP 3.5 RAG pipeline Definition of Done is met. Plan gates 11.1–11.7 all pass. Independent `pytest` in `backend/` matches the claimed suite: **152 passed, 1 skipped**.

**Is STEP 3.5 DoD met?** **Yes.**

**May STEP 3.6 (remaining specialized agents) proceed?** **Yes.**

---

## Gate-by-gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | RagConfig parameterization — chunk size/overlap/strategy via config; contract vs receipt on same modules | **PASS** |
| 11.2 | HybridRetriever merges pgvector + BM25/keyword; no separate vector DB product | **PASS** |
| 11.3 | Persistence — ingest writes `document_chunks` with embeddings; queryable by `document_id` | **PASS** |
| 11.4 | API surface — `ingest` + `query` match §3.5; callable from task/service without ChatService/Search | **PASS** |
| 11.5 | No type-branch — no per-document-type control flow in `app/rag/` pipeline modules | **PASS** |
| 11.6 | Scope — no Search/Citation/Summary/… agents; no Flutter `rag_chat`; no ChatService wiring | **PASS** |
| 11.7 | Final vs OpenSpec rag-pipeline + architecture §3.5 | **PASS** |
| — | `pytest` in `backend/` green | **PASS** (152 passed, 1 skipped, 1 warning) |

---

## Evidence

### 11.1 RagConfig parameterization gate

- `app/rag/config.py`: `RagConfig` requires `chunk_size` / `chunk_overlap`, defaults `strategy` (`fixed` \| `paragraph`), plus `top_k`, dense/keyword weights, optional `max_context_chars`; overlap ≥ size rejected.
- Callers supply config; `Chunker` dispatches only on `config.strategy` via a handler map — not document type.
- Presets (`CONTRACT_CONFIG` / `RECEIPT_CONFIG`) live in `app/rag/presets.py` (allowed by plan); pipeline modules do not switch on type names.
- Behavioral proof: `test_ingest_uses_config_not_type_branch`, `test_two_configs_same_pipeline_code_path` — same `RagPipeline` / `Chunker`, different configs → different chunk counts.

### 11.2 HybridRetriever gate

- `app/rag/retriever.py`: `HybridRetriever.retrieve` runs dense + keyword paths, merges via RRF (`_rrf_merge`), returns top-k `RankedChunk`s.
- Postgres: pgvector cosine (`<=>`) + `ts_rank_cd` / `to_tsvector` (BM25-style).
- Non-Postgres unit path: in-process cosine + token overlap (documented; keeps default suite green).
- No Pinecone / Chroma / Weaviate clients or deps anywhere in the repo (grep clean aside from an explicit “no …” docstring).

### 11.3 Persistence gate

- Model `DocumentChunk` (`document_chunks`): FK to `documents` with cascade, `chunk_index`, `content`, `embedding` via `EmbeddingVector`, timestamps.
- Alembic `0002_rag_chunks`: `extracted_text` on documents; Postgres `vector` extension + `Vector()` column; SQLite TEXT JSON fallback for tests.
- `DocumentChunkRepository.replace_for_document` / `list_by_document`; ingest clears/replaces prior chunks (idempotent re-ingest tested).
- Coverage: `tests/test_rag_chunks_model.py`, `tests/test_rag_pipeline.py` (`test_ingest_persists_chunks_and_is_idempotent`).

### 11.4 API surface gate

- Architecture §3.5 surface satisfied:
  - `async def ingest(self, document: Document, config: RagConfig) -> None`
  - `async def query(self, document_id: str, question: str) -> RagAnswer`
- Constructor also takes `ContextBuilder` + `chunk_store` (plan-required composition); optional `config=` on `query` is additive and compatible with the architecture signature.
- Celery `app/tasks/embeddings.py` `generate_embeddings` resolves `RagConfig` via presets and calls `RagPipeline.ingest` — no Master / Search / Citation imports.
- `RagAnswer` returns retrieval `context` + ranked `chunks`; `answer=None` (LLM composition out of scope; ready for future ChatService).

### 11.5 No type-branch gate

- Static guard `tests/test_rag_no_type_branch.py` scans pipeline modules (`chunker`, `embedder`, `retriever`, `context_builder`, `pipeline`, `config`, `types`) for `document_type` / contract|receipt|paper control-flow patterns + AST `If` on `document_type`.
- Independent source review: no `if document_type` (or similar) in pipeline modules; type names only as preset keys in `presets.py`.

### 11.6 Scope gate

- Agents under `app/agents/`: `base_agent`, `master_agent`, `ocr_agent` only — no Search / Citation / Summary / Translation / Export / Security / Notification / Analytics.
- No Flutter `rag_chat` feature; no `ChatService` implementation (only a docstring reference in `types.py`).
- OCR task persists `extracted_text` only; does not call RAG from Master (plan-aligned).

### 11.7 Final vs OpenSpec + architecture

| OpenSpec requirement | Status |
|---|---|
| Parameterized ingest/query without per-type pipeline branches | Met |
| HybridRetriever (pgvector + BM25/keyword), no separate vector DB | Met |
| Embeddings in PostgreSQL pgvector / `document_chunks` | Met (Postgres path + SQLite test fallback) |
| Reusable by features (callable; ChatService not implemented here) | Met |

Layout matches architecture §3.1 `rag/` (`chunker`, `embedder`, `retriever`, `context_builder`) plus plan extras (`config`, `pipeline`, `presets`, `types`).

### Pytest

Independent run in `backend/` (`python -m pytest -q --tb=line`):

```
152 passed, 1 skipped, 1 warning in 8.25s
```

Skipped test: `test_hybrid_postgres_pgvector_integration` (`@pytest.mark.postgres`) when Postgres+pgvector URL is not configured — allowed by plan §5.5 / review brief.

---

## Findings

### Blockers

None.

### Non-blocking notes

1. **Constructor vs architecture sketch** — Architecture shows `__init__(chunker, embedder, retriever)` only; implementation also injects `ContextBuilder` and `DocumentChunkRepository`. This matches the task plan and does not break the required `ingest` / `query` surface.
2. **Postgres hybrid path not exercised in this local run** — Unit/SQLite hybrid path is covered; full pgvector+FTS integration remains skip-marked until `LEXIVO_POSTGRES_URL` (or equivalent) is set. Acceptable for STEP 3.5 DoD as written.
3. **Plan §11 checkboxes** — Still unchecked in `rag-pipeline-tasks.md` (as claimed). This review closes the reviewer gate; implementers may mark 11.1–11.7 and the DoD reviewer line after accepting this PASS.

---

## STEP 3.6 readiness

STEP 3.6 (remaining specialized agents: Summary, Translation, Search, Citation, Export, Security, Notification, Analytics; Master graph wiring for Search/Citation) **may proceed**.

Consumers of this pipeline (Flutter `rag_chat`, `ChatService.ask` → `RagPipeline.query`, Search/Citation agents) remain correctly deferred.
