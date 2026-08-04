## Context

Authoritative inputs are `spec/nexora_spec.md`, `spec/architecture.md`, and `spec/ui_design_system.md`. Main `openspec/specs/` is empty (greenfield). Architecture §7 open questions are resolved: Supabase Auth, Mistral OCR, Gemini (OpenAI fallback), subscription built but flagged off, Cloud Run. See proposal.md for motivation and capability list.

## Goals / Non-Goals

**Goals:**
- Establish 14 OpenSpec capabilities aligned 1:1 with architecture module boundaries and the UI component inventory.
- Encode launch defaults and v1 product constraints as testable requirements for orchestrated sub-agents.
- Define the technical approach and execution gates so STEP 2 planners can break work into small TDD loops without reinventing contracts.

**Non-Goals:**
- Implementing Flutter/FastAPI/agent code in this change.
- Writing `database.md`, `api_contract.md`, or other follow-on docs from nexora_spec §11 (tracked as later planning inputs).
- Choosing final brand hex/typefaces now (Design System Agent selects within mood and documents tokens).

## Decisions

### 1. One bootstrap change, then archive
**Choice:** Single change `initialize-nexora-openspec` with delta specs for all 14 capabilities; archive into main specs after sign-off.  
**Why:** One reviewable STEP 1 unit; matches greenfield convention.  
**Alternative:** One change per capability — rejected as fragmented for initial bootstrap.

### 2. Adapter defaults (DI bindings)
| Concern | Default | Alternate kept |
|---------|---------|----------------|
| Auth | Supabase Auth | Clerk adapter |
| OCR | Mistral OCR | Google Document AI |
| LLM | Gemini | OpenAI |
| Storage | Cloudflare R2 | (interface only) |
| Hosting | Cloud Run | Railway not used for v1 |

**Why:** Ecosystem fit (Postgres/Supabase; Gemini multimodal/RAG cost; cheaper OCR path; Cloud Run scaling/IAM).  
**Alternative:** Clerk/Document AI/OpenAI/Railway — deferred as adapter swaps.

### 3. Layering enforcement
- Flutter: feature-first clean architecture; cross-feature only via `core/` entities, domain providers, or GoRouter.
- Backend: routers → services → repositories; adapters only via Protocols.
- Agents: Master Agent / LangGraph only; BaseAgent for all specialists.
- UI: features compose `core/design_system` only; new atoms require ui_design_system + Design System Agent first.

### 4. Flutter version
**Choice:** Latest stable Flutter 3.x at implementation time.  
**Why:** Flutter 4.x is not available; correct docs to reality.  
**Alternative:** Block on Flutter 4 — rejected.

### 5. Product v1 constraints baked into specs
- Languages: EN ↔ ES, FR, DE, HI, PT  
- PDF: summary + translation + chat annotations with per-section toggles  
- Notifications: in-app + push; no email  
- Quotas (config): 20 docs/month, 100 chats/day, 500 OCR pages/month; paywall UI flagged off  
- Web input: camera when available + file upload via DocumentInputSource  

### 6. Execution order (orchestrator gate)
1. This OpenSpec + sign-off  
2. Design system DoD (`ui_design_system.md` §7)  
3. Backend core + adapters  
4. BaseAgent + Master + OCR  
5. RAG pipeline  
6. Remaining agents  
7. Frontend features sequentially  
8. CI/CD  
9. Final DoD vs nexora_spec §12  

## Risks / Trade-offs

- [Mistral OCR accuracy on dense scans] → Keep Document AI adapter ready; switch via DI if metrics fail.  
- [Quota enforcement with paywall hidden may confuse users] → Clear quota errors; flag enables upgrade UX later without new limit logic.  
- [Large bootstrap spec set drifts from later detail docs] → Treat OpenSpec as behavioral SoT after archive; expand with new changes, don’t silently edit three ways.  
- [Flutter 3.x “latest stable” moves over time] → Pin in CI when project is scaffolded; refresh deliberately.  
- [Agent graph complexity early] → Ship Master + OCR first; add agents incrementally per execution order.

## Migration Plan

1. User signs off on this change’s proposal, specs, design, and tasks.  
2. Archive change → populate `openspec/specs/<capability>/spec.md`.  
3. Optionally align `spec/nexora_spec.md` Flutter version wording to 3.x in a tiny follow-up (docs-only).  
4. STEP 2 Planner Agent produces per-capability task loops against archived specs.  
5. Rollback: if sign-off rejects, revise delta specs in-place before archive; do not start design-system implementation.

## Open Questions

None that block STEP 1. Deferred intentionally: concrete brand palette/typefaces (Design System Agent), exact OpenAPI field schemas (`api_contract.md` follow-on), push provider vendor selection within notifications implementation.
