# Lexivo — Product Specification

> **Status:** Draft v1.1  
> **Canonical product SoT:** `spec/spec.md`  
> **Purpose:** Features and product requirements only. Technical depth (architecture, design system, agents, RAG, DB, API) lives in sibling `spec/*.md` files. Operational concerns (security, testing, CI/CD, deployment, environments) live in `docs/*.md`.

**Core design principle:** everything is a reusable component. No screen, agent, API route, or widget should be built as a one-off. Every UI element lives in a shared design system; every AI capability lives behind a shared agent interface; every backend concern lives in a shared, swappable service module.

---

## 1. Overview

**Product name:** Lexivo

**One-line pitch:** An AI-native document assistant that lets users scan, understand, translate, and interrogate any document — on mobile or web — through a fast, agent-powered RAG pipeline.

**Target platforms:** Android, iOS, Web (single Flutter 3.x codebase). Desktop (Windows) is a future phase, not part of v1.

**Primary users:** Students, professionals, and small businesses who deal with paperwork, contracts, receipts, research papers, or reports and want fast answers without reading the whole document.

**Default technology choices (product-level):**
| Concern | Default | Notes |
|---------|---------|--------|
| Client | Flutter 3.x | Single codebase; adaptive layouts required |
| Auth | Supabase Auth | Default; other providers via adapter only |
| OCR | Mistral OCR | Swappable via adapter |
| LLM | Gemini | Swappable via shared LLM adapter |
| Subscription / paywall | Feature-flagged **off** at launch | Built, but not enforced until enabled |
| Ads | AdMob (free tier) | Suppressed for premium / paid users |
| Localization | `en` default | Zero hardcoded UI strings (intl / ARB) |

**Non-goals for v1:**
- No team / multi-user collaboration (future phase)
- No handwriting-specific OCR tuning (future phase)
- No offline LLM inference (offline mode is limited to local caching/queueing, not on-device generation)
- No email notifications (future phase only; in-app / push processing notifications remain in scope where specified)
- Not building the “Productivity Hub” super-app yet — Lexivo is scoped to one strong vertical, architected so a super app can be assembled later from the same reusable components

**Repository layout (target):** Product code is intended to live under a structured monorepo layout documented in architecture. **Today, application code may still live at the repository root**; treat the target layout as the destination for migration, not a blocker for v1 feature work.

---

## 2. Core Features (v1 scope)

| # | Feature | Description |
|---|---------|-------------|
| 1 | Camera document scan | Capture a document via device camera with edge detection/crop |
| 2 | OCR text extraction | Convert scanned image/PDF into clean structured text (Mistral OCR default) |
| 3 | Document summarization | AI-generated short and detailed summaries |
| 4 | Translation | Translate extracted text into supported target languages |
| 5 | Ask-the-document (RAG chat) | Conversational Q&A grounded in the uploaded document via retrieval |
| 6 | Export to PDF | Re-export summary/translation/annotated content as a clean PDF |
| 7 | Cloud sync | Documents, chats, and summaries sync across devices |
| 8 | Auth & account | Sign up/sign in (Supabase Auth default), session management, account settings |
| 9 | Notifications | Processing-complete and reminder notifications (in-app / push). **Email notifications are out of scope for v1** (future only) |
| 10 | Subscription / paywall (post-MVP toggle) | Usage limits and paid tier, built but feature-flagged **off** for launch if not ready |
| 11 | Localization infrastructure | `intl` + ARB; default locale `en`; **no hardcoded user-facing UI strings** anywhere in feature or design-system code |
| 12 | Adaptive layouts | Distinct, intentional layouts for mobile, tablet, and desktop/web viewports — responsive scaling alone is **not** sufficient |
| 13 | Ads (free tier) | AdMob (or equivalent) ad placements for free-tier users; ads **must be suppressed** for premium / subscribed users |
| 14 | App upgrade (soft + force) | Server-driven soft update prompts and hard/force update gates when the client is below a required minimum version |

Every feature above must be delivered as an independent, testable **capability module** and an independent **feature-first Flutter module**. No feature may directly reach into another feature's internals — they only communicate through defined contracts (state providers, API clients, agent interfaces, ads/upgrade adapters).

---

## 3. High-Level Architecture

```
Flutter (Mobile + Web) — adaptive layouts, l10n, ads + upgrade hooks
        │  REST (OpenAPI-typed client, generated)
        ▼
   FastAPI (Python)
        │
        ├── Auth (Supabase Auth default, adapter-swappable)
        ├── Core API (documents, chats, users, exports, app config)
        ├── Queue producer (Celery tasks)
        │
        ▼
   PostgreSQL (+ pgvector)         Redis (cache + broker)
        │                                │
        ▼                                ▼
  Object Storage (R2)              Celery Workers
                                          │
                                          ▼
                                  Agent Orchestrator (LangGraph)
                                          │
        ┌─────────────┬─────────────┬────┴─────────┬─────────────┐
        ▼             ▼             ▼              ▼             ▼
   OCR Agent     Summary      Translation    Search/RAG     Export/PDF
   (Mistral)     Agent        Agent          Agent          (+ others)
                                          │
                                          ▼
                                  Gemini (via shared LLM adapter)
```

**Guiding rule:** every box must be replaceable without touching the boxes around it (e.g., swapping Gemini for another LLM, or Supabase Auth for another provider) via one adapter — not an app-wide rewrite.

**Full system design:** see [`architecture.md`](architecture.md) (module boundaries, folder structures, contracts, agent topology, RAG pipeline detail).

---

## 4. Frontend Requirements (summary)

**Stack (product constraints):** Flutter 3.x · Riverpod · GoRouter · Freezed · Drift · Dio (single generated API client) · Material 3 + token-based design system · intl/ARB localization.

**Architecture pattern:** Feature-first + Clean Architecture. Each feature folder is self-contained and exposes a public barrel API only. Features may depend on `core/`, never on another feature's internals.

**Design system:** All screens compose from `core/design_system` components and tokens. No one-off visual widgets in feature code. Visual direction and component inventory: [`ui_design_system.md`](ui_design_system.md).

**Adaptive layouts (required):**
- Provide **purpose-built** layouts for mobile, tablet, and desktop/web breakpoints (e.g., bottom nav vs side rail, multi-pane document + chat on large screens).
- “Looks fine when stretched” responsive-only behavior is **insufficient** for DoD.
- Navigation and chrome must adapt by form factor using design-system navigation primitives.

**Localization (required):**
- Default locale: **English (`en`)**.
- All user-facing strings live in ARB / intl resources — **zero hardcoded UI strings** in Dart UI code (features and design system).
- Adding a locale later must not require rewriting screens.

**Ads & upgrade hooks (product):**
- Free-tier users may see AdMob placements behind a shared ads adapter; premium users must never see ads.
- Soft-update and force-update flows are first-class product behaviors with shared hooks (version check → prompt or blocking gate).

**Detail:** frontend layering, `core/` layout, and feature folder rules → [`architecture.md`](architecture.md). Visual tokens and components → [`ui_design_system.md`](ui_design_system.md).

---

## 5. AI Agents / RAG (summary)

**Orchestration:** LangGraph-based master agent coordinating specialized agents (OCR, summary, translation, search/RAG, export/PDF, and supporting agents). Agents share one `BaseAgent` interface; no agent calls another agent directly.

**Defaults:** OCR → Mistral; generation / chat → Gemini, both behind shared adapters.

**RAG (high level):** Document → OCR → chunking → embeddings → pgvector → hybrid retrieve → context build → LLM. Chunking, embedding, and retrieval are reusable pipeline modules, not chat-only one-offs.

**Detail:** agent topology, contracts, prompts, and RAG design → [`architecture.md`](architecture.md) (and follow-on agent/RAG specs as they exist).

---

## 6. Backend (summary)

**Stack (product constraints):** FastAPI · PostgreSQL + pgvector · SQLAlchemy · Alembic · Redis · Celery · Cloudflare R2 · Supabase Auth (default) · REST + OpenAPI-generated Flutter client.

**Patterns:** Thin routers → service layer → repositories → adapters (storage, auth, LLM, OCR). Celery tasks are single-purpose and composable. Domain concepts (documents, chats, exports, users, app config for upgrade/ads flags) follow a consistent service shape.

**Detail:** service boundaries, adapters, jobs, and data model overview → [`architecture.md`](architecture.md).

---

## 7. Cross-Cutting Product Requirements

These are product obligations. **Implementation and operational SoT** lives under `docs/` — keep this section to requirements and pointers only.

| Concern | Product requirement | Source of truth |
|---------|---------------------|-----------------|
| Logging | Client and server logging suitable for development; **debug-level / verbose logs must not ship enabled in production builds** | Implementation conventions in architecture / engineering docs |
| Security & privacy | Auth via Supabase (default); signed object URLs; PII/document protection; rate limits and quotas applied consistently | [`docs/security.md`](../docs/security.md) |
| Testing | Shared fixtures; unit/widget/integration coverage of business logic and adapters; golden coverage at design-system level | [`docs/testing-strategy.md`](../docs/testing-strategy.md) |
| CI / CD | Automated lint, test, and build gates on PRs; reusable workflows | [`docs/ci-cd.md`](../docs/ci-cd.md) |
| Deployment | Web + backend deploy paths; mobile store pipelines | [`docs/deployment-guide.md`](../docs/deployment-guide.md) |
| Environments | Distinct env configs (e.g. local / staging / production) without leaking secrets into the client | [`docs/environment-strategy.md`](../docs/environment-strategy.md) |
| Observability | Production error reporting (Sentry) and product analytics (PostHog) wired for launch | Covered in deployment / environment docs as applicable |

Do **not** duplicate full CI pipelines, threat models, test matrices, or env matrices in this product spec — update the linked docs instead.

---

## 8. Definition of Done (v1 launch)

- [ ] Auth working end-to-end with **Supabase Auth** (sign up, sign in, session persistence)
- [ ] Document scan → OCR (Mistral) → summary → translation → chat pipeline working on **mobile and adaptive web** (tablet/desktop layouts included, not phone-stretched-only)
- [ ] Export to PDF working
- [ ] Cloud sync across devices
- [ ] In-app / push notifications for job completion (email **not** required for v1)
- [ ] Design system fully in place with no one-off widgets in feature code
- [ ] **Localization:** default `en` ARB wired; **no hardcoded user-facing UI strings**
- [ ] **Adaptive layouts** reviewed for mobile, tablet, and desktop/web entry points
- [ ] **Ads hooks:** AdMob (or adapter) integrated for free tier; ads suppressed for premium
- [ ] **App upgrade hooks:** soft update prompt and force-update gate driven by server/config
- [ ] Subscription / paywall code present but **feature-flagged off** at launch if not ready
- [ ] All agents implemented against the shared `BaseAgent` interface; LLM via Gemini adapter by default
- [ ] Business-logic test coverage meets the bar in [`docs/testing-strategy.md`](../docs/testing-strategy.md)
- [ ] CI green per [`docs/ci-cd.md`](../docs/ci-cd.md); deploy paths documented in [`docs/deployment-guide.md`](../docs/deployment-guide.md)
- [ ] **Sentry** + **PostHog** wired for production

---

## 9. Explicit Reusability Checklist (apply to every PR)

- [ ] Does this PR introduce any new UI widget not built from `core/design_system`?
- [ ] Does this PR introduce **hardcoded user-facing strings** instead of intl/ARB?
- [ ] Has **adaptive layout** been considered (mobile / tablet / desktop) — or is this phone-only stretched?
- [ ] Does this PR duplicate an existing agent's plumbing instead of implementing `BaseAgent`?
- [ ] Does this PR call an LLM / OCR / storage / auth / **ads** SDK directly instead of going through the shared adapter?
- [ ] Does this PR hand-write an API call instead of using the generated client?
- [ ] Is any prompt inlined in code instead of stored in the shared `prompts/` directory?
- [ ] Do soft/force upgrade or ads placements bypass the shared hooks/adapters?

If the answer to any of the above is yes, the PR should be revised before merge.

---

## 10. Spec Document Map

| Document | Role |
|----------|------|
| `spec/spec.md` | **This file** — product features & requirements (canonical) |
| `spec/architecture.md` | System architecture, modules, adapters, agents/RAG overview |
| `spec/ui_design_system.md` | Design tokens, components, visual rules |
| `docs/security.md` | Security & privacy SoT |
| `docs/testing-strategy.md` | Testing SoT |
| `docs/ci-cd.md` | CI/CD SoT |
| `docs/deployment-guide.md` | Deployment SoT |
| `docs/environment-strategy.md` | Environments SoT |

Follow-on product/tech specs (`database.md`, `api_contract.md`, agent/RAG deep-dives, etc.) expand sections without changing the product scope locked here unless this file is deliberately revised.
