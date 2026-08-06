"""Lexivo backend — local development.

## Env (required)

```bash
cd backend
copy .env.example .env   # PowerShell; or `cp .env.example .env`
```

Edit `.env` with your Supabase, Gemini, Mistral, and R2 keys. **Never commit `.env`.**

On startup the API validates required vars, logs **masked** secrets, and prints enabled providers.
Tests set `LEXIVO_SKIP_ENV_VALIDATION=1` so pytest can use fakes without real keys.

## Run API locally (host)

Requires Postgres + Redis reachable at the URLs in `.env` (or Compose services on localhost ports).

```bash
cd backend
python -m pip install -r requirements.txt
uvicorn app.main:app --reload --app-dir .
```

Health: `GET http://127.0.0.1:8000/api/v1/health`

## Tests

```bash
cd backend
python -m pip install -e ".[dev]"
python -m pytest
```

Default CI uses **eager Celery** + Protocol fakes (no Redis/SDK). Optional Compose-backed cases are marked `@pytest.mark.compose` and skipped unless you opt in:

```bash
python -m pytest -m compose
```

## Docker Compose (local stack)

Requires Docker Desktop / Docker Engine with Compose v2.
**Hosting:** Cloud Run (API + Celery worker) + Cloudflare Pages (web) — see [docs/deployment-guide.md](../docs/deployment-guide.md) (index: [docs/deployment.md](../docs/deployment.md)).
Compose remains the **local** developer stack only (architecture.md §6).

```bash
cd backend
copy .env.example .env   # PowerShell; or `cp .env.example .env`
# fill secrets in .env
docker compose up --build
```

Services: Postgres+pgvector, Redis, API (`:8000`), Celery worker. Compose loads `backend/.env` (gitignored).

### CI

PR/main pipelines call reusable composites (`.github/actions/`) — Flutter analyze/test, pytest (eager Celery), OpenAPI snapshot check, Docker image build. See [docs/ci-cd.md](../docs/ci-cd.md).

### Verify Compose smoke — host verification

1. `cd backend`
2. `copy .env.example .env` and fill required keys
3. `docker compose up --build -d`
4. Wait until `postgres` and `redis` (and ideally `api`) report healthy
5. `curl http://127.0.0.1:8000/api/v1/health` → `{"status":"ok"}`
6. `docker compose down`
"""
