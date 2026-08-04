## 1. Sign-off and archive

- [ ] 1.1 Obtain user sign-off on proposal, all 14 delta specs, design, and this task list
- [ ] 1.2 Archive `initialize-nexora-openspec` into main `openspec/specs/`
- [ ] 1.3 Correct `spec/nexora_spec.md` Flutter version wording to latest stable 3.x
- [ ] 1.4 Delegate Planner Agent to produce per-capability small-task loops (spec → unit test → impl → widget/integration test → review → fix → commit)

## 2. Design system (gate — capability: design-system)

- [ ] 2.1 Implement all tokens in ui_design_system.md §2 (color light/dark, spacing, radius, elevation, typography, motion)
- [ ] 2.2 Implement all components + variants in ui_design_system.md §3
- [ ] 2.3 Add golden tests for every component variant
- [ ] 2.4 Add design_system_showcase catalog (dev-flag-gated)
- [ ] 2.5 Verify Definition of Done (ui_design_system.md §7) before any feature UI
- [ ] 2.6 Reviewer Agent: reusability checklist + no feature-model coupling

## 3. Backend core (capability: backend-services + auth domain)

- [ ] 3.1 Scaffold FastAPI layout per architecture.md §3.1; config via pydantic-settings
- [ ] 3.2 Define AuthProvider, StorageProvider, LLMProvider, OCRProvider Protocols + DI
- [ ] 3.3 Implement Supabase Auth adapter (default) and R2 Storage adapter
- [ ] 3.4 Implement Gemini LLM adapter (default) and Mistral OCR adapter (default); stub OpenAI + Document AI adapters behind same Protocols
- [ ] 3.5 Implement BaseService CRUD shape + DocumentService/UserService + repositories
- [ ] 3.6 Thin routers for auth, documents, users; OpenAPI from Pydantic schemas
- [ ] 3.7 Celery task units for upload/OCR enqueue; Docker Compose local stack
- [ ] 3.8 Unit/integration tests with shared fixtures; Reviewer Agent on adapter/service contracts

## 4. Agent architecture — Base + Master + OCR (capability: agent-orchestrator + ocr)

- [ ] 4.1 Implement base_agent.py (AgentResult, BaseAgent, on_error) with unit tests
- [ ] 4.2 Implement Master Agent LangGraph graph + node registry
- [ ] 4.3 Implement OCR Agent + prompt templates; wire Celery → Master → OCR
- [ ] 4.4 Tests proving no agent-to-agent direct calls; Reviewer Agent pass

## 5. RAG pipeline (capability: rag-pipeline)

- [ ] 5.1 Implement Chunker, Embedder, HybridRetriever, context_builder, RagPipeline + RagConfig
- [ ] 5.2 Persist document_chunks with pgvector; ingest/query unit tests
- [ ] 5.3 Reviewer Agent: parameterized by config, no per-type code branches

## 6. Remaining specialized agents (capability: agent-orchestrator)

- [ ] 6.1 Summary Agent + tests
- [ ] 6.2 Translation Agent (EN↔ES/FR/DE/HI/PT) + tests
- [ ] 6.3 Search Agent + Citation Agent + tests
- [ ] 6.4 Export Agent + Security Agent + tests
- [ ] 6.5 Notification Agent + Analytics Agent + tests
- [ ] 6.6 Reviewer Agent: BaseAgent + prompts/ + LLMProvider only

## 7. Frontend features (one at a time; after design-system DoD)

- [ ] 7.1 Generate Flutter OpenAPI client; core network/routing/utils (Result, job_poller, async_value_view)
- [ ] 7.2 auth feature (capability: auth) — TDD loop + Reviewer
- [ ] 7.3 document_scan feature (capability: document-scan) — DocumentInputSource camera+upload + Reviewer
- [ ] 7.4 ocr result view (capability: ocr) + Reviewer
- [ ] 7.5 summarization feature + Reviewer
- [ ] 7.6 translation feature + Reviewer
- [ ] 7.7 rag_chat feature + Reviewer
- [ ] 7.8 pdf_export feature (per-section toggles) + Reviewer
- [ ] 7.9 notifications feature (in-app + push) + Reviewer
- [ ] 7.10 subscription feature (flag off; config caps) + Reviewer

## 8. CI/CD (capability: ci-cd)

- [ ] 8.1 Reusable composite workflows: lint, test, build
- [ ] 8.2 Flutter web → Cloudflare Pages; backend/workers → Cloud Run
- [ ] 8.3 Android APK/AAB build job; OpenAPI client regen check
- [ ] 8.4 Wire Sentry + PostHog for production configs
- [ ] 8.5 Reviewer Agent: no copy-pasted per-env workflows

## 9. Final Definition of Done (nexora_spec.md §12)

- [ ] 9.1 End-to-end review against §12 checklist
- [ ] 9.2 Confirm §13 reusability checklist clean on main
- [ ] 9.3 Confirm architecture contracts (service/adapter/agent) and no one-off UI widgets
