## Why

Nexora has authoritative product, architecture, and design-system documents, but no structured OpenSpec capability set for orchestrated, TDD-driven implementation. Converting those docs into OpenSpec now locks module boundaries, adapter defaults, and UI contracts before any feature code is written.

## What Changes

- Bootstrap OpenSpec in the Nexora repo and introduce **14 new capabilities** matching `architecture.md` module boundaries.
- Encode resolved launch defaults: Supabase Auth, Mistral OCR, Gemini LLM (OpenAI fallback), subscription built but feature-flagged off, Cloud Run hosting.
- Correct Flutter target to latest stable **3.x** (not 4.x) for implementation reality.
- Capture v1 product constraints: translation languages EN↔ES/FR/DE/HI/PT; PDF export of summary + translation + chat annotations; in-app + push notifications (no email); free-tier caps as config; web document input via camera + file upload behind one abstraction.
- After sign-off, archive this change into main specs so STEP 2 planners/implementers consume a single source of truth.

## Capabilities

### New Capabilities
- `design-system`: Token set (§2) and reusable components (§3) from `ui_design_system.md`, gated by its Definition of Done before feature UI.
- `auth`: Sign up/sign in, session persistence, account settings via Supabase Auth adapter.
- `document-scan`: Camera capture with edge detect/crop and file-upload fallback via a single DocumentInputSource abstraction (mobile + web).
- `ocr`: OCR text extraction through OCRProvider (default: Mistral OCR).
- `summarization`: Short and detailed AI summaries via Summary Agent.
- `translation`: Translate extracted text EN↔ES/FR/DE/HI/PT via Translation Agent.
- `rag-chat`: Ask-the-document conversational Q&A with citations via Search/Citation agents and RAG pipeline.
- `pdf-export`: Export summary, translation, and chat annotations as PDF with per-section toggles.
- `notifications`: In-app + push notifications for job completion and reminders (no email in v1).
- `subscription`: Usage limits and paid tier, built but feature-flagged off at launch; caps as config.
- `agent-orchestrator`: BaseAgent contract, Master Agent (LangGraph), and all specialized agents; no agent-to-agent direct calls.
- `rag-pipeline`: Chunker, embedder, HybridRetriever, context builder parameterized by RagConfig.
- `backend-services`: FastAPI service layer, repositories, and adapter Protocols (LLM/OCR/Storage/Auth); thin routers only.
- `ci-cd`: Reusable GitHub Actions composite workflows; deploy Flutter web + FastAPI/Celery to Cloud Run + Cloudflare Pages.

### Modified Capabilities
- (none — greenfield; main `openspec/specs/` is empty)

## Impact

- Creates `openspec/changes/initialize-nexora-openspec/` planning artifacts and, after archive, main specs under `openspec/specs/<capability>/spec.md`.
- Does not implement application code in this change; it is the planning gate before design-system and backend work.
- Downstream: Design System → Backend core → Agents → RAG → Frontend features → CI/CD, per orchestrator execution order.
- External systems locked as defaults: Supabase Auth, Mistral OCR, Gemini, Cloudflare R2, Neon Postgres+pgvector, Redis, Celery, Cloud Run, Cloudflare Pages, Sentry, PostHog.
