# Lexivo deployment & CI/CD

Config-driven local / staging / production (architecture §6). Staging vs production differ only by **GitHub Environment secrets/vars** — never hardcoded env forks in app code.

## Pipeline overview

```text
PR ──► lint (Flutter analyze + Python ruff/compile)
    ──► test (flutter test + pytest)
    ──► OpenAPI snapshot check
    ──► backend Docker build (no push from forks)

main ──► same checks
      ──► build: Flutter web, Android APK + AAB, backend image → GHCR
      ──► deploy staging: Cloudflare Pages + Cloud Run (API + Celery worker)

production ──► workflow_dispatch / tag v*
            ──► same composites with environment=production
            ──► GitHub Environment protection (required reviewers)
```

Reusable pieces live under `.github/actions/` (composite actions). Caller workflows in `.github/workflows/` stay thin.

## Environment matrix

| Concern | Local | Staging | Production |
|---|---|---|---|
| Host | Docker Compose (`backend/docker-compose.yml`) | Cloud Run + Cloudflare Pages | Cloud Run + Cloudflare Pages |
| DB | Compose Postgres+pgvector | Neon (via `DATABASE_URL`) | Neon |
| Redis | Compose Redis | Managed Redis / Memorystore | Managed Redis |
| API | `localhost:8000` | Cloud Run service | Cloud Run service |
| Worker | Compose `celery … worker` | Cloud Run (same image, command override) | Same |
| Web | `flutter run -d chrome` | Cloudflare Pages project (staging) | Cloudflare Pages project (production) |
| Config | `backend/.env` + Flutter `--dart-define` | GitHub Environment `staging` | GitHub Environment `production` |
| `APP_ENV` | `local` | `staging` | `production` |

### Local Compose

See [backend/README.md](../backend/README.md) and `backend/docker-compose.yml`.

```bash
cd backend
cp .env.example .env   # or copy on Windows
docker compose up --build
curl http://127.0.0.1:8000/api/v1/health
```

CI uses the **same image** (`backend/Dockerfile`) and **same Settings env var names**. PR pytest runs with eager Celery + in-memory/SQLite fixtures (no full Compose on every PR).

### Dockerfile dual use

- **API:** default `CMD` → `uvicorn app.main:app --host 0.0.0.0 --port 8000`
- **Worker:** override command → `celery -A app.tasks.celery_app worker --loglevel=info` (same as Compose `worker` service)

Health check path: `GET /api/v1/health`.

## Workflow contract

Composites that **must** exist (checked by `tool/check_workflow_contract.sh`):

| Composite | Path | Role |
|---|---|---|
| lint | `.github/actions/lint` | Flutter analyze + Python lint |
| test | `.github/actions/test` | Flutter test + pytest |
| build | `.github/actions/build` | web / android-apk / android-aab / backend-image |
| deploy-cloud-run | `.github/actions/deploy-cloud-run` | API + worker to Cloud Run |
| deploy-cloudflare-pages | `.github/actions/deploy-cloudflare-pages` | Flutter web → Pages |

Callers: `pr.yml`, `main.yml`, `deploy-production.yml`. Staging and production pass different `environment` / secrets only — they do not duplicate job bodies.

### Branch protection (manual)

Enable on `main` (org/repo admin):

- Require status checks: `lint-flutter`, `lint-python`, `test-flutter`, `test-python`, `openapi-snapshot`, `build-backend-image`
- Do **not** allow production deploy from PRs

## Image registry

**Choice: GitHub Container Registry (GHCR).**

- Tags: `ghcr.io/<owner>/lexivo-backend:<git-sha>` plus floating `staging` / `production` on deploy
- PR builds image to verify Dockerfile; **does not push** from untrusted forks
- Main pushes after green checks

Registry host is never hardcoded in application code — only in Actions inputs/vars.

## Flutter dart-defines (release)

| Define | Purpose | Default |
|---|---|---|
| `API_BASE_URL` | FastAPI base URL | `http://localhost:8000` |
| `SUPABASE_URL` | Auth | empty |
| `SUPABASE_ANON_KEY` | Auth (public) | empty |
| `SENTRY_DSN` | Sentry Flutter | empty (no-op) |
| `POSTHOG_API_KEY` | PostHog Flutter | empty (no-op) |
| `POSTHOG_HOST` | PostHog host | empty |
| `SUBSCRIPTION_PAYWALL_ENABLED` | Paywall UI | `false` |
| `LEXIVO_SHOWCASE` | Design-system showcase | `false` |

See root `.env.example`. Production/staging values come from GitHub Environment vars at **build** time.

## Backend Settings ↔ secrets

| Settings field | Env var | Notes |
|---|---|---|
| `app_env` | `APP_ENV` | `local` \| `staging` \| `production` (telemetry/log only) |
| `database_url` | `DATABASE_URL` | Neon in staging/prod |
| `redis_url` | `REDIS_URL` | |
| `celery_broker_url` | `CELERY_BROKER_URL` | |
| `celery_task_always_eager` | `CELERY_TASK_ALWAYS_EAGER` | `true` in CI unit tests |
| `sentry_dsn` | `SENTRY_DSN` | empty → no Sentry init |
| `posthog_api_key` | `POSTHOG_API_KEY` | empty → StubAnalyticsProvider |
| `posthog_host` | `POSTHOG_HOST` | optional |
| (+ provider keys) | see `backend/.env.example` | R2, LLM, OCR, Supabase, etc. |

## Required GitHub secrets & variables

Configure under **Settings → Environments** (`staging`, `production`) and/or repository secrets.

### Shared / registry

| Name | Type | Used by |
|---|---|---|
| `GITHUB_TOKEN` | automatic | GHCR push (packages:write) |

### GCP / Cloud Run (per Environment)

| Name | Type | Purpose |
|---|---|---|
| `GCP_PROJECT_ID` | variable | Cloud Run project |
| `GCP_REGION` | variable | e.g. `us-central1` |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | secret/var | WIF provider resource name |
| `GCP_SERVICE_ACCOUNT` | secret/var | Deploy SA email |
| `CLOUD_RUN_API_SERVICE` | variable | API service name |
| `CLOUD_RUN_WORKER_SERVICE` | variable | Worker service name |
| `DATABASE_URL` | secret | Neon connection string |
| `REDIS_URL` | secret | |
| `CELERY_BROKER_URL` | secret | |
| `SUPABASE_URL` / `SUPABASE_JWT_SECRET` / `SUPABASE_ANON_KEY` | secret | |
| `R2_*` | secret | Object storage |
| `GEMINI_API_KEY` / `MISTRAL_API_KEY` / … | secret | Providers |
| `SENTRY_DSN` | secret | Backend Sentry |
| `POSTHOG_API_KEY` / `POSTHOG_HOST` | secret | Backend analytics |
| `APP_ENV` | variable | `staging` or `production` |

Auth preference: **Workload Identity Federation** (no long-lived JSON key). Fallback: `GCP_SA_KEY` JSON secret if WIF is not yet configured.

### Cloudflare Pages (per Environment)

| Name | Type | Purpose |
|---|---|---|
| `CLOUDFLARE_API_TOKEN` | secret | Pages deploy |
| `CLOUDFLARE_ACCOUNT_ID` | secret | Account |
| `CLOUDFLARE_PAGES_PROJECT` | variable | Project name (staging ≠ production) |
| `API_BASE_URL` | variable | Built into Flutter web |
| `SENTRY_DSN` | secret | Flutter dart-define (may share backend DSN project or use a client project) |
| `POSTHOG_API_KEY` / `POSTHOG_HOST` | secret | Flutter dart-define |
| `SUPABASE_URL` / `SUPABASE_ANON_KEY` | secret/var | Flutter dart-define |

### One-time console setup

1. Create GitHub Environments `staging` and `production`; protect `production` with required reviewers.
2. Create GHCR package permissions for Actions.
3. GCP: enable Cloud Run + Artifact Registry APIs (if mirroring) + WIF pool bound to the deploy SA.
4. Cloudflare: create two Pages projects (or one project with branch aliases); create API token with Pages edit.
5. Point custom domains / DNS at Pages as needed.
6. Neon: create staging + production databases; put URLs in Environment secrets.

## OpenAPI snapshot

PR enforces: in-process `create_app().openapi()` must match `openapi/lexivo.openapi.json`.

```bash
# From repo root (Git Bash / Linux CI)
./tool/check_openapi_snapshot.sh
# Or
python backend/scripts/check_openapi_snapshot.py
```

Full dart-dio codegen remains optional (`TODO(openapi-codegen)`). Soft job skips if `lib/core/network/generated/` is absent.

## Observability

- **Sentry:** init when DSN non-empty (backend lifespan + Flutter bootstrap); no-op when empty (local/CI).
- **PostHog:** backend `PostHogAnalyticsProvider` when `POSTHOG_API_KEY` set; else stub. Flutter init when key set.
- Not Firebase Analytics. Full OTel/Grafana mesh is out of scope for this slice.

## Smoke checklist (after first green main)

- [ ] Staging API: `curl https://<cloud-run-url>/api/v1/health` → `{"status":"ok"}`
- [ ] Staging Pages URL loads Lexivo web shell
- [ ] GHCR image tagged with commit SHA exists
- [ ] Android APK + AAB artifacts downloadable from the Actions run
- [ ] Production workflow waits on Environment approval

> Live deploy cannot be verified in CI without real GCP/Cloudflare credentials. Wiring is present; operators must supply secrets.
