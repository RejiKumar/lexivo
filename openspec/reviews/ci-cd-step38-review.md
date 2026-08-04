# CI/CD STEP 3.8 Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | ci-cd (GitHub Actions composites + Cloud Run + Cloudflare Pages + observability hooks) |
| **Reviewer** | Reviewer Agent (independent) |
| **Date** | 2026-08-04 |
| **Sources** | `openspec/specs/ci-cd/spec.md`, `spec/architecture.md` §6, `spec/nexora_spec.md` §8, `openspec/plans/ci-cd-tasks.md` §11, `openspec/reviews/frontend-subscription-step37-review.md` |
| **Claimed** | composites + pr/main/production workflows; OpenAPI check; Sentry/PostHog hooks; commits `ff2c129`…`f47c1c4`; §11 open |
| **Verdict** | **PASS** |

---

## Verdict

**PASS** — STEP 3.8 CI/CD Definition of Done is met. Plan gates 11.1–11.11 pass. Live staging/production deploy was not executed here (no GCP/Cloudflare credentials); that is an **acceptable partial** per the review contract — workflows, composites, and `docs/deployment.md` are complete and env-gated.

**Is STEP 3.8 CI/CD DoD met?** **Yes.**

**May final product DoD review (STEP 3.9 / nexora_spec §12) proceed?** **Yes.** Operators must still supply GitHub Environment secrets and confirm a green main run with live deploy for the §12 checkbox “CI/CD pipeline green on main, auto-deploying web + backend”; that does not block opening STEP 3.9 review.

---

## Delegation checks (requested)

| # | Check | Result |
|---|---|---|
| 1 | Composites reused (no copy-paste per env) | **PASS** — lint/test/build/deploy-cloud-run/deploy-cloudflare-pages composites; callers only pass `environment` + secrets/vars |
| 2 | PR lint/test/build present | **PASS** — Flutter analyze/test, Python lint/pytest, OpenAPI snapshot, backend image build (no push); no deploy |
| 3 | Deploy workflows env-driven | **PASS** — staging on `main` (`environment: staging`, soft-skip if vars empty); production via tag/`workflow_dispatch` + `environment: production` |
| 4 | Observability hooks present | **PASS** — backend Sentry lifespan + PostHog adapter DI; Flutter `initSentryIfConfigured` / `initPosthogIfConfigured`; empty = no-op |
| 5 | PASS/REJECT; may STEP 3.9 proceed? | **PASS** / **Yes** |

---

## Gate-by-gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Prerequisite — subscription STEP 3.7 still PASS; CI tests green | **PASS** — subscription review **PASS**; observability unit tests green (backend 9 passed; Flutter AppConfig 2 passed). Full suite not re-run this session; prior STEP 3.7 evidence stands. Live GitHub Actions run not independently observed |
| 11.2 | Composite reuse — no copy-pasted env job bodies | **PASS** — five composites under `.github/actions/`; `main.yml` / `deploy-production.yml` are thin callers |
| 11.3 | PR pipeline — analyze + flutter test + pytest (+ OpenAPI); no prod deploy | **PASS** — `pr.yml`; no `deploy` / `environment:` deploy jobs |
| 11.4 | Build artifacts — Docker + web + APK/AAB | **PASS** — main builds backend → GHCR; Flutter web + APK + AAB artifacts |
| 11.5 | Deploy targets — Pages + Cloud Run staging; production gated | **PASS** — staging Cloud Run (API + worker) + Cloudflare Pages; production Environment-gated path documented |
| 11.6 | Env config — secrets/Settings only; Compose retained | **PASS** — Settings/`dart-define`; Compose role documented; no env forks in app code |
| 11.7 | OpenAPI — snapshot enforced; codegen optional | **PASS** — `tool/check_openapi_snapshot.sh` on PR/main/production; soft codegen job; local check: **OpenAPI snapshot OK** |
| 11.8 | Observability — Sentry + PostHog hooks | **PASS** — hooks + empty-safe; secrets listed in `docs/deployment.md` |
| 11.9 | Scope — no store submit / full OTel mesh / feature rewrites | **PASS** — no store/Fastlane/OTel/Grafana automation in `.github/` |
| 11.10 | TDD / docs — tests + `docs/deployment.md` | **PASS** — observability tests green; deployment doc complete; workflow contract files present |
| 11.11 | Final vs OpenSpec ci-cd + architecture §6 + nexora_spec §8 | **PASS** — requirements covered; DoD commit message left for implementer post-review (same pattern as prior slices) |

---

## Evidence

### Commits (claimed chain)

| Commit | Summary |
|---|---|
| `ff2c129` | Document Lexivo CI/CD targets, secrets, and workflow contract |
| `7906ce0` | Add reusable lint, test, and build GitHub Actions composites |
| `32b13c8` | Add PR pipeline with OpenAPI snapshot drift check |
| `f48cccc` | Wire staging/production deploy callers for Cloud Run and Pages |
| `f47c1c4` | Add env-driven Sentry and PostHog hooks for backend and Flutter |

### Composites + callers

| Artifact | Role |
|---|---|
| `.github/actions/lint` | Flutter analyze + ruff |
| `.github/actions/test` | `flutter test` + pytest (eager Celery / SQLite CI env) |
| `.github/actions/build` | `web` \| `android-apk` \| `android-aab` \| `backend-image` |
| `.github/actions/deploy-cloud-run` | API + Celery worker; requires `environment`; project via inputs |
| `.github/actions/deploy-cloudflare-pages` | Wrangler Pages deploy; requires `environment` |
| `.github/workflows/pr.yml` | Lint/test/OpenAPI/image build/workflow-contract; no deploy |
| `.github/workflows/main.yml` | Checks + artifacts + staging deploy (gated on vars) |
| `.github/workflows/deploy-production.yml` | Tag / `workflow_dispatch` + `environment: production` |

Workflow contract paths verified present; deploy composites declare `environment:` and do not hardcode GCP project IDs.

### OpenAPI

- Snapshot: `openapi/lexivo.openapi.json`
- Enforced via `backend/scripts/check_openapi_snapshot.py` (wrapper `tool/check_openapi_snapshot.sh`)
- Independent run: **OpenAPI snapshot OK**

### Observability

- Backend: `init_sentry` in app lifespan; `PostHogAnalyticsProvider` vs stub via Settings/`provider_factory`
- Flutter: `lib/core/observability/sentry_bootstrap.dart`, `posthog_bootstrap.dart` from `main()`; `AppConfig` dart-defines default empty
- Tests: `backend/tests/test_observability.py` — **9 passed**; `test/core/config/app_config_test.dart` — **2 passed**

### Docs / Compose

- `docs/deployment.md` covers pipeline, Environment matrix, secrets, dart-defines, OpenAPI, observability, smoke checklist, and explicit note that live deploy needs credentials
- Local Compose retained (`backend/docker-compose.yml`); CI documents same Dockerfile / Settings names

### Spec alignment

| Source | Expectation | Status |
|---|---|---|
| OpenSpec ci-cd | Reusable composites; PR lint/tests; Pages + Cloud Run; env-driven; Sentry hooks | Met |
| architecture §6 | local / staging / production via env vars; Compose local | Met |
| nexora_spec §8 | analyze/test/pytest/Docker/web/APK-AAB; composites; Cloud Run + Pages; PostHog not Firebase | Met |
| nexora_spec §8.2 OTel/Grafana | Full mesh | Out of scope for STEP 3.8 (gate 11.9) — correct |

---

## Known partial (non-blocking)

- **Live deploy / green main Actions run:** Wiring and docs exist; staging soft-skips when `GCP_PROJECT_ID` / `CLOUDFLARE_PAGES_PROJECT` unset. Production path requires Environment secrets. Smoke checklist in `docs/deployment.md` remains operator-owned. Per review contract, this alone does **not** REJECT.

---

## Soft notes (non-blocking)

1. Staging and production callers share similar long `--set-env-vars` secret maps; deploy **logic** lives once in composites — acceptable thin-caller duplication.
2. Plan §11 checkboxes and the “ci-cd STEP 3.8 slice DoD met” commit remain for the implementer after this PASS (same pattern as STEP 3.7).
3. Branch protection (required status checks) is documented as a manual org/repo step — not automatable from the repo alone.

---

## Actionable findings

**None** — no REJECT blockers.

---

## Proceed decision

| Question | Answer |
|---|---|
| STEP 3.8 DoD met? | **Yes** |
| May STEP 3.9 / nexora_spec §12 final product DoD review proceed? | **Yes** |
| §12 “CI/CD green + auto-deploy” closed by this review? | **Not fully** — workflows ready; live green deploy awaits secrets + operator smoke |
