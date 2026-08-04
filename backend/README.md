"""Lexivo backend — local development.

## Run API locally

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
**Hosting (Cloud Run / Railway) is later** — Compose is the local stack only (architecture.md §6).

```bash
cd backend
copy .env.example .env   # PowerShell; or `cp .env.example .env`
docker compose up --build
```

Services: Postgres+pgvector, Redis, API (`:8000`), Celery worker.

### Verify Compose smoke (task 1.9) — host verification

Docker was not available in the Backend Agent CI/session environment; run this on a host with Docker:

1. `cd backend`
2. `copy .env.example .env` (or `cp .env.example .env`)
3. `docker compose up --build -d`
4. Wait until `postgres` and `redis` (and ideally `api`) report healthy
5. `curl http://127.0.0.1:8000/api/v1/health` → `{"status":"ok"}`
6. `docker compose down`
"""
