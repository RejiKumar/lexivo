# Lexivo CI/CD

**SoT for:** reusable composites, workflows, job catalog, OpenAPI snapshot, notify/rollback, and migration from interim staging-on-main.

**Cross-links:** [branching-strategy.md](branching-strategy.md) · [environment-strategy.md](environment-strategy.md) · [deployment-guide.md](deployment-guide.md) · [testing-strategy.md](testing-strategy.md) · [security.md](security.md)

---

## Goals

- Thin workflows; logic in **composite actions** under `.github/actions/`.
- Same jobs for PR / `dev` / `main`; environments differ by secrets/vars only.
- Target: **`dev` branch CI**; **`main` → production** (protected). Staging Environment later with minimal change.
- Contract enforced by `tool/check_workflow_contract.sh`.

---

## Existing reusable composites

| Composite | Path | Role today |
|---|---|---|
| **lint** | `.github/actions/lint` | Flutter `analyze` + Python ruff / compileall |
| **test** | `.github/actions/test` | `flutter test` + `pytest` |
| **build** | `.github/actions/build` | `web` / `android-apk` / `android-aab` / `backend-image` + dart-define inputs |
| **deploy-cloud-run** | `.github/actions/deploy-cloud-run` | API + Celery worker (same image, command override) |
| **deploy-cloudflare-pages** | `.github/actions/deploy-cloudflare-pages` | Flutter web → Pages |

Callers today: `pr.yml`, `main.yml`, `deploy-production.yml`.

---

## Conceptual extensions (implement when needed)

Keep callers thin — add composites rather than duplicating steps.

| Composite (planned) | Responsibility |
|---|---|
| **format** | `dart format --set-exit-if-changed` + `ruff format --check` (or black if adopted) |
| **coverage** | Flutter + pytest coverage; fail under threshold (see [testing-strategy.md](testing-strategy.md) — 80% business logic) |
| **build-ios** | `flutter build ipa` / archive on **`macos-latest`** (or self-hosted Mac); codesign via App Store Connect API key / certs in secrets |
| **notify** | Slack/Discord/email on deploy success/failure (webhook secret) |
| **rollback** | Redeploy previous GHCR digest / Pages deployment; optional DB migrate-down policy = **manual only** |

Wire these into workflows below without forking “staging vs prod” job bodies — pass `environment:` only.

---

## Target workflow map

| Trigger | Workflow (target) | Purpose |
|---|---|---|
| PR → `dev` or `main` | `pr.yml` | Lint, format, test, coverage (soft→hard), OpenAPI, Docker build **no push** from forks, workflow-contract |
| Push `dev` | `dev.yml` (add) | Same checks + optional build artifacts; optional deploy to **development** Environment if configured |
| Push `main` | `main.yml` (retarget) | Checks + build + **production** deploy (gated) — **not** staging |
| Tag `v*` / `workflow_dispatch` | `deploy-production.yml` | Explicit production ship with Environment approval |
| Manual | `rollback.yml` (add) | Rollback composite |

### Branch protection

Required checks on `main` (and preferably `dev`): `lint-flutter`, `lint-python`, `test-flutter`, `test-python`, `openapi-snapshot`, `workflow-contract`, `build-backend-image`. Do not allow production secrets on fork PRs.

---

## Job catalog

| Job | Runner | Notes |
|---|---|---|
| **analyze** | `ubuntu-latest` | Flutter analyze (via lint composite) |
| **format** | `ubuntu-latest` | Planned format composite |
| **lint** | `ubuntu-latest` | Flutter + Python (existing) |
| **tests** | `ubuntu-latest` | Flutter unit/widget + pytest |
| **coverage** | `ubuntu-latest` | Upload + gate (planned) |
| **web** | `ubuntu-latest` | `flutter build web --release` + dart-defines |
| **APK / AAB** | `ubuntu-latest` | Release signing when keystore secrets present |
| **iOS** | **`macos-latest`** | Documented; enable when Apple secrets + certificates ready |
| **Docker** | `ubuntu-latest` | Build `backend/Dockerfile`; push GHCR on trusted branches |
| **backend tests** | `ubuntu-latest` | pytest (part of test composite) |
| **deploy** | `ubuntu-latest` | Cloud Run + Cloudflare Pages via Environment |
| **tag** | `ubuntu-latest` | Optional: create `v*` from release workflow |
| **notify** | `ubuntu-latest` | Planned |
| **rollback** | `ubuntu-latest` | Planned; manual approval |
| **openapi-snapshot** | `ubuntu-latest` | Enforced today |
| **openapi-codegen-soft** | `ubuntu-latest` | Soft skip if no `generated/` |
| **qa / staging slot** | later | Same deploy composites → Environment `staging` |

### iOS / Mac runner

- Use `runs-on: macos-latest` (or `macos-14`).
- Secrets: `APP_STORE_CONNECT_API_KEY` (base64/.p8), Key ID, Issuer ID; provisioning via automatic signing or stored profiles.
- Do not attempt iOS on Ubuntu.
- Until enabled: document as **skipped** in `main`/`dev` workflows with a commented job or `if: false` placeholder.

### Image registry (GHCR)

- Image: `ghcr.io/<owner>/lexivo-backend:<git-sha>`
- Floating tags: `development` / `production` (and later `staging`)
- PR: build, **no push** from untrusted forks
- Auth: `GITHUB_TOKEN` + `packages:write`

### Dockerfile dual use

- API: default `uvicorn app.main:app --host 0.0.0.0 --port 8000`
- Worker: `celery -A app.tasks.celery_app worker --loglevel=info`
- Health: `GET /api/v1/health`

---

## OpenAPI snapshot

PR/main must keep `openapi/lexivo.openapi.json` equal to in-process `create_app().openapi()`.

```bash
./tool/check_openapi_snapshot.sh
# or
python backend/scripts/check_openapi_snapshot.py
# update:
python backend/scripts/check_openapi_snapshot.py --update
```

Full dart-dio codegen remains optional (`TODO(openapi-codegen)`). Soft job when `lib/core/network/generated/` absent.

---

## Migration path (interim staging on main)

**Current interim:** `main.yml` builds/deploys with GitHub Environment **`staging`** (and tags image `:staging`) when GCP/Cloudflare vars are set. `deploy-production.yml` already targets **`production`**.

**Preferred end state**

1. Add **`dev.yml`** (or extend PR + push on `dev`) for CI (+ optional non-prod deploy).
2. Retarget **`main.yml`** deploy jobs to Environment **`production`** (or only build on `main` and leave deploy to `deploy-production.yml`).
3. Protect `production` with required reviewers.
4. Until true staging exists, either:
   - **A (prefer when ready):** `main` → production only; stop using Environment name `staging` for main, **or**
   - **B (soft-skip):** keep `if: vars.GCP_PROJECT_ID != ''` skips so “staging” jobs no-op until vars exist; rename Environment when ready.
5. Later: add Environment `staging` + optional branch; reuse same composites — **minimal change**.

Do **not** introduce hardcoded `if staging:` in application code.

---

## Secrets & Environments (CI)

Configure under Settings → Environments. Same names, different values:

| Environment | Use |
|---|---|
| `production` | Live Cloud Run + Pages + store builds; **required reviewers** |
| `development` | Optional shared non-prod |
| `staging` | Later |

Required names (non-exhaustive): `GCP_*`, `CLOUD_RUN_*`, `DATABASE_URL`, `REDIS_URL`, `CELERY_BROKER_URL`, `SUPABASE_*`, `R2_*`, `GEMINI_API_KEY`, `MISTRAL_API_KEY`, `SENTRY_DSN`, `POSTHOG_*`, `CLOUDFLARE_*`, `API_BASE_URL`, Flutter dart-define sources. Prefer WIF over `GCP_SA_KEY`.

Detail: [environment-strategy.md](environment-strategy.md), [deployment-guide.md](deployment-guide.md).

---

## Notify & rollback (ops contract)

**Notify:** on deploy conclusion, post version, SHA, Environment, URLs, workflow run link.

**Rollback:**

1. Identify last known-good GHCR digest / Pages deployment ID.
2. Redeploy that image to Cloud Run (API + worker).
3. Redeploy prior web artifact or Pages rollback.
4. **Do not** auto-run irreversible DB downgrades; restore from Neon PITR if schema broke ([deployment-guide.md](deployment-guide.md)).

---

## QA env slot (later)

Treat QA as either:

- Cloudflare / PR preview + ephemeral API, or
- the future **staging** Environment

Same composites; no third copy of workflow YAML beyond `environment:` input.
