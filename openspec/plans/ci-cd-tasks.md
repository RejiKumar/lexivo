# CI/CD — Task Plan
Capability: **ci-cd** (reusable GitHub Actions composites + PR/main pipelines + staging/production deploy wiring)
Architecture: `spec/architecture.md` §6 (local / staging / production; env-driven `pydantic-settings`; never hardcoded per-env branches)
OpenSpec: `openspec/specs/ci-cd/spec.md`
Product: Lexivo (`spec/nexora_spec.md` §8 CI/CD & Deployment + §12 DoD items for pipeline + Sentry/analytics)
Execution order: **STEP 3.8** after all STEP 3.7 frontend features (subscription last) PASS

**Prerequisite (completed)**
- [x] STEP 3.7 subscription DoD **PASS** (`openspec/reviews/frontend-subscription-step37-review.md`) — all frontend feature slices done; CI/CD (STEP 3.8) may proceed
- [x] Local Docker Compose stack exists (`backend/docker-compose.yml`: Postgres+pgvector, Redis, API, Celery worker) — **reference only**; do not fork a second local stack
- [x] Backend `Dockerfile` exists (`backend/Dockerfile` — Python 3.12-slim, uvicorn on :8000)
- [x] OpenAPI snapshot + regen script exist (`openapi/lexivo.openapi.json`, `tool/generate_api_client.sh`); Flutter client remains interim façade with `TODO(openapi-codegen)`

**Out of scope for this file (later / separate)**
- App Store / Play Store **store submission** automation (this plan builds Android APK/AAB **artifacts** only; iOS IPA / TestFlight later)
- Full OpenTelemetry + Grafana + Prometheus production mesh (hooks/docs OK; deep observability stack later)
- Replacing interim Dio façade with full dart-dio codegen package (optional regen check + docs; full swap when pins allow)
- Rewriting product features, agents, or design-system atoms
- Changing free-tier quota defaults or paywall flag semantics
- Railway as primary host (architecture allows Railway/Cloud Run; **this plan standardizes on Cloud Run** for API/workers + Neon DB; Cloudflare Pages for web)

**Product defaults (resolved)**

| Concern | Choice |
|---|---|
| Workflow layout | `.github/workflows/` callers + `.github/actions/` **composite** actions (lint / test / build / deploy pieces). Environment-specific workflows **call** composites — never copy-paste job bodies per env |
| PR gate | On `pull_request`: Flutter analyze + Flutter test + Python pytest (+ optional OpenAPI snapshot check). No production deploy from PRs |
| Main / release | On `push` to `main` (and optional `workflow_dispatch` / tag): after green checks → build artifacts → deploy **staging** by default; **production** via explicit env approval / `production` GitHub Environment protection |
| Backend host | Google **Cloud Run** services: API (uvicorn) + worker (Celery) from the same `backend/Dockerfile` (worker overrides `command`) |
| Web host | **Cloudflare Pages** from Flutter web build output (`build/web`) |
| Mobile artifact | Android **APK** + **AAB** uploaded as GitHub Actions artifacts (not auto-published to stores in this step) |
| Local | Keep using Compose (`backend/docker-compose.yml`); CI documents parity (same image/env var names). CI pytest may use SQLite/eager Celery or service containers — document choice; do not require full Compose on every PR if too slow |
| Config | Staging vs production differences = **env vars / secrets / GitHub Environments only** (backend `Settings`; Flutter `--dart-define` / Pages env). No `if staging:` code forks |
| OpenAPI check | **Enforced** on PR: checked-in `openapi/lexivo.openapi.json` must match schema exported from the app (e.g. `create_app().openapi()` dump or live `/openapi.json` in CI). Full dart-dio **codegen** remains **optional** / soft (fail only if a `openapi-codegen` path is enabled later) |
| Sentry | Backend + Flutter: init when DSN present; no-op when empty (local/CI). Production Environment secrets supply DSNs |
| PostHog | Backend AnalyticsProvider real adapter (or thin init) when key present; Flutter PostHog SDK/init behind dart-define. Stub remains default for local/CI |
| Secrets | Document required GitHub Environment secrets in `docs/deployment.md` (create this doc — nexora_spec §11 item 10). Never commit secrets |

**Conventions**
- Loop per chunk: failing workflow/script/test → implement → verify green locally or via `act`/push → review vs OpenSpec ci-cd + architecture §6 + nexora_spec §8 → fix → commit.
- Prefer small sequential commits; never one giant “ci-cd” commit.
- Composites accept inputs (`working-directory`, `python-version`, `flutter-version`, `environment`, image tags, etc.) so staging/production callers stay thin.
- Prefix product: Lexivo; package `lexivo`; workflows name jobs clearly (`lint-flutter`, `test-python`, `build-backend-image`, …).
- Do not weaken PR checks to land deploy wiring — deploy jobs depend on test jobs.
- Local Compose remains the developer path; CI must not delete or replace `backend/docker-compose.yml`.

---

## 0. Inventory + deployment docs + decision gates

- [x] 0.1 **Decision gate:** document in this plan / `docs/deployment.md`: Cloud Run (API+worker) + Cloudflare Pages (web) + Neon (DB) + GitHub Environments `staging` / `production`; composites under `.github/actions/`; PR = lint+test only; main → staging auto; production = protected Environment
- [x] 0.2 Inventory status quo: confirm no `.github/workflows` yet (or list existing); note Compose + Dockerfile paths; note `TODO(openapi-codegen)` and snapshot path
- [x] 0.3 Create `docs/deployment.md`: pipeline diagram (nexora_spec §8.1), env matrix (local Compose / staging / production), required secrets table, how to run Compose locally (link `backend/docker-compose.yml` + `backend/README.md`)
- [x] 0.4 Add/extend root or backend README “CI” section pointing at workflows + `docs/deployment.md`
- [x] 0.5 Write a lightweight “workflow contract” checklist test or script comment block: composites must exist for lint, test, build (deploy composite or reusable workflow) — used by §11 gate
- [x] 0.6 Review vs OpenSpec “Reusable composite workflows” + architecture §6; fix; commit docs scaffold

---

## 1. Reusable composite actions (lint / test / build)

### 1.A Lint composite

- [x] 1.1 Create `.github/actions/lint/action.yml` (composite): inputs for Flutter + Python paths/versions
- [x] 1.2 Flutter branch: `flutter pub get` → `flutter analyze` (treat info/warnings per project standard; document `analysis_options.yaml` expectation)
- [x] 1.3 Python branch: install deps from `backend/requirements.txt` (or lockfile if present) → `ruff`/`flake8` **or** `python -m compileall` + document chosen linter; prefer adding `ruff` if not present (minimal pin) — failing test: composite exits non-zero on lint failure
- [x] 1.4 Document composite inputs/outputs in `docs/deployment.md`; commit lint composite

### 1.B Test composite

- [x] 1.5 Create `.github/actions/test/action.yml` (composite): Flutter test + pytest paths
- [x] 1.6 Flutter: `flutter test` (unit + widget); fail on any test failure
- [x] 1.7 Python: `pytest` under `backend/` with CI-friendly Settings (`CELERY_TASK_ALWAYS_EAGER=true`, test DB URL); use GitHub `services:` Postgres+pgvector and Redis when needed, **or** document sqlite/test fixtures already used by suite — prefer matching existing `backend/tests` patterns
- [x] 1.8 Write failing smoke: intentional broken assertion in a throwaway check then remove — or validate composite with a dry-run workflow_dispatch; commit test composite

### 1.C Build composite

- [x] 1.9 Create `.github/actions/build/action.yml` (composite) with inputs: `target` = `web` | `android-apk` | `android-aab` | `backend-image`
- [x] 1.10 Web path: `flutter build web --release` (+ required `--dart-define`s for API base URL etc. from inputs)
- [x] 1.11 Android paths: `flutter build apk` / `flutter build appbundle`; upload paths as outputs
- [x] 1.12 Backend image path: `docker build -t … -f backend/Dockerfile backend` (tag from inputs: sha / env)
- [x] 1.13 Review composites vs OpenSpec “without copy-pasting job definitions”; fix; commit build composite

---

## 2. PR pipeline (caller workflow)

- [x] 2.1 Create `.github/workflows/pr.yml` (or `ci.yml` on `pull_request`): jobs call lint + test composites only
- [x] 2.2 Ensure Flutter analyze/test and pytest both required for merge eligibility (branch protection doc note in `docs/deployment.md` — enabling protection may need org admin)
- [x] 2.3 Add concurrency group cancel-in-progress for same PR
- [x] 2.4 Write failing expectation: workflow YAML validates (`actionlint` optional job or pre-commit); fix; commit PR workflow
- [x] 2.5 Review vs OpenSpec scenario “PR pipeline”; fix; commit

---

## 3. Backend Docker build job + image publish hooks

- [x] 3.1 Caller job (in PR or main build workflow): build backend image via build composite; do **not** push from untrusted forks
- [x] 3.2 On `main`: push image to Artifact Registry / GHCR (document choice in `docs/deployment.md`; prefer **GHCR** or GCP Artifact Registry aligned with Cloud Run)
- [x] 3.3 Tag strategy: `git sha` + `staging` / `production` floating tags via env input — no hardcoded registry in app code
- [x] 3.4 Verify Dockerfile still works for API **and** worker (`command` override for Celery as in Compose); document in deployment.md
- [x] 3.5 Smoke: build image in CI; fail job on docker build error; commit

---

## 4. Flutter web + Android artifact jobs

- [x] 4.1 Main/PR-optional job: Flutter web build via composite; upload `build/web` as artifact
- [x] 4.2 Job: Android APK build; upload artifact
- [x] 4.3 Job: Android AAB build; upload artifact
- [x] 4.4 Cache Flutter SDK / pub + Gradle where practical (composite or caller)
- [x] 4.5 Document dart-defines required for release web/Android (`API_BASE_URL`, Sentry/PostHog keys placeholders, subscription flag, etc.) in `docs/deployment.md` + `.env.example` cross-link
- [x] 4.6 Review vs nexora_spec §8.1 job list; fix; commit

---

## 5. OpenAPI snapshot drift check (enforced) + codegen optional

- [x] 5.1 Add script `tool/check_openapi_snapshot.sh` (or Python under `backend/scripts/`): export schema from `create_app().openapi()` and diff against `openapi/lexivo.openapi.json` (normalized JSON)
- [x] 5.2 Write failing test/CI step: mutate snapshot → check fails; restore → passes
- [x] 5.3 Wire check into PR workflow (after backend deps install; no need for live server if in-process dump works)
- [x] 5.4 Update `docs/api_client.md` + `tool/generate_api_client.sh` notes: snapshot check is **CI-enforced**; full dart-dio codegen remains **optional** (`TODO(openapi-codegen)`) — do not fail PR on missing generated/ package unless explicitly enabled via input `enforce_codegen: true` (default false)
- [x] 5.5 Optional soft job: if `lib/core/network/generated/` exists, run regen dry-run and diff; otherwise skip
- [x] 5.6 Review vs architecture OpenAPI single-source rule; fix; commit

---

## 6. Environment configuration (staging / production)

- [x] 6.1 Define GitHub Environments: `staging`, `production` (protection rules documented; production requires reviewer)
- [x] 6.2 Backend Settings: add optional observability fields if missing — e.g. `app_env: Literal["local","staging","production"] = "local"`, `sentry_dsn: str = ""`, `posthog_api_key: str = ""`, `posthog_host: str = ""` — with unit tests for defaults + env override (TDD)
- [x] 6.3 Ensure no code path branches on env name for business logic; only init/telemetry/log level may read `app_env`
- [x] 6.4 Document mapping: GitHub secrets → Cloud Run env vars → Settings; Flutter dart-defines → `AppConfig`
- [x] 6.5 Align secret **names** with Compose `.env.example` where possible; extend `backend/.env.example` + root `.env.example` with Sentry/PostHog placeholders (empty defaults)
- [x] 6.6 Review vs architecture §6 “No hardcoded env branches”; fix; commit

---

## 7. Deploy composite / reusable workflow — Cloud Run (API + workers)

- [x] 7.1 Create `.github/actions/deploy-cloud-run/action.yml` **or** `.github/workflows/deploy-backend.yml` (`workflow_call`) with inputs: `environment`, `image`, `service_name`, `worker_service_name`, region, project id
- [x] 7.2 Auth to GCP via Workload Identity Federation (preferred) or service account key secret — document in `docs/deployment.md`
- [x] 7.3 Deploy API service (port 8000, health `/api/v1/health`) and Celery worker service/job from same image different args
- [x] 7.4 Wire env vars from GitHub Environment secrets (DATABASE_URL Neon, Redis, R2, LLM keys, SENTRY_DSN, POSTHOG_*, etc.)
- [x] 7.5 Write failing contract test or dry-run: deploy action requires `environment` input and refuses to use hardcoded project IDs in YAML (use secrets/vars)
- [x] 7.6 Staging caller on `main`: deploy backend after build+tests; production caller gated on Environment
- [x] 7.7 Review vs OpenSpec “Build and deploy targets” + Main branch deploy scenario; fix; commit

---

## 8. Deploy — Cloudflare Pages (Flutter web)

- [x] 8.1 Create deploy composite/reusable workflow for Cloudflare Pages: inputs `environment`, `dist_path` (default `build/web`), project name
- [x] 8.2 Auth via Cloudflare API token + account ID secrets; use `wrangler pages deploy` or official action
- [x] 8.3 Staging vs production = different Pages projects **or** branch aliases via env config — not forked build scripts
- [x] 8.4 Pass production API base URL and Sentry/PostHog dart-defines at **build** time (build composite inputs from Environment vars)
- [x] 8.5 Document DNS / Pages project setup steps in `docs/deployment.md` (manual one-time console steps OK)
- [x] 8.6 Wire staging auto-deploy on main; production protected; commit

---

## 9. Sentry + PostHog production wiring hooks

### 9.A Backend

- [x] 9.1 Write failing unit tests: when `sentry_dsn` empty → no Sentry init / no crash; when set → init hook called (mock)
- [x] 9.2 Implement backend Sentry init in app lifespan/factory (dependency optional; pin `sentry-sdk[fastapi]` if added)
- [x] 9.3 Write failing tests for PostHog/Analytics: empty key → StubAnalyticsProvider; non-empty → PostHog adapter binding via Settings (adapter may soft-fail emit)
- [x] 9.4 Implement thin PostHog `AnalyticsProvider` adapter under `app/adapters/analytics/` (SDK only in adapter module); DI selects stub vs real from Settings
- [x] 9.5 Confirm Analytics Agent still depends on Protocol only; grep guard no SDK in `app/agents/`

### 9.B Flutter

- [x] 9.6 Add dart-define / AppConfig hooks: `SENTRY_DSN`, `POSTHOG_API_KEY` (empty default); write failing tests that production flavor reads defines without requiring real network
- [x] 9.7 Wire Sentry Flutter init when DSN non-empty (pin `sentry_flutter` if added); no-op otherwise
- [x] 9.8 Wire PostHog Flutter init when key non-empty (pin official package); no-op / stub otherwise — **not** Firebase Analytics
- [x] 9.9 Ensure CI builds pass with empty DSNs; production Environment supplies values at build/deploy
- [x] 9.10 Review vs OpenSpec “Observability hooks” + nexora_spec §12 Sentry/analytics DoD; fix; commit

---

## 10. Main orchestration workflow + release notes hygiene

- [x] 10.1 Create `.github/workflows/main.yml` (or `deploy-staging.yml`): on push to `main` → lint → test → openapi check → build (web, android artifacts, docker) → deploy staging (Cloud Run + Pages)
- [x] 10.2 Create `.github/workflows/deploy-production.yml`: `workflow_dispatch` and/or tag `v*` → same composites with `environment=production`
- [x] 10.3 Ensure staging/production workflows **only** pass different `environment` / secrets — shared job graphs
- [x] 10.4 Add STATUS badge or short “CI status” note in root README
- [x] 10.5 Smoke checklist in `docs/deployment.md`: after first green main, verify staging health URL + Pages URL
- [x] 10.6 Review full OpenSpec ci-cd + §8; fix; commit orchestration

---

## 11. Reviewer gate checkpoints (STEP 3.8 CI/CD)

Run after §§0–10 land; blockers must be fixed before declaring this slice done.

- [ ] 11.1 **Prerequisite gate:** subscription STEP 3.7 review still PASS; no regression — `flutter test` and `pytest` green on main CI
- [ ] 11.2 **Composite reuse gate:** lint/test/build (and deploy) live as composites or `workflow_call` reusables; staging/production callers do not duplicate job bodies
- [ ] 11.3 **PR pipeline gate:** PR runs Flutter analyze + Flutter test + pytest (+ OpenAPI snapshot check); no production deploy on PR
- [ ] 11.4 **Build artifacts gate:** Docker backend image build; Flutter web build; Android APK + AAB artifacts produced on main pipeline
- [ ] 11.5 **Deploy targets gate:** Cloudflare Pages (web) + Cloud Run (API + worker) wired for staging; production path documented and gated via GitHub Environment
- [ ] 11.6 **Env config gate:** staging vs production differences are env/secrets only; Settings/dart-defines driven; local Compose still documented and unchanged in role
- [ ] 11.7 **OpenAPI gate:** snapshot drift check enforced on PR; full codegen optional/not required unless flag enabled
- [ ] 11.8 **Observability gate:** Sentry + PostHog hooks present; empty config safe for local/CI; production secrets documented
- [ ] 11.9 **Scope gate:** no store submission automation; no full OTel/Grafana stack required; no feature rewrites; Compose not replaced
- [ ] 11.10 **TDD / docs gate:** Settings/observability unit tests green; `docs/deployment.md` complete; workflows validated
- [ ] 11.11 Final review vs `openspec/specs/ci-cd/spec.md` + architecture §6 + nexora_spec §8; fix remaining gaps; commit “ci-cd STEP 3.8 slice DoD met”

---

## Definition of Done (STEP 3.8 — CI/CD)

- [x] Reusable GitHub Actions composites (lint, test, build) + thin env-specific callers
- [x] PR: Flutter analyze/test + pytest (+ OpenAPI snapshot check) before merge eligibility
- [x] Main: Docker backend build, Flutter web build, Android APK/AAB artifacts
- [x] Staging deploy wired: Cloudflare Pages (web) + Cloud Run (API + Celery worker); production path env-gated
- [x] Config-driven staging/production (Settings + secrets); local Compose referenced, not forked
- [x] Sentry + PostHog wiring hooks for production configs (safe no-op when unset)
- [ ] Reviewer gates 11.1–11.11 passed
- [x] Out of scope preserved (store submit; full observability mesh; mandatory dart-dio codegen)

---

## Coverage matrix (planner verification)

| Requirement (OpenSpec / architecture / §8) | Plan section |
|---|---|
| Reusable composite workflows (no copy-paste per env) | §1, §7–8, §10.3, §11.2 |
| PR: lint + tests Flutter + Python | §1–2, §11.3 |
| Flutter analyze / test | §1.2, §1.6, §2 |
| pytest | §1.7, §2 |
| Docker backend build | §1.12, §3, §11.4 |
| Flutter web → Cloudflare Pages | §4.1, §8, §11.5 |
| Android APK/AAB artifacts | §4.2–4.3, §11.4 |
| Cloud Run API + workers | §7, §11.5 |
| Staging/production via env config | §6, §10, §11.6 |
| Local Compose referenced | Prerequisites, §0.3, §11.6 / §11.9 |
| OpenAPI client regen check | §5 (enforced snapshot; optional codegen), §11.7 |
| Sentry + PostHog production hooks | §9, §11.8 |
| Main auto-deploy staging | §7.6, §8.6, §10.1, OpenSpec main scenario |
| subscription prerequisite completed | Prerequisites (PASS review) |

**OpenSpec scenarios covered:** **Yes** — PR lint/tests; main deploy to configured targets; no hardcoded env branches; Sentry when production config set.

**Local Compose:** **Referenced** (`backend/docker-compose.yml`) — not rebuilt; CI documents parity.

**Task count:** **87** numbered TDD/gate tasks (0.1–0.6, 1.1–1.13, 2.1–2.5, 3.1–3.5, 4.1–4.6, 5.1–5.6, 6.1–6.6, 7.1–7.7, 8.1–8.6, 9.1–9.10, 10.1–10.6, 11.1–11.11). Prerequisites (4) marked completed above and excluded. DoD summary list (8) is a roll-up of those gates, not extra work items.

---

## Reviewer

*(Leave blank for Reviewer Agent — fill after implementation.)*

| Field | Value |
|---|---|
| **Capability** | ci-cd (GitHub Actions composites + Cloud Run + Cloudflare Pages + observability hooks) |
| **Reviewer** | |
| **Date** | |
| **Sources** | `openspec/specs/ci-cd/spec.md`, `spec/architecture.md` §6, `spec/nexora_spec.md` §8, this plan §11, `openspec/reviews/frontend-subscription-step37-review.md` |
| **Verdict** | |

### Gate results

| # | Gate | Result |
|---|---|---|
| 11.1 | Prerequisite — subscription STEP 3.7 still PASS; CI tests green | |
| 11.2 | Composite reuse — no copy-pasted env job bodies | |
| 11.3 | PR pipeline — analyze + flutter test + pytest (+ OpenAPI check) | |
| 11.4 | Build artifacts — Docker + web + APK/AAB | |
| 11.5 | Deploy targets — Pages + Cloud Run staging; production gated | |
| 11.6 | Env config — secrets/Settings only; Compose retained | |
| 11.7 | OpenAPI — snapshot enforced; codegen optional | |
| 11.8 | Observability — Sentry + PostHog hooks | |
| 11.9 | Scope — no store submit / full OTel mesh / feature rewrites | |
| 11.10 | TDD / docs — tests + `docs/deployment.md` | |
| 11.11 | Final vs OpenSpec ci-cd + architecture §6 + §8 | |

### Notes

-
