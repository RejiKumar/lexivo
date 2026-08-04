# RAG Pipeline — Task Plan
Capability: rag-pipeline
Architecture: architecture.md §3.5 (`RagPipeline`, `Chunker`, `Embedder`, `HybridRetriever`, `RagConfig` — parameterized, no per-type code branches); §3.1 `rag/` layout
OpenSpec: `openspec/specs/rag-pipeline/spec.md`
Product: Lexivo
Execution order: **STEP 3.5** — RAG pipeline + tests

**Prerequisite (completed)**
- [x] Agent orchestrator STEP 3.4 DoD PASS (`openspec/reviews/agent-orchestrator-step34-review.md`) — BaseAgent + Master + OCR; Celery → Master → OCR; `app/rag/` correctly absent until this step; this plan may proceed

**Out of scope for this file (later steps)**
- Remaining specialized agents: Summary, Translation, Search, Citation, Export, Security, Notification, Analytics (STEP 3.6)
- Master graph wiring for Search/Citation (STEP 3.6)
- Flutter `rag_chat` / ChatService calling `RagPipeline.query` (later feature steps) — pipeline must be **callable** so they can consume it later
- Changing BaseAgent/Master beyond an optional thin post-OCR ingest hook (prefer pipeline callable from service/Celery task)

**In scope (only)**
- `backend/app/rag/`: `chunker.py`, `embedder.py`, `retriever.py` (`HybridRetriever` = pgvector + BM25), `context_builder.py`, `RagPipeline` + `RagConfig` (+ types as needed)
- `ingest(document, config)` and `query(document_id, question)`
- `document_chunks` persistence with pgvector embeddings
- Unit/integration tests with fakes (`FakeEmbedder`, in-memory or SQLite-friendly chunk store where pgvector unavailable; Postgres+pgvector for hybrid integration)
- Optional thin Celery `generate_embeddings` (or equivalent) that calls `RagPipeline.ingest` — composable unit, not agent graph work

**Conventions**
- Loop per chunk: failing unit test → implement → integration test (where noted) → review vs OpenSpec + architecture §3.5 → fix → commit.
- Pipeline code is **config-parameterized only** — never `if document_type == "contract"` (or receipt/paper) branches inside chunker/embedder/retriever/pipeline.
- `RagConfig` carries chunk size / overlap / strategy (and any other knobs); callers pick the config; pipeline stays type-agnostic.
- `HybridRetriever` merges dense (pgvector similarity) + keyword (BM25 / Postgres FTS ranked as BM25-style) into one ranked context set — **no** separate vector DB product (Pinecone/Chroma/Weaviate).
- Prefer Protocols/DI for embedding backends; use fakes in unit tests.
- Prefer small sequential commits; never one giant “rag” commit.
- Prefix layout: `backend/app/rag/` per architecture.md §3.1.

**Current state (migration note)**
- STEP 3.4 complete: OCR text returned in `AgentResult.data` but **not** persisted on `documents`; `document_chunks` table deferred; no `app/rag/` yet.
- This step must make ingestable text available (minimal document field and/or ingest input contract) and introduce `document_chunks` + pipeline.

---

## 0. `rag/` scaffold + dependencies

- [x] 0.1 Add Python deps needed for RAG (e.g. `pgvector` SQLAlchemy helpers if used; keep BM25 via Postgres `tsvector`/`ts_rank_cd` or documented equivalent — no new vector DB client libs)
- [x] 0.2 Scaffold `app/rag/` tree: `__init__.py`, stubs for `chunker.py`, `embedder.py`, `retriever.py`, `context_builder.py`, `pipeline.py` (or `rag_pipeline.py`), `config.py` (`RagConfig`) — **no** Search/Citation agent stubs
- [x] 0.3 Write failing smoke test that `app.rag` package imports
- [x] 0.4 Review scaffold vs architecture.md §3.1 `rag/` file list + §3.5 surface; fix; commit

---

## 1. RagConfig + shared RAG types

- [x] 1.1 Write failing unit tests for `RagConfig`: required fields include chunk size, overlap, strategy (enum/str); optional knobs (top_k, dense/keyword weights) with sensible defaults; invalid sizes (overlap ≥ chunk size, non-positive) rejected
- [x] 1.2 Write failing unit tests: two preset factories or fixtures (e.g. `contract_config` vs `receipt_config`) differ only in config values — proving parameterization without pipeline type branches
- [x] 1.3 Write failing unit tests for result types: `Chunk` (text, index/metadata), `RagAnswer` (or equivalent query return: answer context string / ranked chunks + metadata) as used by `query`
- [x] 1.4 Implement `RagConfig` + types under `app/rag/` (re-export from package `__init__` as needed)
- [x] 1.5 Review vs OpenSpec “Parameterized ingest and query” + architecture §3.5 `RagConfig`; fix; commit

---

## 2. Chunker (config-driven, no type branches)

- [x] 2.1 Write failing unit tests: given plain text + `RagConfig`, `Chunker.chunk(text, config)` returns ordered chunks respecting size/overlap; empty text → empty list
- [x] 2.2 Write failing unit tests: same text with different configs (contract vs receipt sizes) yields different chunk boundaries; chunker implementation has **no** document-type conditionals (AST/source guard optional here; full guard in §9)
- [x] 2.3 Write failing unit tests for strategy hook if config includes strategy (e.g. `fixed` vs `paragraph`): behavior changes only via config value dispatch map — not per document-type `if`
- [x] 2.4 Implement `app/rag/chunker.py`
- [x] 2.5 Review vs OpenSpec “Different configs same pipeline”; fix; commit

---

## 3. Embedder + FakeEmbedder

- [x] 3.1 Decide embedding port: dedicated `EmbeddingProvider` Protocol **or** Embedder wrapping an injectable callable/client — must not import vendor SDKs inside `rag/` modules directly (adapter/DI only). Document choice in module docstring briefly
- [x] 3.2 Write failing unit tests for `Embedder.embed(texts: list[str]) -> list[list[float]]`: stable length per text; empty input → empty output; dimension consistent for a given fake/provider
- [x] 3.3 Implement `FakeEmbedder` in `tests/fakes.py` (deterministic hash→vector) for unit/integration tests without network
- [x] 3.4 Implement `app/rag/embedder.py` depending on injected provider/fake
- [x] 3.5 Review vs architecture §3.3 Protocol/DI spirit (no SDK in rag core); fix; commit

---

## 4. `document_chunks` model + migration + repository

- [x] 4.1 Write failing migration/model tests (or Alembic upgrade check): `document_chunks` table with FK to `documents`, chunk index, text/content, embedding column (`vector` on Postgres), timestamps; cascade delete with document
- [x] 4.2 Add minimal document field for ingestable OCR/body text (e.g. `extracted_text`) **or** equivalent ingest contract so `RagPipeline.ingest` can read text without re-running OCR; migration + model update; unit test persistence round-trip
- [x] 4.3 Implement SQLAlchemy `DocumentChunk` model + Alembic revision `0002_...` (enable/use existing `vector` extension on Postgres; dialect-safe fallback for SQLite unit tests if needed — e.g. JSON/BLOB float list for non-Postgres)
- [x] 4.4 Implement `DocumentChunkRepository` (or rag-owned store port): insert chunks for document, list/delete by `document_id`, support vector similarity query on Postgres
- [x] 4.5 Optionally persist OCR text from STEP 3.4 task onto document when OCR succeeds (thin field write only — **not** calling RAG from Master); unit test that ready documents can carry text for later ingest
- [x] 4.6 Review vs OpenSpec “Embeddings storage” + nexora_spec `document_chunks` + pgvector; fix; commit

---

## 5. HybridRetriever (pgvector + BM25)

- [x] 5.1 Write failing unit tests for dense path: given stored embeddings + query vector, returns top-k by similarity scoped to `document_id`
- [x] 5.2 Write failing unit tests for keyword/BM25 path: given chunk texts + query string, returns keyword-ranked hits for that `document_id` (Postgres `tsvector`/`ts_rank_cd` or equivalent BM25-style ranking — document approach in retriever module)
- [x] 5.3 Write failing unit tests for merge: `HybridRetriever.retrieve(document_id, question, *, embed_query, config?)` combines dense + keyword into one ranked list (RRF or weighted score); duplicates collapsed; empty corpus → empty
- [x] 5.4 Implement `app/rag/retriever.py` (`HybridRetriever`) using PostgreSQL only — **no** Pinecone/Chroma/Weaviate clients
- [x] 5.5 Integration test on Postgres+pgvector (Compose or CI service): ingest-like insert → hybrid retrieve returns expected chunk for a distinctive keyword + semantic-ish fake vector; skip/mark if Postgres unavailable in local unit-only run with clear reason
- [x] 5.6 Review vs OpenSpec “Hybrid retrieval” + architecture “HybridRetriever (pgvector + BM25)”; fix; commit

---

## 6. Context builder

- [x] 6.1 Write failing unit tests: `ContextBuilder.build(chunks)` concatenates/format ranked chunks into a single context string (or structured context) suitable for later ChatService/LLM; respects max token/char budget if config provides one
- [x] 6.2 Implement `app/rag/context_builder.py`
- [x] 6.3 Review vs architecture §3.5 pipeline composition (retriever → context); fix; commit

---

## 7. RagPipeline — ingest + query

- [x] 7.1 Write failing unit tests for `RagPipeline.__init__(chunker, embedder, retriever, context_builder, chunk_store/session…)` wiring
- [x] 7.2 Write failing unit tests for `async ingest(document, config)`: chunks text via Chunker(config) → embeds → persists `document_chunks` with embeddings; re-ingest replaces or clears prior chunks for that document (define idempotent behavior and test it)
- [x] 7.3 Write failing unit tests: contract config vs receipt config on two documents → both use same pipeline modules; only chunk counts/boundaries differ (spy on chunker/embedder called with respective configs — **no** type branch in pipeline source)
- [x] 7.4 Write failing unit tests for `async query(document_id, question) -> RagAnswer`: embeds question → HybridRetriever → ContextBuilder → returns ranked context / answer payload (LLM answer composition **out of scope** — return retrieval context shaped for future ChatService; if `RagAnswer` includes optional `answer` field, leave unset or pass-through stub)
- [x] 7.5 Write failing unit test: query on unknown / non-ingested document_id fails clearly or returns empty context per documented contract
- [x] 7.6 Implement `RagPipeline` matching architecture.md §3.5 signatures: `ingest(document, config)`, `query(document_id, question)`
- [x] 7.7 Integration test with FakeEmbedder + DB: ingest document with text → assert `document_chunks` rows with embeddings → query returns context containing a known phrase
- [x] 7.8 Review vs OpenSpec parameterized ingest/query + “Reusable by features” (API ready for ChatService later, but **do not** implement ChatService); fix; commit

---

## 8. Optional thin Celery `generate_embeddings` (callable ingest)

Prefer task/service callability over Master wiring (Search comes in 3.6).

- [x] 8.1 Write failing tests for Celery task unit (e.g. `generate_embeddings(document_id, config_name|dict)`): loads document + extracted text, resolves `RagConfig`, calls `RagPipeline.ingest`; does **not** import Search/Citation agents; does **not** require Master
- [x] 8.2 Implement thin task in `app/tasks/` composing repository + pipeline factory; job_type e.g. `generate_embeddings`; status updates mirror other tasks (queued/running/succeeded/failed) without inventing new orchestration
- [x] 8.3 Optional: after OCR success in `document_processing`, enqueue embeddings **or** document how callers enqueue — either is OK; if auto-chained, keep OCR task free of chunker/retriever logic (only enqueue/call ingest helper)
- [x] 8.4 Review vs backend-services “single-purpose Celery tasks” (`generate_embeddings`) + this plan’s out-of-scope Master/Search; fix; commit

---

## 9. Parameterization / no-type-branch guard

- [x] 9.1 Write failing static/unit guard: `app/rag/` modules must not contain document-type branch patterns (`contract`/`receipt`/`paper` as control-flow type switches). Config presets may live in a `presets.py` or test fixtures only
- [x] 9.2 Write failing behavioral test: ingesting with two different `RagConfig` instances exercises one code path (same class methods); assert chunker/pipeline receive config object rather than a type string used for branching
- [x] 9.3 Adjust code until guards pass
- [x] 9.4 Review vs OpenSpec “without branching pipeline code per document type” + architecture §3.5; fix; commit

---

## 10. Shared fixtures + pytest green

- [x] 10.1 Add fixtures: sample documents with `extracted_text`, `RagConfig` presets, `FakeEmbedder`, pipeline factory, optional Postgres hybrid marker
- [x] 10.2 Ensure rag tests use shared fakes; no network embedding calls in default unit suite
- [x] 10.3 Run full `backend` `pytest` suite green (STEP 3.3 + 3.4 behaviors preserved)
- [x] 10.4 Review fixture hygiene; fix; commit

---

## 11. Reviewer gate checkpoints (STEP 3.5)

Run after §§1–9 land; blockers must be fixed before declaring STEP 3.5 done.

- [ ] 11.1 **RagConfig parameterization gate:** chunk size/overlap/strategy driven by `RagConfig`; contract vs receipt configs work on the **same** pipeline modules
- [ ] 11.2 **HybridRetriever gate:** retrieve merges pgvector similarity + BM25/keyword; no separate vector DB product
- [ ] 11.3 **Persistence gate:** successful ingest writes `document_chunks` with embeddings; queryable by `document_id`
- [ ] 11.4 **API surface gate:** `RagPipeline.ingest` + `query` match architecture §3.5; callable from task/service without ChatService/Search agent
- [ ] 11.5 **No type-branch gate:** no per-document-type code branches in `app/rag/` pipeline modules
- [ ] 11.6 **Scope gate:** no Search/Citation/Summary/… agents; no Flutter `rag_chat`; no ChatService RAG wiring required
- [ ] 11.7 Final review vs `openspec/specs/rag-pipeline/spec.md` + architecture §3.5; fix remaining gaps; commit “rag-pipeline STEP 3.5 DoD met”

---

## Definition of Done (STEP 3.5)

- [x] `RagConfig` + `Chunker` + `Embedder` + `HybridRetriever` + `ContextBuilder` + `RagPipeline` implemented under `app/rag/`
- [x] `ingest(document, config)` and `query(document_id, question)` unit- and integration-tested with fakes
- [x] `document_chunks` persisted with pgvector (Postgres); hybrid retrieval covered
- [x] Parameterization proven: different configs, same pipeline code (no per-type branches)
- [x] Pipeline usable later by ChatService / Search agent (callable API); those consumers **not** implemented here
- [x] Full backend pytest green; STEP 3.4 OCR/Master behaviors preserved
- [ ] Reviewer gates 11.1–11.7 passed
