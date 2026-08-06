# Lexivo

**Lexivo AI Document Assistant** — scan, understand, translate, and interrogate any document through an agent-powered RAG pipeline on mobile and web.

[![CI status](https://github.com/OWNER/lexivo/actions/workflows/pr.yml/badge.svg)](https://github.com/OWNER/lexivo/actions/workflows/pr.yml)

*(Replace `OWNER` with the GitHub org or user after the repository is published.)*

---

## Product Vision

Lexivo turns paperwork into answers. Students, professionals, and small businesses capture documents once, then summarize, translate, and ask grounded questions without reading every page. The product is scoped to a strong document vertical, built from reusable UI, agent, and service components so a broader productivity hub can assemble later from the same pieces.

Full product and technical scope: [spec/spec.md](spec/spec.md). Architecture: [spec/architecture.md](spec/architecture.md). UI system: [spec/ui_design_system.md](spec/ui_design_system.md).

## About

Lexivo is a cross-platform Flutter client backed by a FastAPI + LangGraph service layer. Documents flow through OCR, embeddings (pgvector), and specialized agents for summary, translation, RAG chat, and PDF export. Auth is Supabase; object storage is Cloudflare R2; web ships on Cloudflare Pages; API and workers run on Cloud Run.

## Problems Solved

| Pain | Lexivo response |
|---|---|
| Paper and PDF overload | Camera scan + OCR into clean, searchable text |
| Slow comprehension | AI short and detailed summaries |
| Language barriers | Translation of extracted content |
| Finding facts in long docs | Grounded RAG chat over the document |
| Sharing outcomes | PDF export of summaries, translations, and annotated results |
| Device lock-in | Cloud sync and account-based access across platforms |

## Features

| Capability | Notes |
|---|---|
| Document scan | Camera capture with crop / edge-aware input |
| OCR | Structured text extraction (Mistral OCR) |
| Summarization | Short and detailed AI summaries |
| Translation | Target-language translation of extracted text |
| RAG chat | Conversational Q&A grounded in the document |
| PDF export | Clean export of processed content |
| Cloud sync | Documents, chats, and summaries across devices |
| Auth & account | Sign up, sign in, session management (Supabase Auth) |
| Notifications | Processing-complete and reminder alerts |
| Subscription | Usage limits / paid tier — **feature-flagged** |
| Ads | Supported on the free tier |
| Adaptive web | Distinct mobile / tablet / desktop layouts (not stretched mobile) |
| Localization | English (`en`) in v1 |

Input strategy: [docs/document_input_source.md](docs/document_input_source.md). Typed API client: [docs/api_client.md](docs/api_client.md).

## AI Capabilities

- **Agent orchestrator** (LangGraph) routes OCR, summary, translation, RAG, and export as composable units
- **LLM:** Google Gemini (provider-swappable via adapters)
- **OCR:** Mistral OCR
- **Retrieval:** Hybrid search over PostgreSQL + pgvector embeddings
- **Background work:** Celery for OCR, embedding, translation, PDF, and notifications

## Tech Stack

| Layer | Technology |
|---|---|
| Client | Flutter 3.x, Riverpod, GoRouter |
| API | FastAPI |
| Agents | LangGraph |
| Data | PostgreSQL + pgvector |
| Jobs | Celery (+ Redis broker) |
| Auth | Supabase Auth |
| AI / OCR | Gemini, Mistral OCR |
| Storage | Cloudflare R2 |
| Hosting | Cloud Run (API + worker), Cloudflare Pages (web) |

## Folder Structure

**Target layout** (post-migration):

```text
lexivo/
  frontend/     # Flutter app (mobile + web)
  backend/      # FastAPI, Celery, agents
  docs/         # Ops, env, CI/CD, security, testing guides
  spec/         # Product & architecture specs
  prompts/      # Shared agent prompts
  scripts/      # Tooling and automation
  .github/      # Actions workflows and composites
  design/       # Design references
  assets/       # Shared static assets
```

> **Current state:** the Flutter app still lives at the repository root (`lib/`, `pubspec.yaml`, platform folders). Treat `frontend/` as the target home until migration completes. Backend already lives under `backend/`.

## Dev Setup

**Prerequisites:** Flutter 3.x SDK, Dart, Docker (for the local backend stack), Python 3.11+ (optional host runs without Compose).

```bash
# Flutter dependencies (repo root until frontend/ migration)
flutter pub get

# Backend: copy env template, add YOUR keys, then start Postgres/Redis/API/worker
cd backend
cp .env.example .env          # PowerShell: copy .env.example .env
# edit backend/.env — fill Supabase, Gemini, Mistral, R2 (never commit this file)
docker compose up --build
```

API health: `GET http://127.0.0.1:8000/api/v1/health`  
Backend notes: [backend/README.md](backend/README.md).

### Platform permissions (scan)

- **Android:** camera and media/storage permissions as required by `image_picker` / `file_picker` (`AndroidManifest.xml`)
- **iOS:** `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` (`Info.plist`)

## Local environment (DEBUG — do not commit secrets)

Secrets live only in **gitignored** files. Templates in the repo contain placeholders only.

| File | Role | Committed? |
|---|---|---|
| `backend/.env.example` | Backend template | Yes (placeholders) |
| `backend/.env` | Your backend keys (Pydantic Settings) | **No** |
| `.env.example` | Flutter dart-define template | Yes (placeholders) |
| `.env.development` | Your Flutter client defines — **one file for web, Android, and iOS** | **No** |

`.gitignore` ignores `.env`, `.env.*`, and keeps `!.env.example` / `!.env.*.example`.

**Split of responsibility**

| Variable | Where |
|---|---|
| `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `API_BASE_URL`, feature flags | Flutter (`--dart-define` / `.env.development`) |
| `SUPABASE_JWT_SECRET`, `DATABASE_URL`, `GEMINI_API_KEY`, `MISTRAL_API_KEY`, `R2_*`, Redis/Celery | `backend/.env` only |
| `SENTRY_DSN`, `POSTHOG_*` | Optional on both sides (empty = no-op) |

Never put `SUPABASE_JWT_SECRET`, Gemini, Mistral, or R2 secrets in Flutter dart-defines or source code.

### 1. Configure backend (`backend/.env`)

```bash
cd backend
cp .env.example .env
```

Fill at least:

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_JWT_SECRET=
DATABASE_URL=postgresql+psycopg://lexivo:lexivo@localhost:5432/lexivo
GEMINI_API_KEY=
LLM_PROVIDER=gemini
MISTRAL_API_KEY=
OCR_PROVIDER=mistral
R2_ACCOUNT_ID=
R2_ACCESS_KEY_ID=
R2_SECRET_ACCESS_KEY=
R2_BUCKET_NAME=
R2_ENDPOINT_URL=
CELERY_TASK_ALWAYS_EAGER=true
```

On startup the API logs **masked** values and enabled providers (never full secrets). If a required key is missing, it exits with a clear error pointing at `backend/.env`.

### 2. Configure Flutter (`.env.development`)

```bash
# from repo root
cp .env.example .env.development     # PowerShell: copy .env.example .env.development
```

Set `SUPABASE_URL` and `SUPABASE_ANON_KEY`; keep `API_BASE_URL=http://localhost:8000`.
This one file serves **every** debug target — web, Android emulator, Android USB
device, and iOS — because `tool/run_dev` tunnels the device's `localhost:8000`
to the host with `adb reverse`. There is no per-platform env file and no
`10.0.2.2` special case.

### 3. Start PostgreSQL (and Redis / API)

**Recommended — Docker Compose** (Postgres + pgvector, Redis, API, Celery worker):

```bash
cd backend
docker compose up --build
```

Compose reads `backend/.env` and overrides DB/Redis URLs to container hostnames.

**Optional — API on the host** (Compose Postgres/Redis still running, or your own Postgres):

```bash
cd backend
python -m pip install -r requirements.txt
# ensure backend/.env is filled
uvicorn app.main:app --reload --app-dir .
```

Only run one API process at a time. A second uvicorn bound to `127.0.0.1:8000`
takes precedence over one bound to `0.0.0.0:8000` on Windows, so a forgotten
instance with stale env silently serves every request.

**Optional — your own PostgreSQL install** (no Docker). Create the role, database,
and pgvector extension that `DATABASE_URL` expects:

```sql
-- as a superuser (psql -U postgres)
CREATE ROLE lexivo WITH LOGIN PASSWORD 'lexivo';
CREATE DATABASE lexivo OWNER lexivo;
\c lexivo
CREATE EXTENSION IF NOT EXISTS vector;   -- requires the pgvector extension files
```

`CREATE EXTENSION vector` fails unless pgvector is installed for that server
(Compose uses the `pgvector/pgvector` image, which bundles it). Without it, RAG
chat and embeddings cannot run.

### 4. Run Flutter in Debug mode

Start the API first (one instance only):

```powershell
powershell -ExecutionPolicy Bypass -File tool\run_api.ps1   # -Force replaces an existing listener
```

Then launch any target from the same `.env.development`:

```powershell
powershell -ExecutionPolicy Bypass -File tool\run_dev.ps1 -Target android   # emulator or USB phone
powershell -ExecutionPolicy Bypass -File tool\run_dev.ps1 -Target web
powershell -ExecutionPolicy Bypass -File tool\run_dev.ps1 -Target android -DeviceId RZCXB2B0CVT
```

macOS / Linux (required for iOS):

```bash
./tool/run_dev.sh --target ios
./tool/run_dev.sh --target web
```

The script sets up `adb reverse tcp:8000 tcp:8000` for Android targets, so the
device resolves `http://localhost:8000` to this machine — no `10.0.2.2`, no LAN
IP, and no firewall rule. For a physical **iOS** device (adb cannot tunnel),
pass your machine's LAN address; the script writes it back into the same file:

```bash
./tool/run_dev.sh --target ios --api-host 192.168.1.20
```

Plain `flutter run` still works if you prefer it:

```bash
flutter run --dart-define-from-file=.env.development -d chrome
```

If required client keys are missing, Debug mode shows a configuration screen
instead of crashing — that screen means you launched without the env file.

Design-system showcase (no backend keys required for UI only):

```bash
flutter run --dart-define=LEXIVO_SHOWCASE=true
```

### Provider setup guides

**Supabase**

1. Create a project at [supabase.com](https://supabase.com).
2. Project Settings → API: copy **Project URL** → `SUPABASE_URL`, the **anon / publishable** key → `SUPABASE_ANON_KEY` (Flutter + backend).
3. `SUPABASE_JWT_SECRET` (**backend only**) is optional. Projects using JWT signing
   keys issue asymmetric (ES256/RS256) access tokens, which the API verifies through
   the project JWKS derived from `SUPABASE_URL`. Only set the secret for legacy
   projects that still sign with HS256 (Project Settings → JWT Keys → legacy secret).
4. Auth → URL configuration: allow `http://localhost:*` (and your Flutter web origin) for local redirects.

**Google Gemini**

1. Create an API key in Google AI Studio (or Vertex).
2. Set `GEMINI_API_KEY` and `LLM_PROVIDER=gemini` in `backend/.env`.
3. Used for summary, translation, RAG chat — never ship this key in the Flutter app.

**Mistral OCR**

1. Create an API key in the Mistral console.
2. Set `MISTRAL_API_KEY` and `OCR_PROVIDER=mistral` in `backend/.env`.

**Cloudflare R2**

1. Cloudflare dashboard → R2 → create a private bucket (e.g. `lexivo-dev`).
2. Create an API token with object read/write for that bucket.
3. Set in `backend/.env`: `R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET_NAME`, `R2_ENDPOINT_URL` (S3-compatible endpoint for the account).

Full matrix (dev/prod, GitHub Environments): [docs/environment-strategy.md](docs/environment-strategy.md).  
Related: [docs/deployment-guide.md](docs/deployment-guide.md), [docs/security.md](docs/security.md), [docs/production-checklist.md](docs/production-checklist.md).

## Running the App

```bash
# After backend/.env + .env.development are filled and API is up:
flutter run --dart-define-from-file=.env.development -d chrome

# Mobile / desktop device
flutter run --dart-define-from-file=.env.development

# Design-system showcase
flutter run --dart-define=LEXIVO_SHOWCASE=true
```

Typical local API: `http://localhost:8000` (`API_BASE_URL`).
## Build Commands

```bash
# Analyze & unit/widget tests
flutter analyze
flutter test

# Web release
flutter build web --release

# Android
flutter build apk --release
flutter build appbundle --release

# OpenAPI client (from snapshot)
./tool/generate_api_client.sh
./tool/check_openapi_snapshot.sh
```

Backend tests: `cd backend && python -m pytest` (see [backend/README.md](backend/README.md)).

## CI/CD

PR checks, main-branch staging deploys, and production releases are defined as thin workflows over reusable composites under `.github/`.

**Details:** [docs/ci-cd.md](docs/ci-cd.md) · branching: [docs/branching-strategy.md](docs/branching-strategy.md) · versions: [docs/app-versioning.md](docs/app-versioning.md).

## Deployment Overview

Staging and production host the Flutter web app on **Cloudflare Pages** and the API/Celery workers on **Google Cloud Run**. Local development uses Docker Compose only.

**Details:** [docs/deployment-guide.md](docs/deployment-guide.md) · go-live gate: [docs/production-checklist.md](docs/production-checklist.md).

## Security

Auth, storage URL signing, PII handling, and rate limits are specified separately — do not invent ad-hoc auth or inline secrets.

**Details:** [docs/security.md](docs/security.md).

## Testing

Unit, widget, integration, golden, and backend pytest expectations live in the testing strategy. Prefer shared fixtures and generated clients over one-off mocks.

**Details:** [docs/testing-strategy.md](docs/testing-strategy.md).

## Roadmap

| Phase | Focus |
|---|---|
| **v1 (current)** | Scan → OCR → summary → translation → RAG chat → PDF export; auth, sync, notifications; adaptive web; `en` l10n; subscription flagged; free-tier ads |
| **Near-term** | Harden CI/CD and production checklist; complete `frontend/` migration; broaden language coverage |
| **Later** | Desktop (Windows); team collaboration; handwriting-tuned OCR; deeper offline generation |

Definition of Done for launch: [spec/spec.md](spec/spec.md) §12.

## Contribution Guide

1. Read [spec/spec.md](spec/spec.md), [spec/architecture.md](spec/architecture.md), and [docs/branching-strategy.md](docs/branching-strategy.md).
2. Work in small, feature-scoped PRs; follow the reusable-component checklist in the product spec.
3. Keep UI in the design system ([spec/ui_design_system.md](spec/ui_design_system.md)); keep prompts under `prompts/`.
4. Use the generated API client ([docs/api_client.md](docs/api_client.md)); do not hand-roll endpoints.
5. Run `flutter analyze` / `flutter test` and backend `pytest` before opening a PR; CI must stay green.
6. Never commit `.env` files or production secrets.
