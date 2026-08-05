# Lexivo environment strategy

**SoT for:** which environments exist, how config differs, Flutter dart-defines, backend env files, secrets, app IDs, data isolation, domains, and how to add Staging later.

**Cross-links:** [deployment-guide.md](deployment-guide.md) · [ci-cd.md](ci-cd.md) · [security.md](security.md) · [production-checklist.md](production-checklist.md)

---

## Locked scope (now)

| Environment | Status | Purpose |
|---|---|---|
| **Development** | Active | Local + shared non-prod cloud when wired; `dev` branch CI |
| **Production** | Active | Live users; `main` → production (protected) |
| **Staging** | Later | Pre-prod parity slot; design so it slots in with minimal change |

Solo founder: keep two live surfaces only. Do **not** fork business logic by environment — differ by secrets, vars, dart-defines, and GitHub Environments only.

---

## Environment matrix (Dev + Prod)

| Concern | Development | Production | Staging (future) |
|---|---|---|---|
| Git | `dev`, `feature/*`, local | `main` (protected), `hotfix/*`, tags `v*` | Optional `staging` branch later |
| Host API / worker | Local Compose **or** Cloud Run (dev project) | Cloud Run | Cloud Run (separate services) |
| Host web | `flutter run` / Pages preview | Cloudflare Pages | Separate Pages project |
| DB | Local Postgres+pgvector **or** Neon **dev** | Neon **prod** | Neon **staging** |
| Object storage | Local / R2 **dev** bucket | R2 **prod** bucket | R2 **staging** bucket |
| Redis / Celery | Compose Redis | Managed Redis | Managed Redis (staging) |
| Auth | Supabase **dev** project | Supabase **prod** project | Supabase staging project |
| Backend env file | `.env.development` (local) | `.env.production` (reference only; runtime = GH secrets → Cloud Run) | `.env.staging` (future) |
| Flutter `ENV` | `development` | `production` | `staging` |
| GitHub Environment | `development` (optional) | `production` (required reviewers) | `staging` |
| `APP_ENV` (backend) | `local` or `development` | `production` | `staging` |
| Quotas | Same defaults (20 / 100 / 500) unless overridden | Defaults | Same |
| Subscription paywall | Off (`false`) | Off until launch decision | Off or match prod |
| Ads | Usually off (`ENABLE_ADS=false`) | AdMob on when ready | Off or test IDs |

### Local Compose (unchanged role)

See `backend/docker-compose.yml` and `backend/README.md`. Local is always “development” for app config even when Compose uses `APP_ENV=local`.

```bash
cd backend
cp .env.example .env.development   # or maintain .env as symlink/copy for Compose
docker compose up --build
curl http://127.0.0.1:8000/api/v1/health
```

CI pytest: eager Celery + fixtures (no full Compose on every PR). Same Dockerfile and Settings names as Cloud Run.

---

## Flutter dart-defines

Pass at **build/run** time (`--dart-define=KEY=value`). Empty observability keys = no-op. Never commit secret values.

### Required / canonical set

| Define | Purpose | Dev default | Prod default |
|---|---|---|---|
| `ENV` | Logical environment label | `development` | `production` |
| `API_BASE_URL` | FastAPI base URL | `http://localhost:8000` | `https://api.<prod-domain>` |
| `APP_NAME` | Display / branding override | `Lexivo Dev` | `Lexivo` |
| `ENABLE_LOGGING` | Verbose client logs | `true` | `false` |
| `ENABLE_ANALYTICS` | PostHog (and similar) | `false` | `true` |
| `ENABLE_CRASH_REPORTING` | Sentry | `false` | `true` |
| `ENABLE_ADS` | AdMob SDK / placements | `false` | `true` when ads live |
| `AI_PROVIDER` | Client hint / feature gate (server still authoritative) | `gemini` | `gemini` |
| `OCR_PROVIDER` | Client hint / feature gate | `mistral` | `mistral` |
| `SUPABASE_URL` | Auth project URL | Dev project | Prod project |
| `SUPABASE_ANON_KEY` | Public anon key | Dev anon | Prod anon |
| `SENTRY_DSN` | Flutter Sentry | empty / dev DSN | Prod client DSN |
| `POSTHOG_API_KEY` | Flutter PostHog | empty | Prod key |
| `POSTHOG_HOST` | PostHog host | empty / EU host | Prod host |
| `SUBSCRIPTION_PAYWALL_ENABLED` | Paywall UI only | `false` | `false` until paid launch |
| `LEXIVO_SHOWCASE` | Design-system catalog | `false` (opt-in `true` locally) | `false` |

Root `.env.example` documents the subset used today; extend loaders / build composite inputs as new keys are wired in `AppConfig`.

### Example

```bash
flutter run \
  --dart-define=ENV=development \
  --dart-define=API_BASE_URL=http://localhost:8000 \
  --dart-define=APP_NAME=Lexivo\ Dev \
  --dart-define=ENABLE_LOGGING=true \
  --dart-define=ENABLE_ANALYTICS=false \
  --dart-define=ENABLE_CRASH_REPORTING=false \
  --dart-define=ENABLE_ADS=false \
  --dart-define=AI_PROVIDER=gemini \
  --dart-define=OCR_PROVIDER=mistral \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=SUBSCRIPTION_PAYWALL_ENABLED=false
```

CI: GitHub Environment vars/secrets → `.github/actions/build` inputs at **build** time. See [ci-cd.md](ci-cd.md).

---

## Backend env files

| File | When | Notes |
|---|---|---|
| `backend/.env.example` | Always in repo | Template only; no secrets |
| `backend/.env.development` | Local / Compose | Gitignored; copy from example |
| `backend/.env.production` | Operator reference / rare local prod-shaped runs | Gitignored; **never** the source of truth for Cloud Run |
| `backend/.env.staging` | Future | Same shape as production; different values |

**Cloud Run:** inject via GitHub Environment secrets → deploy composite `env-vars`. Do not bake `.env.*` into images.

### Settings ↔ env (summary)

| Area | Env vars |
|---|---|
| Stage | `APP_ENV` |
| Infra | `DATABASE_URL`, `REDIS_URL`, `CELERY_BROKER_URL`, `CELERY_TASK_ALWAYS_EAGER` |
| Auth | `AUTH_PROVIDER=supabase`, `SUPABASE_URL`, `SUPABASE_JWT_SECRET`, `SUPABASE_ANON_KEY` |
| Storage | `STORAGE_PROVIDER=r2`, `R2_*` |
| AI | `LLM_PROVIDER=gemini`, `GEMINI_API_KEY` |
| OCR | `OCR_PROVIDER=mistral`, `MISTRAL_API_KEY` |
| Quotas | `FREE_TIER_DOCS_PER_MONTH=20`, `FREE_TIER_CHAT_MESSAGES_PER_DAY=100`, `FREE_TIER_OCR_PAGES_PER_MONTH=500` |
| Paywall | `SUBSCRIPTION_PAYWALL_ENABLED=false` |
| Observability | `SENTRY_DSN`, `POSTHOG_API_KEY`, `POSTHOG_HOST` |

Full template: `backend/.env.example`. Secrets handling: [security.md](security.md).

---

## Secrets: local + CI

| Location | Rule |
|---|---|
| Git | Never commit secrets, keystores, `.env.development` / `.env.production`, service-account JSON |
| Local | `.env.development` + Flutter defines / local env loader |
| CI | GitHub **Environments**: `production` (protected); optional `development`; future `staging` |
| Prefer | Workload Identity Federation for GCP; short-lived tokens for Cloudflare |

Naming convention: same secret **names** across Environments; values differ per Environment.

---

## Android applicationId variants

| Variant | applicationId (target) | Notes |
|---|---|---|
| Development | `com.lexivo.lexivo.dev` | Side-by-side install with prod |
| Production | `com.lexivo.lexivo` | Current default in `android/app/build.gradle.kts` |
| Staging (future) | `com.lexivo.lexivo.staging` | Separate Firebase/AdMob apps if needed |

Use product flavors / `--flavor` when introducing `.dev`. Until flavors land, local debug may share prod id — do not ship unsigned debug to stores.

SHA-1 / SHA-256: register **per** keystore (debug + upload/release) in Supabase / Google Cloud / App Links. See [deployment-guide.md](deployment-guide.md).

---

## iOS bundle IDs

| Variant | Bundle ID (target) |
|---|---|
| Development | `com.lexivo.lexivo.dev` |
| Production | `com.lexivo.lexivo` |
| Staging (future) | `com.lexivo.lexivo.staging` |

Separate App IDs enable parallel TestFlight vs App Store, distinct Sign in with Apple, and push certificates.

---

## DB and R2 separation

| Resource | Development | Production | Staging (future) |
|---|---|---|---|
| Neon database | `lexivo_dev` (or local Compose) | `lexivo_prod` | `lexivo_staging` |
| R2 bucket | `lexivo-dev` | `lexivo-prod` | `lexivo-staging` |
| Signed URLs | Short TTL; never public buckets | Same | Same |

No shared prod data in dev. Migrations: run against the target DB for that Environment only.

---

## Domains

| Surface | Development | Production | Staging (future) |
|---|---|---|---|
| API | `http://localhost:8000` | `https://api.lexivo.app` (example) | `https://api.staging.lexivo.app` |
| Web | `http://localhost:*` | `https://lexivo.app` / `www` | `https://staging.lexivo.app` |
| Auth redirects | localhost + custom schemes | Prod HTTPS + App Links / Universal Links | Staging HTTPS + schemes |

Exact hostnames are operator-owned; keep them as GitHub Environment **variables** (`API_BASE_URL`, Pages custom domain), not hardcoded in app code.

---

## How to add Staging later (checklist)

1. Create Neon DB + R2 bucket + Supabase project labeled staging.
2. Add GitHub Environment `staging` (optional protection).
3. Add `backend/.env.staging` to `.gitignore` docs only; wire Cloud Run services `*-staging`.
4. Create Cloudflare Pages project (or branch alias) for staging web.
5. Add Flutter dart-define `ENV=staging` and optional Android/iOS `.staging` applicationId / bundle ID.
6. Introduce `staging` branch **or** deploy from `dev` / `release/*` into the staging Environment — prefer Environment-only difference, same composites.
7. Soft-skip or remove interim “main deploys staging” path; keep **`dev` CI** and **`main` → production**. See [ci-cd.md](ci-cd.md) migration path.
8. Update this matrix and [production-checklist.md](production-checklist.md) once; do not invent a fourth “qa” env unless needed (QA slot = staging or ephemeral preview).

---

## Out of scope (documented elsewhere)

- Store signing, DNS, Cloud Run ops → [deployment-guide.md](deployment-guide.md)
- Workflows / composites → [ci-cd.md](ci-cd.md)
- PII / secrets policy → [security.md](security.md)
- Email template i18n → **future only** (not an env concern for v1)
