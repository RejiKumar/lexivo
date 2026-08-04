"""Lexivo backend — local development.

## Run API locally

```bash
cd backend
python -m pip install -r requirements.txt
uvicorn app.main:app --reload --app-dir .
```

Health: `GET http://127.0.0.1:8000/api/v1/health`

## Docker Compose (local stack)

Requires Docker Desktop / Docker Engine with Compose v2.

```bash
cd backend
copy .env.example .env   # PowerShell; or `cp .env.example .env`
docker compose up --build
```

Services: Postgres+pgvector, Redis, API, Celery worker.
Cloud Run / Railway hosting is deferred; Compose is the local stack only (architecture.md §6).

### Verify Compose smoke (task 1.9)

1. `docker compose up --build -d`
2. Wait until Postgres and Redis healthchecks are healthy
3. `curl http://127.0.0.1:8000/api/v1/health` → `{"status":"ok"}`
4. `docker compose down`
"""
